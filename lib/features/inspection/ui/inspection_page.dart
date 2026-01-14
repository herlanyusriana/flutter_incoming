import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/api/api_client.dart';
import '../../../core/utils/image_upload_compressor.dart';
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
  const InspectionPage({super.key, required this.containerId});
  final int containerId;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => InspectionRepository(apiClient: context.read<ApiClient>()),
      child: BlocProvider(
        create: (context) => InspectionCubit(
          repository: context.read<InspectionRepository>(),
          containerId: containerId,
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
  final _driverNameController = TextEditingController();
  final _notesController = TextEditingController();
  final _compressor = const ImageUploadCompressor();
  bool _didInitSealCode = false;
  bool _didInitDriverName = false;
  bool _didInitNotes = false;
  InspectionSide _issueSide = InspectionSide.front;

  @override
  void dispose() {
    _sealCodeController.dispose();
    _driverNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(InspectionSide side, ImageSource source) async {
    final cubit = context.read<InspectionCubit>();
    final picker = ImagePicker();
    final xfile = await picker.pickImage(
      source: source,
      imageQuality: 55,
      maxWidth: 1024,
      maxHeight: 1024,
      requestFullMetadata: false,
    );
    if (!mounted || xfile == null) return;
    final compressed = await _compressor.compress(
      File(xfile.path),
      maxDimension: 1024,
      quality: 55,
      maxBytes: 110 * 1024,
      minDimension: 720,
      minQuality: 35,
    );
    if (!mounted) return;
    await cubit.setPhoto(side, compressed);
  }

  Future<void> _pickDamagePhoto(int index, ImageSource source) async {
    final cubit = context.read<InspectionCubit>();
    final picker = ImagePicker();
    final xfile = await picker.pickImage(
      source: source,
      imageQuality: 55,
      maxWidth: 1024,
      maxHeight: 1024,
      requestFullMetadata: false,
    );
    if (!mounted || xfile == null) return;
    final compressed = await _compressor.compress(
      File(xfile.path),
      maxDimension: 1024,
      quality: 55,
      maxBytes: 110 * 1024,
      minDimension: 720,
      minQuality: 35,
    );
    if (!mounted) return;
    await cubit.setDamagePhoto(index, compressed);
  }

  Future<void> _showPickSourceSheet({
    required String title,
    required Future<void> Function() onCamera,
    required Future<void> Function() onGallery,
  }) async {
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.photo_camera_rounded),
                  title: const Text('Ambil dari Kamera'),
                  onTap: () async {
                    Navigator.pop(context);
                    await onCamera();
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.photo_library_rounded),
                  title: const Text('Ambil dari Album'),
                  onTap: () async {
                    Navigator.pop(context);
                    await onGallery();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _issueLabel(String key) {
    return key.replaceAll('_', ' ');
  }

  Widget _photoTile({
    required String label,
    required String orientationHint,
    required VoidCallback onTap,
    required File? localFile,
    required String? remoteUrl,
    VoidCallback? onClear,
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
            Positioned(
              right: 10,
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  orientationHint,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11),
                ),
              ),
            ),
            if (onClear != null && localFile != null)
              Positioned(
                right: 10,
                top: 10,
                child: InkResponse(
                  onTap: onClear,
                  radius: 20,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                  ),
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
      InspectionSide.inside => s.issuesInside,
      InspectionSide.seal => s.issuesSeal,
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
        final title = '${s.arrival.invoiceNo} • ${s.container.containerNo}';

        if (!_didInitSealCode) {
          _sealCodeController.text = s.sealCode;
          _didInitSealCode = true;
        }
        if (!_didInitDriverName) {
          _driverNameController.text = s.driverName;
          _didInitDriverName = true;
        }
        if (!_didInitNotes) {
          _notesController.text = s.notes;
          _didInitNotes = true;
        }
        if (s.notesAuto && _notesController.text != s.notes) {
          _notesController.text = s.notes;
        }

        return Scaffold(
          appBar: AppBar(title: Text(title)),
          body: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Invoice: ${s.arrival.invoiceNo}',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Arrival: ${s.arrival.arrivalNo}',
                            style: const TextStyle(color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Container: ${s.container.containerNo}',
                            style: const TextStyle(color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
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
                      padding: const EdgeInsets.all(14),
                      child: TextField(
                        controller: _driverNameController,
                        onChanged: context.read<InspectionCubit>().setDriverName,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Driver Name',
                          hintText: 'Nama driver untuk kolom tanda tangan',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 180,
                            child: _photoTile(
                              label: 'Foto Depan',
                              orientationHint: 'PORTRAIT',
                              onTap: () => _showPickSourceSheet(
                                title: 'Foto Depan',
                                onCamera: () => _pickPhoto(InspectionSide.front, ImageSource.camera),
                                onGallery: () => _pickPhoto(InspectionSide.front, ImageSource.gallery),
                              ),
                              localFile: s.photoFront,
                              remoteUrl: s.photoFrontUrl,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 180,
                            child: _photoTile(
                              label: 'Belakang',
                              orientationHint: 'PORTRAIT',
                              onTap: () => _showPickSourceSheet(
                                title: 'Foto Belakang',
                                onCamera: () => _pickPhoto(InspectionSide.back, ImageSource.camera),
                                onGallery: () => _pickPhoto(InspectionSide.back, ImageSource.gallery),
                              ),
                              localFile: s.photoBack,
                              remoteUrl: s.photoBackUrl,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 180,
                            child: _photoTile(
                              label: 'Kiri',
                              orientationHint: 'LANDSCAPE',
                              onTap: () => _showPickSourceSheet(
                                title: 'Foto Kiri',
                                onCamera: () => _pickPhoto(InspectionSide.left, ImageSource.camera),
                                onGallery: () => _pickPhoto(InspectionSide.left, ImageSource.gallery),
                              ),
                              localFile: s.photoLeft,
                              remoteUrl: s.photoLeftUrl,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 180,
                            child: _photoTile(
                              label: 'Kanan',
                              orientationHint: 'LANDSCAPE',
                              onTap: () => _showPickSourceSheet(
                                title: 'Foto Kanan',
                                onCamera: () => _pickPhoto(InspectionSide.right, ImageSource.camera),
                                onGallery: () => _pickPhoto(InspectionSide.right, ImageSource.gallery),
                              ),
                              localFile: s.photoRight,
                              remoteUrl: s.photoRightUrl,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 180,
                            child: _photoTile(
                              label: 'Dalam',
                              orientationHint: 'PORTRAIT',
                              onTap: () => _showPickSourceSheet(
                                title: 'Foto Dalam',
                                onCamera: () => _pickPhoto(InspectionSide.inside, ImageSource.camera),
                                onGallery: () => _pickPhoto(InspectionSide.inside, ImageSource.gallery),
                              ),
                              localFile: s.photoInside,
                              remoteUrl: s.photoInsideUrl,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 180,
                            child: _photoTile(
                              label: 'Foto Seal',
                              orientationHint: 'PORTRAIT',
                              onTap: () => _showPickSourceSheet(
                                title: 'Foto Seal',
                                onCamera: () => _pickPhoto(InspectionSide.seal, ImageSource.camera),
                                onGallery: () => _pickPhoto(InspectionSide.seal, ImageSource.gallery),
                              ),
                              localFile: s.photoSeal,
                              remoteUrl: s.photoSealUrl,
                            ),
                          ),
                        ],
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
                              labelText: 'Bagian',
                              border: OutlineInputBorder(),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<InspectionSide>(
                                value: _issueSide,
                                isExpanded: true,
                                items: const [
                                  DropdownMenuItem(value: InspectionSide.front, child: Text('Depan')),
                                  DropdownMenuItem(value: InspectionSide.back, child: Text('Belakang')),
                                  DropdownMenuItem(value: InspectionSide.left, child: Text('Kiri')),
                                  DropdownMenuItem(value: InspectionSide.right, child: Text('Kanan')),
                                  DropdownMenuItem(value: InspectionSide.inside, child: Text('Dalam')),
                                  DropdownMenuItem(value: InspectionSide.seal, child: Text('No. Seal')),
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
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 150,
                                  child: _photoTile(
                                    label: 'Detail #1 (Optional)',
                                    orientationHint: 'OPTIONAL',
                                    onTap: () => _showPickSourceSheet(
                                      title: 'Foto Detail Kerusakan #1',
                                      onCamera: () => _pickDamagePhoto(1, ImageSource.camera),
                                      onGallery: () => _pickDamagePhoto(1, ImageSource.gallery),
                                    ),
                                    localFile: s.photoDamage1,
                                    remoteUrl: s.photoDamage1Url,
                                    onClear: s.photoDamage1 != null ? () => context.read<InspectionCubit>().setDamagePhoto(1, null) : null,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: SizedBox(
                                  height: 150,
                                  child: _photoTile(
                                    label: 'Detail #2 (Optional)',
                                    orientationHint: 'OPTIONAL',
                                    onTap: () => _showPickSourceSheet(
                                      title: 'Foto Detail Kerusakan #2',
                                      onCamera: () => _pickDamagePhoto(2, ImageSource.camera),
                                      onGallery: () => _pickDamagePhoto(2, ImageSource.gallery),
                                    ),
                                    localFile: s.photoDamage2,
                                    remoteUrl: s.photoDamage2Url,
                                    onClear: s.photoDamage2 != null ? () => context.read<InspectionCubit>().setDamagePhoto(2, null) : null,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: SizedBox(
                                  height: 150,
                                  child: _photoTile(
                                    label: 'Detail #3 (Optional)',
                                    orientationHint: 'OPTIONAL',
                                    onTap: () => _showPickSourceSheet(
                                      title: 'Foto Detail Kerusakan #3',
                                      onCamera: () => _pickDamagePhoto(3, ImageSource.camera),
                                      onGallery: () => _pickDamagePhoto(3, ImageSource.gallery),
                                    ),
                                    localFile: s.photoDamage3,
                                    remoteUrl: s.photoDamage3Url,
                                    onClear: s.photoDamage3 != null ? () => context.read<InspectionCubit>().setDamagePhoto(3, null) : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
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
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () {
                                final cubit = context.read<InspectionCubit>();
                                cubit.applyAutoNotes();
                              },
                              icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                              label: const Text('Generate keterangan'),
                            ),
                          ),
                          TextField(
                            controller: _notesController,
                            onChanged: context.read<InspectionCubit>().setNotes,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Keterangan',
                              hintText: 'Otomatis dari checklist kerusakan (bisa diedit)',
                            ),
                          ),
                        ],
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
