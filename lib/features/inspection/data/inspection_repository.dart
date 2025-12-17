import 'dart:io';

import '../../../core/api/api_client.dart';

class InspectionRepository {
  InspectionRepository({required ApiClient apiClient}) : _api = apiClient;
  final ApiClient _api;

  Future<ArrivalWithInspection> getArrival(int arrivalId) async {
    final res = await _api.getJson('/api/arrivals/$arrivalId/inspection');
    return ArrivalWithInspection.fromJson(res);
  }

  Future<void> submit({
    required int arrivalId,
    required String status,
    required String? notes,
    required File? photoLeft,
    required File? photoRight,
    required File? photoFront,
    required File? photoBack,
    required List<String> issuesLeft,
    required List<String> issuesRight,
    required List<String> issuesFront,
    required List<String> issuesBack,
  }) async {
    await _api.postMultipart(
      '/api/arrivals/$arrivalId/inspection',
      fields: {
        'status': status,
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
      },
    );
  }
}

class ArrivalWithInspection {
  ArrivalWithInspection({required this.arrival, required this.inspection});
  final ArrivalInfo arrival;
  final Inspection? inspection;

  factory ArrivalWithInspection.fromJson(Map<String, dynamic> json) {
    return ArrivalWithInspection(
      arrival: ArrivalInfo.fromJson(json['arrival'] as Map<String, dynamic>),
      inspection: json['inspection'] == null ? null : Inspection.fromJson(json['inspection'] as Map<String, dynamic>),
    );
  }
}

class ArrivalInfo {
  ArrivalInfo({required this.id, required this.invoiceNo, required this.arrivalNo, required this.containerNumbers});
  final int id;
  final String invoiceNo;
  final String arrivalNo;
  final String? containerNumbers;

  factory ArrivalInfo.fromJson(Map<String, dynamic> json) {
    return ArrivalInfo(
      id: json['id'] as int,
      invoiceNo: (json['invoice_no'] as String?) ?? '-',
      arrivalNo: (json['arrival_no'] as String?) ?? '-',
      containerNumbers: json['container_numbers'] as String?,
    );
  }
}

class Inspection {
  Inspection({
    required this.notes,
    required this.issuesLeft,
    required this.issuesRight,
    required this.issuesFront,
    required this.issuesBack,
  });

  final String? notes;
  final List<String> issuesLeft;
  final List<String> issuesRight;
  final List<String> issuesFront;
  final List<String> issuesBack;

  factory Inspection.fromJson(Map<String, dynamic> json) {
    return Inspection(
      notes: json['notes'] as String?,
      issuesLeft: ((json['issues_left'] as List?) ?? const []).cast<String>(),
      issuesRight: ((json['issues_right'] as List?) ?? const []).cast<String>(),
      issuesFront: ((json['issues_front'] as List?) ?? const []).cast<String>(),
      issuesBack: ((json['issues_back'] as List?) ?? const []).cast<String>(),
    );
  }
}

