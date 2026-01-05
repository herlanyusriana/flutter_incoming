import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/api_client.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../ui/arrival_containers_page.dart';
import '../cubit/arrivals_cubit.dart';
import '../data/arrivals_repository.dart';

class ArrivalsPage extends StatelessWidget {
  const ArrivalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => ArrivalsRepository(apiClient: context.read<ApiClient>()),
      child: BlocProvider(
        create: (context) => ArrivalsCubit(repository: context.read<ArrivalsRepository>())..load(),
        child: const _ArrivalsView(),
      ),
    );
  }
}

class _ArrivalsView extends StatefulWidget {
  const _ArrivalsView();

  @override
  State<_ArrivalsView> createState() => _ArrivalsViewState();
}

class _ArrivalsViewState extends State<_ArrivalsView> {
  final _qController = TextEditingController();

  @override
  void dispose() {
    _qController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    await context.read<ArrivalsCubit>().load(q: _qController.text);
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.inbox_rounded, color: Color(0xFF2563EB)),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tidak ada pending inspection',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Kalau invoice sudah di-inspect lewat APK, item akan hilang dari list ini.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _qController,
              decoration: const InputDecoration(
                hintText: 'Cari invoice/arrival/container…',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onSubmitted: (_) => _search(),
            ),
          ),
          const SizedBox(width: 10),
          FilledButton(
            onPressed: _search,
            child: const Text('Cari'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Inspection'),
        actions: [
          IconButton(onPressed: () => context.read<AuthCubit>().logout(), icon: const Icon(Icons.logout_rounded)),
        ],
      ),
      body: Column(
        children: [
          _searchBar(),
          Expanded(
            child: BlocBuilder<ArrivalsCubit, ArrivalsState>(
              builder: (context, state) {
                if (state.status == ArrivalsStatus.loading || state.status == ArrivalsStatus.initial) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.status == ArrivalsStatus.failure) {
                  return Center(child: Text(state.error ?? 'Error'));
                }
                if (state.items.isEmpty) return _emptyState();

                return RefreshIndicator(
                  onRefresh: _search,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: state.items.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final a = state.items[i];
                      return Card(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => ArrivalContainersPage(arrivalId: a.id, invoiceNo: a.invoiceNo)),
                            );
                            if (context.mounted) await _search();
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
                                  child: const Icon(Icons.local_shipping_rounded, color: Color(0xFF2563EB)),
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
                                              a.invoiceNo,
                                              style: const TextStyle(fontWeight: FontWeight.w800),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEFF6FF),
                                              borderRadius: BorderRadius.circular(999),
                                            ),
                                            child: const Text(
                                              'PENDING',
                                              style: TextStyle(
                                                color: Color(0xFF2563EB),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${a.vendorName} • ${a.arrivalNo}',
                                        style: const TextStyle(color: Color(0xFF475569)),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Pending: ${a.pendingContainers} • Container: ${a.containerNumbers ?? '-'}',
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
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
