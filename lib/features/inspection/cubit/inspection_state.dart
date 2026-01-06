part of 'inspection_cubit.dart';

sealed class InspectionState extends Equatable {
  const InspectionState();

  const factory InspectionState.loading() = InspectionLoading;
  const factory InspectionState.ready({
    required ArrivalInfo arrival,
    required ContainerInfo container,
    required bool hasExistingInspection,
    required String sealCode,
    required String driverName,
    required String notes,
    required bool notesAuto,
    required List<String> issuesLeft,
    required List<String> issuesRight,
    required List<String> issuesFront,
    required List<String> issuesBack,
    String? photoLeftUrl,
    String? photoRightUrl,
    String? photoFrontUrl,
    String? photoBackUrl,
    String? photoInsideUrl,
    String? photoSealUrl,
    String? photoDamageUrl,
    File? photoLeft,
    File? photoRight,
    File? photoFront,
    File? photoBack,
    File? photoInside,
    File? photoSeal,
    File? photoDamage,
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
    required this.container,
    required this.hasExistingInspection,
    required this.sealCode,
    required this.driverName,
    required this.notes,
    required this.notesAuto,
    required this.issuesLeft,
    required this.issuesRight,
    required this.issuesFront,
    required this.issuesBack,
    this.photoLeftUrl,
    this.photoRightUrl,
    this.photoFrontUrl,
    this.photoBackUrl,
    this.photoInsideUrl,
    this.photoSealUrl,
    this.photoDamageUrl,
    this.photoLeft,
    this.photoRight,
    this.photoFront,
    this.photoBack,
    this.photoInside,
    this.photoSeal,
    this.photoDamage,
    this.submitting = false,
    this.submitted = false,
    this.error,
  });

  final ArrivalInfo arrival;
  final ContainerInfo container;
  final bool hasExistingInspection;
  final String sealCode;
  final String driverName;
  final String notes;
  final bool notesAuto;
  final List<String> issuesLeft;
  final List<String> issuesRight;
  final List<String> issuesFront;
  final List<String> issuesBack;
  final String? photoLeftUrl;
  final String? photoRightUrl;
  final String? photoFrontUrl;
  final String? photoBackUrl;
  final String? photoInsideUrl;
  final String? photoSealUrl;
  final String? photoDamageUrl;
  final File? photoLeft;
  final File? photoRight;
  final File? photoFront;
  final File? photoBack;
  final File? photoInside;
  final File? photoSeal;
  final File? photoDamage;
  final bool submitting;
  final bool submitted;
  final String? error;

  InspectionReady copyWith({
    String? sealCode,
    String? driverName,
    String? notes,
    bool? notesAuto,
    List<String>? issuesLeft,
    List<String>? issuesRight,
    List<String>? issuesFront,
    List<String>? issuesBack,
    String? photoLeftUrl,
    String? photoRightUrl,
    String? photoFrontUrl,
    String? photoBackUrl,
    String? photoInsideUrl,
    String? photoSealUrl,
    String? photoDamageUrl,
    File? photoLeft,
    File? photoRight,
    File? photoFront,
    File? photoBack,
    File? photoInside,
    File? photoSeal,
    File? photoDamage,
    bool? submitting,
    bool? submitted,
    String? error,
  }) {
    return InspectionReady(
      arrival: arrival,
      container: container,
      hasExistingInspection: hasExistingInspection,
      sealCode: sealCode ?? this.sealCode,
      driverName: driverName ?? this.driverName,
      notes: notes ?? this.notes,
      notesAuto: notesAuto ?? this.notesAuto,
      issuesLeft: issuesLeft ?? this.issuesLeft,
      issuesRight: issuesRight ?? this.issuesRight,
      issuesFront: issuesFront ?? this.issuesFront,
      issuesBack: issuesBack ?? this.issuesBack,
      photoLeftUrl: photoLeftUrl ?? this.photoLeftUrl,
      photoRightUrl: photoRightUrl ?? this.photoRightUrl,
      photoFrontUrl: photoFrontUrl ?? this.photoFrontUrl,
      photoBackUrl: photoBackUrl ?? this.photoBackUrl,
      photoInsideUrl: photoInsideUrl ?? this.photoInsideUrl,
      photoSealUrl: photoSealUrl ?? this.photoSealUrl,
      photoDamageUrl: photoDamageUrl ?? this.photoDamageUrl,
      photoLeft: photoLeft ?? this.photoLeft,
      photoRight: photoRight ?? this.photoRight,
      photoFront: photoFront ?? this.photoFront,
      photoBack: photoBack ?? this.photoBack,
      photoInside: photoInside ?? this.photoInside,
      photoSeal: photoSeal ?? this.photoSeal,
      photoDamage: photoDamage ?? this.photoDamage,
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
      InspectionSide.inside => copyWith(photoInside: photo),
      InspectionSide.seal => copyWith(photoSeal: photo),
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
      InspectionSide.inside => this,
      InspectionSide.seal => this,
    };
  }

  @override
  List<Object?> get props => [
        arrival,
        container,
        hasExistingInspection,
        sealCode,
        driverName,
        notes,
        notesAuto,
        issuesLeft,
        issuesRight,
        issuesFront,
        issuesBack,
        photoLeftUrl,
        photoRightUrl,
        photoFrontUrl,
        photoBackUrl,
        photoInsideUrl,
        photoSealUrl,
        photoDamageUrl,
        photoLeft?.path,
        photoRight?.path,
        photoFront?.path,
        photoBack?.path,
        photoInside?.path,
        photoSeal?.path,
        photoDamage?.path,
        submitting,
        submitted,
        error,
      ];
}
