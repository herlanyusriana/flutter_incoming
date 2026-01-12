import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImageUploadCompressor {
  const ImageUploadCompressor();

  Future<File> compress(
    File input, {
    int maxDimension = 1280,
    int quality = 60,
  }) async {
    try {
      final bytes = await input.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return input;

      img.Image out = decoded;
      final width = decoded.width;
      final height = decoded.height;
      final largest = width > height ? width : height;
      if (largest > maxDimension) {
        final targetW = width >= height ? maxDimension : (width * maxDimension / height).round();
        final targetH = height > width ? maxDimension : (height * maxDimension / width).round();
        out = img.copyResize(out, width: targetW, height: targetH, interpolation: img.Interpolation.average);
      }

      final jpg = Uint8List.fromList(img.encodeJpg(out, quality: quality));
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/upload_${DateTime.now().microsecondsSinceEpoch}.jpg');
      await file.writeAsBytes(jpg, flush: true);
      return file;
    } catch (_) {
      return input;
    }
  }
}

