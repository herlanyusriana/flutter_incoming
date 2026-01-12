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
    required List<String> issuesInside,
    required List<String> issuesSeal,
    String? photoLeftUrl,
    String? photoRightUrl,
    String? photoFrontUrl,
    String? photoBackUrl,
    String? photoInsideUrl,
    String? photoSealUrl,
    String? photoDamage1Url,
    String? photoDamage2Url,
    String? photoDamage3Url,
    File? photoLeft,
    File? photoRight,
    File? photoFront,
    File? photoBack,
    File? photoInside,
    File? photoSeal,
    File? photoDamage1,
    File? photoDamage2,
    File? photoDamage3,
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
    required this.issuesInside,
    required this.issuesSeal,
    this.photoLeftUrl,
    this.photoRightUrl,
    this.photoFrontUrl,
    this.photoBackUrl,
    this.photoInsideUrl,
    this.photoSealUrl,
    this.photoDamage1Url,
    this.photoDamage2Url,
    this.photoDamage3Url,
    this.photoLeft,
    this.photoRight,
    this.photoFront,
    this.photoBack,
    this.photoInside,
    this.photoSeal,
    this.photoDamage1,
    this.photoDamage2,
    this.photoDamage3,
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
  final List<String> issuesInside;
  final List<String> issuesSeal;
  final String? photoLeftUrl;
  final String? photoRightUrl;
  final String? photoFrontUrl;
  final String? photoBackUrl;
  final String? photoInsideUrl;
  final String? photoSealUrl;
  final String? photoDamage1Url;
  final String? photoDamage2Url;
  final String? photoDamage3Url;
  final File? photoLeft;
  final File? photoRight;
  final File? photoFront;
  final File? photoBack;
  final File? photoInside;
  final File? photoSeal;
  final File? photoDamage1;
  final File? photoDamage2;
  final File? photoDamage3;
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
    List<String>? issuesInside,
    List<String>? issuesSeal,
    String? photoLeftUrl,
    String? photoRightUrl,
    String? photoFrontUrl,
    String? photoBackUrl,
    String? photoInsideUrl,
    String? photoSealUrl,
    String? photoDamage1Url,
    String? photoDamage2Url,
    String? photoDamage3Url,
    File? photoLeft,
    File? photoRight,
    File? photoFront,
    File? photoBack,
    File? photoInside,
    File? photoSeal,
    File? photoDamage1,
    File? photoDamage2,
    File? photoDamage3,
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
      issuesInside: issuesInside ?? this.issuesInside,
      issuesSeal: issuesSeal ?? this.issuesSeal,
      photoLeftUrl: photoLeftUrl ?? this.photoLeftUrl,
      photoRightUrl: photoRightUrl ?? this.photoRightUrl,
      photoFrontUrl: photoFrontUrl ?? this.photoFrontUrl,
      photoBackUrl: photoBackUrl ?? this.photoBackUrl,
      photoInsideUrl: photoInsideUrl ?? this.photoInsideUrl,
      photoSealUrl: photoSealUrl ?? this.photoSealUrl,
      photoDamage1Url: photoDamage1Url ?? this.photoDamage1Url,
      photoDamage2Url: photoDamage2Url ?? this.photoDamage2Url,
      photoDamage3Url: photoDamage3Url ?? this.photoDamage3Url,
      photoLeft: photoLeft ?? this.photoLeft,
      photoRight: photoRight ?? this.photoRight,
      photoFront: photoFront ?? this.photoFront,
      photoBack: photoBack ?? this.photoBack,
      photoInside: photoInside ?? this.photoInside,
      photoSeal: photoSeal ?? this.photoSeal,
      photoDamage1: photoDamage1 ?? this.photoDamage1,
      photoDamage2: photoDamage2 ?? this.photoDamage2,
      photoDamage3: photoDamage3 ?? this.photoDamage3,
      submitting: submitting ?? this.submitting,
      submitted: submitted ?? this.submitted,
      error: error,
    );
  }

  InspectionReady copyWithDamagePhoto(int index, File? photo) {
    return switch (index) {
      1 => copyWith(photoDamage1: photo),
      2 => copyWith(photoDamage2: photo),
      3 => copyWith(photoDamage3: photo),
      _ => this,
    };
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
      InspectionSide.inside => copyWith(issuesInside: toggle(issuesInside)),
      InspectionSide.seal => copyWith(issuesSeal: toggle(issuesSeal)),
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
        issuesInside,
        issuesSeal,
        photoLeftUrl,
        photoRightUrl,
        photoFrontUrl,
        photoBackUrl,
        photoInsideUrl,
        photoSealUrl,
        photoDamage1Url,
        photoDamage2Url,
        photoDamage3Url,
        photoLeft?.path,
        photoRight?.path,
        photoFront?.path,
        photoBack?.path,
        photoInside?.path,
        photoSeal?.path,
        photoDamage1?.path,
        photoDamage2?.path,
        photoDamage3?.path,
        submitting,
        submitted,
        error,
      ];
}
