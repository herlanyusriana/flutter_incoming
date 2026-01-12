import 'dart:io';
import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/storage/inspection_draft_storage.dart';
import '../data/inspection_repository.dart';

part 'inspection_state.dart';

class InspectionCubit extends Cubit<InspectionState> {
  InspectionCubit({required InspectionRepository repository, required int containerId})
      : _repo = repository,
        _containerId = containerId,
        _drafts = InspectionDraftStorage(),
        super(const InspectionState.loading());

  final InspectionRepository _repo;
  final int _containerId;
  final InspectionDraftStorage _drafts;

  Future<void> load() async {
    emit(const InspectionState.loading());
    try {
      final res = await _repo.getContainer(_containerId);
      final existingNotes = (res.inspection?.notes ?? '').trim();
      InspectionReady next = InspectionState.ready(
        arrival: res.arrival,
        container: res.container,
        hasExistingInspection: res.inspection != null,
        sealCode: (res.inspection?.sealCode ?? res.container.sealCode) ?? '',
        driverName: res.inspection?.driverName ?? '',
        notes: existingNotes,
        notesAuto: existingNotes.isEmpty,
        issuesLeft: res.inspection?.issuesLeft ?? const [],
        issuesRight: res.inspection?.issuesRight ?? const [],
        issuesFront: res.inspection?.issuesFront ?? const [],
        issuesBack: res.inspection?.issuesBack ?? const [],
        issuesInside: res.inspection?.issuesInside ?? const [],
        issuesSeal: res.inspection?.issuesSeal ?? const [],
        photoLeftUrl: res.inspection?.photoLeftUrl,
        photoRightUrl: res.inspection?.photoRightUrl,
        photoFrontUrl: res.inspection?.photoFrontUrl,
        photoBackUrl: res.inspection?.photoBackUrl,
        photoInsideUrl: res.inspection?.photoInsideUrl,
        photoSealUrl: res.inspection?.photoSealUrl,
        photoDamageUrl: res.inspection?.photoDamageUrl,
      ) as InspectionReady;

      final draft = await _drafts.load(_containerId);
      if (draft != null) {
        next = _applyDraft(next, draft);
      }

      emit(next);
    } catch (e) {
      emit(InspectionState.failure(e.toString()));
    }
  }

  InspectionReady _applyDraft(InspectionReady base, InspectionDraft draft) {
    File? fileOrNull(String? path) {
      if (path == null || path.trim().isEmpty) return null;
      final f = File(path);
      return f.existsSync() ? f : null;
    }

    return base.copyWith(
      sealCode: (draft.sealCode ?? base.sealCode),
      driverName: (draft.driverName ?? base.driverName),
      notes: (draft.notes ?? base.notes),
      notesAuto: (draft.notesAuto ?? base.notesAuto),
      issuesLeft: draft.issuesLeft ?? base.issuesLeft,
      issuesRight: draft.issuesRight ?? base.issuesRight,
      issuesFront: draft.issuesFront ?? base.issuesFront,
      issuesBack: draft.issuesBack ?? base.issuesBack,
      issuesInside: draft.issuesInside ?? base.issuesInside,
      issuesSeal: draft.issuesSeal ?? base.issuesSeal,
      photoLeft: fileOrNull(draft.photoLeftPath) ?? base.photoLeft,
      photoRight: fileOrNull(draft.photoRightPath) ?? base.photoRight,
      photoFront: fileOrNull(draft.photoFrontPath) ?? base.photoFront,
      photoBack: fileOrNull(draft.photoBackPath) ?? base.photoBack,
      photoInside: fileOrNull(draft.photoInsidePath) ?? base.photoInside,
      photoSeal: fileOrNull(draft.photoSealPath) ?? base.photoSeal,
      photoDamage: fileOrNull(draft.photoDamagePath) ?? base.photoDamage,
    );
  }

  Future<void> _saveDraft(InspectionReady s) async {
    final draft = InspectionDraft(
      containerId: _containerId,
      sealCode: s.sealCode,
      driverName: s.driverName,
      notes: s.notes,
      notesAuto: s.notesAuto,
      issuesLeft: s.issuesLeft,
      issuesRight: s.issuesRight,
      issuesFront: s.issuesFront,
      issuesBack: s.issuesBack,
      issuesInside: s.issuesInside,
      issuesSeal: s.issuesSeal,
      photoLeftPath: s.photoLeft?.path,
      photoRightPath: s.photoRight?.path,
      photoFrontPath: s.photoFront?.path,
      photoBackPath: s.photoBack?.path,
      photoInsidePath: s.photoInside?.path,
      photoSealPath: s.photoSeal?.path,
      photoDamagePath: s.photoDamage?.path,
    );
    await _drafts.save(draft);
  }

  void setSealCode(String sealCode) {
    final s = state;
    if (s is! InspectionReady) return;
    final next = s.copyWith(sealCode: sealCode);
    emit(next);
    unawaited(_saveDraft(next));
  }

  void setNotes(String notes) {
    final s = state;
    if (s is! InspectionReady) return;
    final nextAuto = notes.trim().isEmpty;
    final next = s.copyWith(notes: notes, notesAuto: nextAuto);
    emit(next);
    unawaited(_saveDraft(next));
  }

  void setDriverName(String name) {
    final s = state;
    if (s is! InspectionReady) return;
    final next = s.copyWith(driverName: name);
    emit(next);
    unawaited(_saveDraft(next));
  }

