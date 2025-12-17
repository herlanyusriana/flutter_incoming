part of 'inspection_cubit.dart';

sealed class InspectionState extends Equatable {
  const InspectionState();

  const factory InspectionState.loading() = InspectionLoading;
  const factory InspectionState.ready({
    required ArrivalInfo arrival,
    required bool hasExistingInspection,
    required String notes,
    required List<String> issuesLeft,
    required List<String> issuesRight,
    required List<String> issuesFront,
    required List<String> issuesBack,
    File? photoLeft,
    File? photoRight,
    File? photoFront,
    File? photoBack,
    bool submitting,
    bool submitted,
    String? error,
  }) = InspectionReady;
  const factory InspectionState.failure(String error) = InspectionFailure;

  @override
  List<Object?> get props => [];
}

class InspectionLoading extends InspectionState {
  const InspectionLoading();

  @override
  List<Object?> get props => [];
}

class InspectionFailure extends InspectionState {
  const InspectionFailure(this.error);
  final String error;

  @override
  List<Object?> get props => [error];
}

class InspectionReady extends InspectionState {
  const InspectionReady({
    required this.arrival,
    required this.hasExistingInspection,
    required this.notes,
    required this.issuesLeft,
    required this.issuesRight,
    required this.issuesFront,
    required this.issuesBack,
    this.photoLeft,
    this.photoRight,
    this.photoFront,
    this.photoBack,
    this.submitting = false,
    this.submitted = false,
    this.error,
  });

  final ArrivalInfo arrival;
  final bool hasExistingInspection;
  final String notes;
  final List<String> issuesLeft;
  final List<String> issuesRight;
  final List<String> issuesFront;
  final List<String> issuesBack;
  final File? photoLeft;
  final File? photoRight;
  final File? photoFront;
  final File? photoBack;
  final bool submitting;
  final bool submitted;
  final String? error;

  InspectionReady copyWith({
    String? notes,
    List<String>? issuesLeft,
    List<String>? issuesRight,
    List<String>? issuesFront,
    List<String>? issuesBack,
    File? photoLeft,
    File? photoRight,
    File? photoFront,
    File? photoBack,
    bool? submitting,
    bool? submitted,
    String? error,
  }) {
    return InspectionReady(
      arrival: arrival,
      hasExistingInspection: hasExistingInspection,
      notes: notes ?? this.notes,
      issuesLeft: issuesLeft ?? this.issuesLeft,
      issuesRight: issuesRight ?? this.issuesRight,
      issuesFront: issuesFront ?? this.issuesFront,
      issuesBack: issuesBack ?? this.issuesBack,
      photoLeft: photoLeft ?? this.photoLeft,
      photoRight: photoRight ?? this.photoRight,
      photoFront: photoFront ?? this.photoFront,
      photoBack: photoBack ?? this.photoBack,
      submitting: submitting ?? this.submitting,
      submitted: submitted ?? this.submitted,
      error: error,
    );
  }

  InspectionReady copyWithPhoto(InspectionSide side, File photo) {
    return switch (side) {
      InspectionSide.left => copyWith(photoLeft: photo),
      InspectionSide.right => copyWith(photoRight: photo),
      InspectionSide.front => copyWith(photoFront: photo),
      InspectionSide.back => copyWith(photoBack: photo),
    };
  }

  InspectionReady toggleIssue(InspectionSide side, String issue) {
    List<String> toggle(List<String> issues) {
      final set = issues.toSet();
      if (set.contains(issue)) {
        set.remove(issue);
      } else {
        set.add(issue);
      }
      return set.toList()..sort();
    }

    return switch (side) {
      InspectionSide.left => copyWith(issuesLeft: toggle(issuesLeft)),
      InspectionSide.right => copyWith(issuesRight: toggle(issuesRight)),
      InspectionSide.front => copyWith(issuesFront: toggle(issuesFront)),
      InspectionSide.back => copyWith(issuesBack: toggle(issuesBack)),
    };
  }

  @override
  List<Object?> get props => [
        arrival,
        hasExistingInspection,
        notes,
        issuesLeft,
        issuesRight,
        issuesFront,
        issuesBack,
        photoLeft?.path,
        photoRight?.path,
        photoFront?.path,
        photoBack?.path,
        submitting,
        submitted,
        error,
      ];
}

