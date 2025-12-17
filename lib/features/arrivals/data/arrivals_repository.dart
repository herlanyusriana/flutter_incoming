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
}

class ArrivalSummary {
  ArrivalSummary({
    required this.id,
    required this.arrivalNo,
    required this.invoiceNo,
    required this.vendorName,
    required this.containerNumbers,
  });

  final int id;
  final String arrivalNo;
  final String invoiceNo;
  final String vendorName;
  final String? containerNumbers;

  factory ArrivalSummary.fromJson(Map<String, dynamic> json) {
    final vendor = (json['vendor'] as Map<String, dynamic>?) ?? const {};
    return ArrivalSummary(
      id: json['id'] as int,
      arrivalNo: (json['arrival_no'] as String?) ?? '-',
      invoiceNo: (json['invoice_no'] as String?) ?? '-',
      vendorName: (vendor['name'] as String?) ?? '-',
      containerNumbers: json['container_numbers'] as String?,
    );
  }
}

