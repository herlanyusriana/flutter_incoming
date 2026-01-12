import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/inspection/cubit/inspection_cubit.dart';

class InspectionDraft {
  const InspectionDraft({
    required this.containerId,
    this.sealCode,
    this.driverName,
    this.notes,
    this.notesAuto,
    this.issuesLeft,
    this.issuesRight,
    this.issuesFront,
    this.issuesBack,
    this.issuesInside,
    this.issuesSeal,
    this.photoLeftPath,
    this.photoRightPath,
    this.photoFrontPath,
    this.photoBackPath,
    this.photoInsidePath,
    this.photoSealPath,
    this.photoDamage1Path,
    this.photoDamage2Path,
    this.photoDamage3Path,
  });

  final int containerId;
  final String? sealCode;
  final String? driverName;
  final String? notes;
  final bool? notesAuto;
  final List<String>? issuesLeft;
  final List<String>? issuesRight;
  final List<String>? issuesFront;
  final List<String>? issuesBack;
  final List<String>? issuesInside;
  final List<String>? issuesSeal;
  final String? photoLeftPath;
  final String? photoRightPath;
  final String? photoFrontPath;
  final String? photoBackPath;
  final String? photoInsidePath;
  final String? photoSealPath;
  final String? photoDamage1Path;
  final String? photoDamage2Path;
  final String? photoDamage3Path;

  Map<String, dynamic> toJson() => {
        'container_id': containerId,
        'seal_code': sealCode,
        'driver_name': driverName,
        'notes': notes,
        'notes_auto': notesAuto,
        'issues_left': issuesLeft,
        'issues_right': issuesRight,
        'issues_front': issuesFront,
        'issues_back': issuesBack,
        'issues_inside': issuesInside,
        'issues_seal': issuesSeal,
        'photo_left_path': photoLeftPath,
        'photo_right_path': photoRightPath,
        'photo_front_path': photoFrontPath,
        'photo_back_path': photoBackPath,
        'photo_inside_path': photoInsidePath,
        'photo_seal_path': photoSealPath,
        'photo_damage_1_path': photoDamage1Path,
        'photo_damage_2_path': photoDamage2Path,
        'photo_damage_3_path': photoDamage3Path,
      };

  static InspectionDraft fromJson(Map<String, dynamic> json) {
    List<String>? list(String key) {
      final raw = json[key];
      if (raw is List) {
        return raw.map((e) => e.toString()).toList();
      }
      return null;
    }

    return InspectionDraft(
      containerId: (json['container_id'] as num).toInt(),
      sealCode: json['seal_code'] as String?,
      driverName: json['driver_name'] as String?,
      notes: json['notes'] as String?,
      notesAuto: json['notes_auto'] as bool?,
      issuesLeft: list('issues_left'),
      issuesRight: list('issues_right'),
      issuesFront: list('issues_front'),
      issuesBack: list('issues_back'),
      issuesInside: list('issues_inside'),
      issuesSeal: list('issues_seal'),
      photoLeftPath: json['photo_left_path'] as String?,
      photoRightPath: json['photo_right_path'] as String?,
      photoFrontPath: json['photo_front_path'] as String?,
      photoBackPath: json['photo_back_path'] as String?,
      photoInsidePath: json['photo_inside_path'] as String?,
      photoSealPath: json['photo_seal_path'] as String?,
      // Backward compatible: old drafts used single photo_damage_path
      photoDamage1Path: (json['photo_damage_1_path'] as String?) ?? (json['photo_damage_path'] as String?),
      photoDamage2Path: json['photo_damage_2_path'] as String?,
      photoDamage3Path: json['photo_damage_3_path'] as String?,
    );
  }
}

class InspectionDraftStorage {
  static const _keyPrefix = 'inspection_draft_v2_';

  String _key(int containerId) => '$_keyPrefix$containerId';

  Future<InspectionDraft?> load(int containerId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(containerId));
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final jsonMap = jsonDecode(raw) as Map<String, dynamic>;
      final draft = InspectionDraft.fromJson(jsonMap);
      return draft.containerId == containerId ? draft : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> save(InspectionDraft draft) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(draft.containerId), jsonEncode(draft.toJson()));
  }

  Future<void> clear(int containerId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(containerId));

    // Best-effort cleanup for old key version
    await prefs.remove('inspection_draft_v1_$containerId');

    final dir = await _draftDir(containerId);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  Future<File> persistPhoto({
    required int containerId,
    required String slot,
    required File source,
  }) async {
    final draftDir = await _draftDir(containerId);
    if (!await draftDir.exists()) {
      await draftDir.create(recursive: true);
    }

    final ext = _safeExt(source.path);
    final name = '${slot}_${DateTime.now().millisecondsSinceEpoch}$ext';
    final target = File('${draftDir.path}${Platform.pathSeparator}$name');

    if (await target.exists()) {
      await target.delete();
    }
    return source.copy(target.path);
  }

  Future<Directory> _draftDir(int containerId) async {
    final base = await getApplicationDocumentsDirectory();
    return Directory('${base.path}${Platform.pathSeparator}inspection_drafts${Platform.pathSeparator}$containerId');
  }

  String _safeExt(String path) {
    final lower = path.toLowerCase();
    for (final ext in ['.jpg', '.jpeg', '.png', '.heic', '.webp']) {
      if (lower.endsWith(ext)) return ext;
    }
    return '.jpg';
  }

  String slotForSide(InspectionSide side) {
    return switch (side) {
      InspectionSide.left => 'left',
      InspectionSide.right => 'right',
      InspectionSide.front => 'front',
      InspectionSide.back => 'back',
      InspectionSide.inside => 'inside',
      InspectionSide.seal => 'seal',
    };
  }
}
