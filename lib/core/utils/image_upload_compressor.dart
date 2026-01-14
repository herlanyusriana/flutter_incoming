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
    int? maxBytes,
    int minDimension = 720,
    int minQuality = 35,
  }) async {
    try {
      final bytes = await input.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return input;

      File? best;
      var currentMaxDimension = maxDimension;
      var currentQuality = quality;

      while (true) {
        var out = decoded;
        final width = decoded.width;
        final height = decoded.height;
        final largest = width > height ? width : height;
        if (largest > currentMaxDimension) {
          final targetW = width >= height ? currentMaxDimension : (width * currentMaxDimension / height).round();
          final targetH = height > width ? currentMaxDimension : (height * currentMaxDimension / width).round();
          out = img.copyResize(out, width: targetW, height: targetH, interpolation: img.Interpolation.average);
        }

        final jpgBytes = Uint8List.fromList(img.encodeJpg(out, quality: currentQuality));
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/upload_${DateTime.now().microsecondsSinceEpoch}.jpg');
        await file.writeAsBytes(jpgBytes, flush: true);
        best = file;

        if (maxBytes == null || jpgBytes.lengthInBytes <= maxBytes) return file;

        if (currentQuality > minQuality) {
          currentQuality = (currentQuality - 8).clamp(minQuality, 100);
          continue;
        }
        if (currentMaxDimension > minDimension) {
          currentMaxDimension = (currentMaxDimension * 0.85).round().clamp(minDimension, maxDimension);
          currentQuality = quality;
          continue;
        }

        return best;
      }
    } catch (_) {
      return input;
    }
  }
}
