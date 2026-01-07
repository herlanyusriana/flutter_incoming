import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/inspection_repository.dart';

part 'inspection_state.dart';

class InspectionCubit extends Cubit<InspectionState> {
  InspectionCubit({required InspectionRepository repository, required int containerId})
      : _repo = repository,
        _containerId = containerId,
        super(const InspectionState.loading());

  final InspectionRepository _repo;
  final int _containerId;

  Future<void> load() async {
    emit(const InspectionState.loading());
    try {
      final res = await _repo.getContainer(_containerId);
      final existingNotes = (res.inspection?.notes ?? '').trim();
      emit(InspectionState.ready(
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
      ));
    } catch (e) {
      emit(InspectionState.failure(e.toString()));
    }
  }

  void setSealCode(String sealCode) {
    final s = state;
    if (s is! InspectionReady) return;
    emit(s.copyWith(sealCode: sealCode));
  }

  void setNotes(String notes) {
    final s = state;
    if (s is! InspectionReady) return;
    final nextAuto = notes.trim().isEmpty;
    emit(s.copyWith(notes: notes, notesAuto: nextAuto));
  }

  void setDriverName(String name) {
    final s = state;
    if (s is! InspectionReady) return;
    emit(s.copyWith(driverName: name));
  }

  String buildAutoNotes() {
    final s = state;
    if (s is! InspectionReady) return '';
    return _buildAutoNotes(s);
  }

  void applyAutoNotes() {
    final s = state;
    if (s is! InspectionReady) return;
    emit(s.copyWith(notes: _buildAutoNotes(s), notesAuto: true));
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
      return;
    }
    final autoNotes = _buildAutoNotes(next);
    emit(next.copyWith(notes: autoNotes, notesAuto: true));
  }

  void setPhoto(InspectionSide side, File photo) {
    final s = state;
    if (s is! InspectionReady) return;
    emit(s.copyWithPhoto(side, photo));
  }

  void setDamagePhoto(File? photo) {
    final s = state;
    if (s is! InspectionReady) return;
    emit(s.copyWith(photoDamage: photo));
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
      emit(s.copyWith(submitting: false, submitted: true));
    } catch (e) {
      emit(s.copyWith(submitting: false, error: e.toString()));
    }
  }
}

enum InspectionSide { left, right, front, back, inside, seal }
