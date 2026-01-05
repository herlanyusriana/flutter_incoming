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
      emit(InspectionState.ready(
        arrival: res.arrival,
        container: res.container,
        hasExistingInspection: res.inspection != null,
        sealCode: (res.inspection?.sealCode ?? res.container.sealCode) ?? '',
        notes: res.inspection?.notes ?? '',
        issuesLeft: res.inspection?.issuesLeft ?? const [],
        issuesRight: res.inspection?.issuesRight ?? const [],
        issuesFront: res.inspection?.issuesFront ?? const [],
        issuesBack: res.inspection?.issuesBack ?? const [],
        photoLeftUrl: res.inspection?.photoLeftUrl,
        photoRightUrl: res.inspection?.photoRightUrl,
        photoFrontUrl: res.inspection?.photoFrontUrl,
        photoBackUrl: res.inspection?.photoBackUrl,
        photoInsideUrl: res.inspection?.photoInsideUrl,
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
    emit(s.copyWith(notes: notes));
  }

  void toggleIssue(InspectionSide side, String issue) {
    final s = state;
    if (s is! InspectionReady) return;
    emit(s.toggleIssue(side, issue));
  }

  void setPhoto(InspectionSide side, File photo) {
    final s = state;
    if (s is! InspectionReady) return;
    emit(s.copyWithPhoto(side, photo));
  }

  String _deriveStatus(InspectionReady s) {
    final hasIssues = s.issuesLeft.isNotEmpty || s.issuesRight.isNotEmpty || s.issuesFront.isNotEmpty || s.issuesBack.isNotEmpty;
    return hasIssues ? 'damage' : 'ok';
  }

  Future<void> submit() async {
    final s = state;
    if (s is! InspectionReady) return;

    if (!s.hasExistingInspection) {
      final missing = <String>[];
      if (s.sealCode.trim().isEmpty) missing.add('no. seal');
      if (s.photoLeft == null) missing.add('foto kiri');
      if (s.photoRight == null) missing.add('foto kanan');
      if (s.photoFront == null) missing.add('foto depan');
      if (s.photoBack == null) missing.add('foto belakang');
      if (s.photoInside == null) missing.add('foto dalam');
      if (missing.isNotEmpty) {
        emit(InspectionState.failure('Wajib upload: ${missing.join(', ')}'));
        emit(s);
        return;
      }
    }

    emit(s.copyWith(submitting: true, error: null));
    try {
      await _repo.submit(
        containerId: _containerId,
        status: _deriveStatus(s),
        sealCode: s.sealCode.trim().isEmpty ? null : s.sealCode.trim(),
        notes: s.notes.trim().isEmpty ? null : s.notes.trim(),
        photoLeft: s.photoLeft,
        photoRight: s.photoRight,
        photoFront: s.photoFront,
        photoBack: s.photoBack,
        photoInside: s.photoInside,
        issuesLeft: s.issuesLeft,
        issuesRight: s.issuesRight,
        issuesFront: s.issuesFront,
        issuesBack: s.issuesBack,
      );
      emit(s.copyWith(submitting: false, submitted: true));
    } catch (e) {
      emit(s.copyWith(submitting: false, error: e.toString()));
    }
  }
}

enum InspectionSide { left, right, front, back, inside }
