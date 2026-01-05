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
    required String? notes,
    required File? photoLeft,
    required File? photoRight,
    required File? photoFront,
    required File? photoBack,
    required File? photoInside,
    required List<String> issuesLeft,
    required List<String> issuesRight,
    required List<String> issuesFront,
    required List<String> issuesBack,
  }) async {
    await _api.postMultipart(
      '/api/containers/$containerId/inspection',
      fields: {
        'status': status,
        if (sealCode != null) 'seal_code': sealCode,
        if (notes != null) 'notes': notes,
      },
      listFields: {
        'issues_left': issuesLeft,
        'issues_right': issuesRight,
        'issues_front': issuesFront,
        'issues_back': issuesBack,
      },
      files: {
        'photo_left': photoLeft,
        'photo_right': photoRight,
        'photo_front': photoFront,
        'photo_back': photoBack,
        'photo_inside': photoInside,
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
    required this.notes,
    required this.issuesLeft,
    required this.issuesRight,
    required this.issuesFront,
    required this.issuesBack,
    required this.photoLeftUrl,
    required this.photoRightUrl,
    required this.photoFrontUrl,
    required this.photoBackUrl,
    required this.photoInsideUrl,
  });

  final String? sealCode;
  final String? notes;
  final List<String> issuesLeft;
  final List<String> issuesRight;
  final List<String> issuesFront;
  final List<String> issuesBack;
  final String? photoLeftUrl;
  final String? photoRightUrl;
  final String? photoFrontUrl;
  final String? photoBackUrl;
  final String? photoInsideUrl;

  factory Inspection.fromJson(Map<String, dynamic> json) {
    return Inspection(
      sealCode: json['seal_code'] as String?,
      notes: json['notes'] as String?,
      issuesLeft: ((json['issues_left'] as List?) ?? const []).cast<String>(),
      issuesRight: ((json['issues_right'] as List?) ?? const []).cast<String>(),
      issuesFront: ((json['issues_front'] as List?) ?? const []).cast<String>(),
      issuesBack: ((json['issues_back'] as List?) ?? const []).cast<String>(),
      photoLeftUrl: json['photo_left_url'] as String?,
      photoRightUrl: json['photo_right_url'] as String?,
      photoFrontUrl: json['photo_front_url'] as String?,
      photoBackUrl: json['photo_back_url'] as String?,
      photoInsideUrl: json['photo_inside_url'] as String?,
    );
  }
}
