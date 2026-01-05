import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/api_client.dart';
import '../../inspection/ui/inspection_page.dart';
import '../data/arrivals_repository.dart';

class ArrivalContainersPage extends StatefulWidget {
  const ArrivalContainersPage({super.key, required this.arrivalId, required this.invoiceNo});

  final int arrivalId;
  final String invoiceNo;

  @override
  State<ArrivalContainersPage> createState() => _ArrivalContainersPageState();
}

class _ArrivalContainersPageState extends State<ArrivalContainersPage> {
  late final ArrivalsRepository _repo;
  bool _loading = true;
  String? _error;
  ArrivalDetail? _arrival;

  @override
  void initState() {
    super.initState();
    _repo = ArrivalsRepository(apiClient: context.read<ApiClient>());
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final detail = await _repo.arrivalContainers(widget.arrivalId);
      setState(() {
        _arrival = detail;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = _arrival;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.invoiceNo),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_error != null
              ? Center(child: Text(_error!))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    children: [
                      if (a != null) ...[
                        Text(
                          a.vendorName,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Arrival: ${a.arrivalNo}',
                          style: const TextStyle(color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 12),
                      ],
                      ...(a?.containers ?? const []).map((c) {
                        final statusColor = c.inspected ? const Color(0xFF16A34A) : const Color(0xFF2563EB);
                        final statusText = c.inspected ? 'DONE' : 'PENDING';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Card(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => InspectionPage(containerId: c.id)),
                                );
                                if (mounted) await _load();
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 44,
                                      width: 44,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(Icons.inventory_2_rounded, color: Color(0xFF2563EB)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  c.containerNo,
                                                  style: const TextStyle(fontWeight: FontWeight.w800),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: statusColor.withValues(alpha: 0.12),
                                                  borderRadius: BorderRadius.circular(999),
                                                ),
                                                child: Text(
                                                  statusText,
                                                  style: TextStyle(
                                                    color: statusColor,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w800,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Seal: ${c.sealCode ?? '-'}',
                                            style: const TextStyle(color: Color(0xFF64748B)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                      if ((a?.containers ?? const []).isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: Center(child: Text('Tidak ada container untuk invoice ini.')),
                        ),
                    ],
                  ),
                )),
    );
  }
}

