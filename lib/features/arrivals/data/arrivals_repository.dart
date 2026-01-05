import '../../../core/api/api_client.dart';

class ArrivalsRepository {
  ArrivalsRepository({required ApiClient apiClient}) : _api = apiClient;
  final ApiClient _api;

  Future<List<ArrivalSummary>> pendingArrivals({String? q, int limit = 30}) async {
    final res = await _api.getJson('/api/arrivals/pending-inspection', query: {
      if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
      'limit': '$limit',
    });
    final data = (res['data'] as List).cast<Map<String, dynamic>>();
    return data.map(ArrivalSummary.fromJson).toList();
  }

  Future<ArrivalDetail> arrivalContainers(int arrivalId) async {
    final res = await _api.getJson('/api/arrivals/$arrivalId/containers');
    return ArrivalDetail.fromJson(res['arrival'] as Map<String, dynamic>);
  }
}

class ArrivalSummary {
  ArrivalSummary({
    required this.id,
    required this.arrivalNo,
    required this.invoiceNo,
    required this.vendorName,
    required this.containerNumbers,
    required this.pendingContainers,
  });

  final int id;
  final String arrivalNo;
  final String invoiceNo;
  final String vendorName;
  final String? containerNumbers;
  final int pendingContainers;

  factory ArrivalSummary.fromJson(Map<String, dynamic> json) {
    final vendor = (json['vendor'] as Map<String, dynamic>?) ?? const {};
    final containers = ((json['containers'] as List?) ?? const []).cast<Map<String, dynamic>>();
    final pending = containers.where((c) => (c['inspected'] as bool?) != true).length;
    return ArrivalSummary(
      id: json['id'] as int,
      arrivalNo: (json['arrival_no'] as String?) ?? '-',
      invoiceNo: (json['invoice_no'] as String?) ?? '-',
      vendorName: (vendor['name'] as String?) ?? '-',
      containerNumbers: json['container_numbers'] as String?,
      pendingContainers: pending,
    );
  }
}

class ArrivalDetail {
  ArrivalDetail({
    required this.id,
    required this.arrivalNo,
    required this.invoiceNo,
    required this.vendorName,
    required this.containers,
  });

  final int id;
  final String arrivalNo;
  final String invoiceNo;
  final String vendorName;
  final List<ContainerSummary> containers;

  factory ArrivalDetail.fromJson(Map<String, dynamic> json) {
    final vendor = (json['vendor'] as Map<String, dynamic>?) ?? const {};
    final containers = ((json['containers'] as List?) ?? const []).cast<Map<String, dynamic>>();
    return ArrivalDetail(
      id: json['id'] as int,
      arrivalNo: (json['arrival_no'] as String?) ?? '-',
      invoiceNo: (json['invoice_no'] as String?) ?? '-',
      vendorName: (vendor['name'] as String?) ?? '-',
      containers: containers.map(ContainerSummary.fromJson).toList(),
    );
  }
}

class ContainerSummary {
  ContainerSummary({
    required this.id,
    required this.containerNo,
    required this.sealCode,
    required this.inspected,
  });

  final int id;
  final String containerNo;
  final String? sealCode;
  final bool inspected;

  factory ContainerSummary.fromJson(Map<String, dynamic> json) {
    return ContainerSummary(
      id: json['id'] as int,
      containerNo: (json['container_no'] as String?) ?? '-',
      sealCode: json['seal_code'] as String?,
      inspected: (json['inspected'] as bool?) ?? false,
    );
  }
}
