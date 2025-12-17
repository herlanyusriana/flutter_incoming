import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/inspection_repository.dart';

part 'inspection_state.dart';

class InspectionCubit extends Cubit<InspectionState> {
  InspectionCubit({required InspectionRepository repository, required int arrivalId})
      : _repo = repository,
        _arrivalId = arrivalId,
        super(const InspectionState.loading());

  final InspectionRepository _repo;
  final int _arrivalId;

  Future<void> load() async {
    emit(const InspectionState.loading());
    try {
      final res = await _repo.getArrival(_arrivalId);
      emit(InspectionState.ready(
        arrival: res.arrival,
        hasExistingInspection: res.inspection != null,
        notes: res.inspection?.notes ?? '',
        issuesLeft: res.inspection?.issuesLeft ?? const [],
        issuesRight: res.inspection?.issuesRight ?? const [],
        issuesFront: res.inspection?.issuesFront ?? const [],
        issuesBack: res.inspection?.issuesBack ?? const [],
      ));
    } catch (e) {
      emit(InspectionState.failure(e.toString()));
    }
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
      if (s.photoLeft == null) missing.add('foto kiri');
      if (s.photoRight == null) missing.add('foto kanan');
      if (s.photoFront == null) missing.add('foto depan');
      if (s.photoBack == null) missing.add('foto belakang');
      if (missing.isNotEmpty) {
        emit(InspectionState.failure('Wajib upload: ${missing.join(', ')}'));
        emit(s);
        return;
      }
    }

    emit(s.copyWith(submitting: true, error: null));
    try {
      await _repo.submit(
        arrivalId: _arrivalId,
        status: _deriveStatus(s),
        notes: s.notes.trim().isEmpty ? null : s.notes.trim(),
        photoLeft: s.photoLeft,
        photoRight: s.photoRight,
        photoFront: s.photoFront,
        photoBack: s.photoBack,
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

enum InspectionSide { left, right, front, back }