  String buildAutoNotes() {
    final s = state;
    if (s is! InspectionReady) return '';
    return _buildAutoNotes(s);
  }

  void applyAutoNotes() {
    final s = state;
    if (s is! InspectionReady) return;
    final next = s.copyWith(notes: _buildAutoNotes(s), notesAuto: true);
    emit(next);
    unawaited(_saveDraft(next));
  }

  String _buildAutoNotes(InspectionReady s) {
    List<String> cleanIssues(List<String> issues) {
      return issues.map((e) => e.trim()).where((e) => e.isNotEmpty).toSet().toList()..sort();
    }

    String fmtSide(String label, List<String> issues) {
      final clean = cleanIssues(issues);
      if (clean.isEmpty) return '';
      return '$label (${clean.join(', ')})';
    }

    final damageParts = <String>[
      fmtSide('Depan', s.issuesFront),
      fmtSide('Belakang', s.issuesBack),
      fmtSide('Kiri', s.issuesLeft),
      fmtSide('Kanan', s.issuesRight),
      fmtSide('Dalam', s.issuesInside),
      fmtSide('No. Seal', s.issuesSeal),
    ].where((e) => e.isNotEmpty).toList();

    final header = 'Hasil inspeksi visual container ${s.container.containerNo}';

    if (damageParts.isEmpty) {
      return '$header: kondisi dalam keadaan baik.';
    }

    return '$header: ditemukan kerusakan pada ${damageParts.join(' | ')}.';
  }

  void toggleIssue(InspectionSide side, String issue) {
    final s = state;
    if (s is! InspectionReady) return;
    final next = s.toggleIssue(side, issue);
    if (!next.notesAuto) {
      emit(next);
      unawaited(_saveDraft(next));
      return;
    }
    final autoNotes = _buildAutoNotes(next);
    final finalNext = next.copyWith(notes: autoNotes, notesAuto: true);
    emit(finalNext);
    unawaited(_saveDraft(finalNext));
  }

  Future<void> setPhoto(InspectionSide side, File photo) async {
    final s = state;
    if (s is! InspectionReady) return;
    final slot = _drafts.slotForSide(side);
    File nextPhoto = photo;
    try {
      nextPhoto = await _drafts.persistPhoto(containerId: _containerId, slot: slot, source: photo);
    } catch (_) {}

    final next = s.copyWithPhoto(side, nextPhoto);
    emit(next);
    unawaited(_saveDraft(next));
  }

  Future<void> setDamagePhoto(File? photo) async {
    final s = state;
    if (s is! InspectionReady) return;
    if (photo == null) {
      final next = s.copyWith(photoDamage: null);
      emit(next);
      unawaited(_saveDraft(next));
      return;
    }

    File nextPhoto = photo;
    try {
      nextPhoto = await _drafts.persistPhoto(containerId: _containerId, slot: 'damage', source: photo);
    } catch (_) {}

    final next = s.copyWith(photoDamage: nextPhoto);
    emit(next);
    unawaited(_saveDraft(next));
  }

  String _deriveStatus(InspectionReady s) {
    final hasIssues = s.issuesLeft.isNotEmpty ||
        s.issuesRight.isNotEmpty ||
        s.issuesFront.isNotEmpty ||
        s.issuesBack.isNotEmpty ||
        s.issuesInside.isNotEmpty ||
        s.issuesSeal.isNotEmpty;
    return hasIssues ? 'damage' : 'ok';
  }

  Future<void> submit() async {
    final s = state;
    if (s is! InspectionReady) return;

    if (!s.hasExistingInspection) {
      final missing = <String>[];
      if (s.sealCode.trim().isEmpty) missing.add('no. seal');
      if (s.driverName.trim().isEmpty) missing.add('driver name');
      if (s.photoLeft == null) missing.add('foto kiri');
      if (s.photoRight == null) missing.add('foto kanan');
      if (s.photoFront == null) missing.add('foto depan');
      if (s.photoBack == null) missing.add('foto belakang');
      if (s.photoInside == null) missing.add('foto dalam');
      if (s.photoSeal == null) missing.add('foto seal');
      if (missing.isNotEmpty) {
        emit(InspectionState.failure('Wajib upload: ${missing.join(', ')}'));
        emit(s);
        return;
      }
    }

    emit(s.copyWith(submitting: true, error: null));
    try {
      final computedNotes = s.notes.trim().isEmpty ? _buildAutoNotes(s) : s.notes.trim();
      await _repo.submit(
        containerId: _containerId,
        status: _deriveStatus(s),
        sealCode: s.sealCode.trim().isEmpty ? null : s.sealCode.trim(),
        driverName: s.driverName.trim().isEmpty ? null : s.driverName.trim(),
        notes: computedNotes.isEmpty ? null : computedNotes,
        photoLeft: s.photoLeft,
        photoRight: s.photoRight,
        photoFront: s.photoFront,
        photoBack: s.photoBack,
        photoInside: s.photoInside,
        photoSeal: s.photoSeal,
        photoDamage: s.photoDamage,
        issuesLeft: s.issuesLeft,
        issuesRight: s.issuesRight,
        issuesFront: s.issuesFront,
        issuesBack: s.issuesBack,
        issuesInside: s.issuesInside,
        issuesSeal: s.issuesSeal,
      );
      await _drafts.clear(_containerId);
      emit(s.copyWith(submitting: false, submitted: true));
    } catch (e) {
      emit(s.copyWith(submitting: false, error: e.toString()));
    }
  }
}

enum InspectionSide { left, right, front, back, inside, seal }
