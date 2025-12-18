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
  final _sealCodeController = TextEditingController();
  final _notesController = TextEditingController();
  bool _didInitSealCode = false;
  bool _didInitNotes = false;
  InspectionSide _issueSide = InspectionSide.front;

  @override
  void dispose() {
    _sealCodeController.dispose();
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

  Widget _photoTile({
    required String label,
    required VoidCallback onTap,
    required File? localFile,
    required String? remoteUrl,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: localFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(localFile, width: double.infinity, fit: BoxFit.cover),
                    )
                  : (remoteUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(remoteUrl, width: double.infinity, fit: BoxFit.cover),
                        )
                      : const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.photo_camera_rounded, color: Color(0xFF2563EB), size: 26),
                              SizedBox(height: 8),
                              Text('Tap untuk ambil foto', style: TextStyle(color: Color(0xFF475569))),
                            ],
                          ),
                        )),
            ),
            Positioned(
              left: 10,
              top: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _issuesFor(InspectionReady s, InspectionSide side) {
    return switch (side) {
      InspectionSide.left => s.issuesLeft,
      InspectionSide.right => s.issuesRight,
      InspectionSide.front => s.issuesFront,
      InspectionSide.back => s.issuesBack,
      InspectionSide.inside => const [],
    };
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

        if (!_didInitSealCode) {
          _sealCodeController.text = s.sealCode;
          _didInitSealCode = true;
        }
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
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: TextField(
                        controller: _sealCodeController,
                        onChanged: context.read<InspectionCubit>().setSealCode,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          labelText: 'No. Seal',
                          hintText: 'Contoh: HUPH019101',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          const gap = 10.0;
                          final gridHeight = constraints.maxWidth * 0.72;

                          return SizedBox(
                            height: gridHeight,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 35,
                                  child: _photoTile(
                                    label: 'Foto Depan',
                                    onTap: () => _takePhoto(InspectionSide.front),
                                    localFile: s.photoFront,
                                    remoteUrl: s.photoFrontUrl,
                                  ),
                                ),
                                const SizedBox(width: gap),
                                Expanded(
                                  flex: 30,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: _photoTile(
                                          label: 'Kiri',
                                          onTap: () => _takePhoto(InspectionSide.left),
                                          localFile: s.photoLeft,
                                          remoteUrl: s.photoLeftUrl,
                                        ),
                                      ),
                                      const SizedBox(height: gap),
                                      Expanded(
                                        child: _photoTile(
                                          label: 'Kanan',
                                          onTap: () => _takePhoto(InspectionSide.right),
                                          localFile: s.photoRight,
                                          remoteUrl: s.photoRightUrl,
                                        ),
                                      ),
                                      const SizedBox(height: gap),
                                      Expanded(
                                        child: _photoTile(
                                          label: 'Dalam',
                                          onTap: () => _takePhoto(InspectionSide.inside),
                                          localFile: s.photoInside,
                                          remoteUrl: s.photoInsideUrl,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: gap),
                                Expanded(
                                  flex: 35,
                                  child: _photoTile(
                                    label: 'Belakang',
                                    onTap: () => _takePhoto(InspectionSide.back),
                                    localFile: s.photoBack,
                                    remoteUrl: s.photoBackUrl,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Checklist Kerusakan', style: TextStyle(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 10),
                          InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Sisi',
                              border: OutlineInputBorder(),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<InspectionSide>(
                                value: _issueSide,
                                isExpanded: true,
                                items: const [
                                  DropdownMenuItem(value: InspectionSide.front, child: Text('Depan (Front)')),
                                  DropdownMenuItem(value: InspectionSide.left, child: Text('Kiri (Left)')),
                                  DropdownMenuItem(value: InspectionSide.right, child: Text('Kanan (Right)')),
                                  DropdownMenuItem(value: InspectionSide.back, child: Text('Belakang (Back)')),
                                ],
                                onChanged: (v) => setState(() => _issueSide = v ?? InspectionSide.front),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: kIssueOptions.map((opt) {
                              final selected = _issuesFor(s, _issueSide).contains(opt);
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
                                onSelected: (_) => context.read<InspectionCubit>().toggleIssue(_issueSide, opt),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
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
