import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/api/api_client.dart';
import '../cubit/inspection_cubit.dart';
import '../data/inspection_repository.dart';

const List<String> kIssueOptions = [
  'rusak',
  'karat',
  'bolong',
  'penyok',
  'bocor',
  'cat_terkelupas',
];

class InspectionPage extends StatelessWidget {
  const InspectionPage({super.key, required this.arrivalId});
  final int arrivalId;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => InspectionRepository(apiClient: context.read<ApiClient>()),
      child: BlocProvider(
        create: (context) => InspectionCubit(
          repository: context.read<InspectionRepository>(),
          arrivalId: arrivalId,
        )..load(),
        child: const _InspectionView(),
      ),
    );
  }
}

class _InspectionView extends StatefulWidget {
  const _InspectionView();

  @override
  State<_InspectionView> createState() => _InspectionViewState();
}

class _InspectionViewState extends State<_InspectionView> {
  final _notesController = TextEditingController();
  bool _didInitNotes = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto(InspectionSide side) async {
    final cubit = context.read<InspectionCubit>();
    final picker = ImagePicker();
    final xfile = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (!mounted || xfile == null) return;
    cubit.setPhoto(side, File(xfile.path));
  }

  String _issueLabel(String key) {
    return key.replaceAll('_', ' ');
  }

  String _sideLabel(InspectionSide side) {
    return switch (side) {
      InspectionSide.left => 'Kiri (Left)',
      InspectionSide.right => 'Kanan (Right)',
      InspectionSide.front => 'Depan (Front)',
      InspectionSide.back => 'Belakang (Back)',
    };
  }

  Widget _sideCard({
    required BuildContext context,
    required InspectionSide side,
    required File? photo,
    required List<String> selectedIssues,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _sideLabel(side),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => _takePhoto(side),
              child: Ink(
                height: 160,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: photo == null
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.photo_camera_rounded, color: Color(0xFF2563EB), size: 28),
                            SizedBox(height: 8),
                            Text('Tap untuk ambil foto', style: TextStyle(color: Color(0xFF475569))),
                          ],
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(photo, width: double.infinity, fit: BoxFit.cover),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: kIssueOptions.map((opt) {
                final selected = selectedIssues.contains(opt);
                return FilterChip(
                  label: Text(
                    _issueLabel(opt),
                    style: TextStyle(
                      color: selected ? Colors.white : const Color(0xFF334155),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  selected: selected,
                  showCheckmark: false,
                  backgroundColor: Colors.white,
                  selectedColor: const Color(0xFF2563EB),
                  side: BorderSide(color: selected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0)),
                  onSelected: (_) => context.read<InspectionCubit>().toggleIssue(side, opt),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InspectionCubit, InspectionState>(
      listenWhen: (prev, next) => prev is InspectionReady && next is InspectionReady && prev.submitted != next.submitted,
      listener: (context, state) {
        if (state is InspectionReady && state.submitted) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        if (state is InspectionLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (state is InspectionFailure) {
          return Scaffold(
            appBar: AppBar(title: const Text('Inspection')),
            body: Center(child: Text(state.error)),
          );
        }
        final s = state as InspectionReady;
        final title = '${s.arrival.invoiceNo} • ${s.arrival.arrivalNo}';

        if (!_didInitNotes) {
          _notesController.text = s.notes;
          _didInitNotes = true;
        }

        return Scaffold(
          appBar: AppBar(title: Text(title)),
          body: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                children: [
                  if (s.error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1F2),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: Text(s.error!, style: const TextStyle(color: Color(0xFFB91C1C))),
                    ),
                  if (s.error != null) const SizedBox(height: 12),
                  _sideCard(context: context, side: InspectionSide.left, photo: s.photoLeft, selectedIssues: s.issuesLeft),
                  const SizedBox(height: 12),
                  _sideCard(context: context, side: InspectionSide.right, photo: s.photoRight, selectedIssues: s.issuesRight),
                  const SizedBox(height: 12),
                  _sideCard(context: context, side: InspectionSide.front, photo: s.photoFront, selectedIssues: s.issuesFront),
                  const SizedBox(height: 12),
                  _sideCard(context: context, side: InspectionSide.back, photo: s.photoBack, selectedIssues: s.issuesBack),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: TextField(
                        controller: _notesController,
                        onChanged: context.read<InspectionCubit>().setNotes,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Catatan',
                          hintText: 'Contoh: terdapat karat pada sisi kanan',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  top: false,
                  minimum: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  child: FilledButton.icon(
                    onPressed: s.submitting ? null : () => context.read<InspectionCubit>().submit(),
                    icon: s.submitting
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.send_rounded),
                    label: Text(s.submitting ? 'Menyimpan...' : (s.hasExistingInspection ? 'Update' : 'Submit')),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
