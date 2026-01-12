import 'dart:io';

import '../../../core/api/api_client.dart';

class InspectionRepository {
  InspectionRepository({required ApiClient apiClient}) : _api = apiClient;
  final ApiClient _api;

  Future<ContainerWithInspection> getContainer(int containerId) async {
    final res = await _api.getJson('/api/containers/$containerId/inspection');
    return ContainerWithInspection.fromJson(res);
  }

  Future<void> submit({
    required int containerId,
    required String status,
    required String? sealCode,
    required String? driverName,
    required String? notes,
    required File? photoLeft,
    required File? photoRight,
    required File? photoFront,
    required File? photoBack,
    required File? photoInside,
    required File? photoSeal,
    required File? photoDamage1,
    required File? photoDamage2,
    required File? photoDamage3,
    required List<String> issuesLeft,
    required List<String> issuesRight,
    required List<String> issuesFront,
    required List<String> issuesBack,
    required List<String> issuesInside,
    required List<String> issuesSeal,
  }) async {
    await _api.postMultipart(
      '/api/containers/$containerId/inspection',
      fields: {
        'status': status,
        if (sealCode != null) 'seal_code': sealCode,
        if (driverName != null) 'driver_name': driverName,
        if (notes != null) 'notes': notes,
      },
      listFields: {
        'issues_left': issuesLeft,
        'issues_right': issuesRight,
        'issues_front': issuesFront,
        'issues_back': issuesBack,
        'issues_inside': issuesInside,
        'issues_seal': issuesSeal,
      },
      files: {
        'photo_left': photoLeft,
        'photo_right': photoRight,
        'photo_front': photoFront,
        'photo_back': photoBack,
        'photo_inside': photoInside,
        'photo_seal': photoSeal,
        'photo_damage_1': photoDamage1,
        'photo_damage_2': photoDamage2,
        'photo_damage_3': photoDamage3,
      },
    );
  }
}

class ContainerWithInspection {
  ContainerWithInspection({required this.arrival, required this.container, required this.inspection});
  final ArrivalInfo arrival;
  final ContainerInfo container;
  final Inspection? inspection;

  factory ContainerWithInspection.fromJson(Map<String, dynamic> json) {
    return ContainerWithInspection(
      arrival: ArrivalInfo.fromJson(json['arrival'] as Map<String, dynamic>),
      container: ContainerInfo.fromJson(json['container'] as Map<String, dynamic>),
      inspection: json['inspection'] == null ? null : Inspection.fromJson(json['inspection'] as Map<String, dynamic>),
    );
  }
}

class ArrivalInfo {
  ArrivalInfo({
    required this.id,
    required this.invoiceNo,
    required this.arrivalNo,
    required this.containerNumbers,
    required this.sealCode,
  });
  final int id;
  final String invoiceNo;
  final String arrivalNo;
  final String? containerNumbers;
  final String? sealCode;

  factory ArrivalInfo.fromJson(Map<String, dynamic> json) {
    return ArrivalInfo(
      id: json['id'] as int,
      invoiceNo: (json['invoice_no'] as String?) ?? '-',
      arrivalNo: (json['arrival_no'] as String?) ?? '-',
      containerNumbers: json['container_numbers'] as String?,
      sealCode: json['seal_code'] as String?,
    );
  }
}

class ContainerInfo {
  ContainerInfo({required this.id, required this.containerNo, required this.sealCode});

  final int id;
  final String containerNo;
  final String? sealCode;

  factory ContainerInfo.fromJson(Map<String, dynamic> json) {
    return ContainerInfo(
      id: json['id'] as int,
      containerNo: (json['container_no'] as String?) ?? '-',
      sealCode: json['seal_code'] as String?,
    );
  }
}

class Inspection {
  Inspection({
    required this.sealCode,
    required this.driverName,
    required this.notes,
    required this.issuesLeft,
    required this.issuesRight,
    required this.issuesFront,
    required this.issuesBack,
    required this.issuesInside,
    required this.issuesSeal,
    required this.photoLeftUrl,
    required this.photoRightUrl,
    required this.photoFrontUrl,
    required this.photoBackUrl,
    required this.photoInsideUrl,
    required this.photoSealUrl,
    required this.photoDamage1Url,
    required this.photoDamage2Url,
    required this.photoDamage3Url,
  });

  final String? sealCode;
  final String? driverName;
  final String? notes;
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

  factory Inspection.fromJson(Map<String, dynamic> json) {
    return Inspection(
      sealCode: json['seal_code'] as String?,
      driverName: json['driver_name'] as String?,
      notes: json['notes'] as String?,
      issuesLeft: ((json['issues_left'] as List?) ?? const []).cast<String>(),
      issuesRight: ((json['issues_right'] as List?) ?? const []).cast<String>(),
      issuesFront: ((json['issues_front'] as List?) ?? const []).cast<String>(),
      issuesBack: ((json['issues_back'] as List?) ?? const []).cast<String>(),
      issuesInside: ((json['issues_inside'] as List?) ?? const []).cast<String>(),
      issuesSeal: ((json['issues_seal'] as List?) ?? const []).cast<String>(),
      photoLeftUrl: json['photo_left_url'] as String?,
      photoRightUrl: json['photo_right_url'] as String?,
      photoFrontUrl: json['photo_front_url'] as String?,
      photoBackUrl: json['photo_back_url'] as String?,
      photoInsideUrl: json['photo_inside_url'] as String?,
      photoSealUrl: json['photo_seal_url'] as String?,
      photoDamage1Url: (json['photo_damage_1_url'] as String?) ?? (json['photo_damage_url'] as String?),
      photoDamage2Url: json['photo_damage_2_url'] as String?,
      photoDamage3Url: json['photo_damage_3_url'] as String?,
    );
  }
}
