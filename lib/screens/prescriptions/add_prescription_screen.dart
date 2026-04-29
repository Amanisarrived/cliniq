import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/prescription_model.dart';
import '../../providers/prescription_provider.dart';
import '../../providers/user_provider.dart';

class AddPrescriptionScreen extends StatefulWidget {
  const AddPrescriptionScreen({super.key});

  @override
  State<AddPrescriptionScreen> createState() => _AddPrescriptionScreenState();
}

class _AddPrescriptionScreenState extends State<AddPrescriptionScreen> {
  final _doctorController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _notesController = TextEditingController();
  final _tagController = TextEditingController();

  final List<File> _imageFiles = [];
  final List<String> _tags = [];
  DateTime _selectedDate = DateTime.now();
  bool _isScanning = false;
  AiExtracted? _aiExtracted;

  final _picker = ImagePicker();

  @override
  void dispose() {
    _doctorController.dispose();
    _hospitalController.dispose();
    _diagnosisController.dispose();
    _notesController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  // ─── Image Picker ─────────────────────────────────────────────

  Future<void> _pickImage(ImageSource source) async {
    final isPro = context.read<UserProvider>().user?.isPro ?? false;
    final maxImages = isPro ? 5 : 1;

    if (_imageFiles.length >= maxImages) {
      _showSnack(isPro
          ? 'Maximum 5 images allowed'
          : 'Free plan allows only 1 photo. Upgrade to Pro for more!');
      return;
    }

    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (picked == null) return;
    final file = File(picked.path);

    setState(() => _imageFiles.add(file));

    // Auto OCR on first image
    if (_imageFiles.length == 1) {
      await _runOcr(file);
    }
  }

  Future<void> _runOcr(File file) async {
    setState(() => _isScanning = true);
    final result =
        await context.read<PrescriptionProvider>().scanPrescription(file);
    if (!mounted) return;
    setState(() {
      _aiExtracted = result;
      _isScanning = false;
    });

    if (result != null && result.medicines.isNotEmpty) {
      _showSnack('AI Detected ${result.medicines.length} medicines!');
    }
  }

  void _showImageOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor:
          isDark ? CliniqTheme.darkSurface : CliniqTheme.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color:
                    isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            _SheetOption(
              icon: Iconsax.camera,
              label: 'Take a photo',
              isDark: isDark,
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            const SizedBox(height: 12),
            _SheetOption(
              icon: Iconsax.gallery,
              label: 'Choose from gallery',
              isDark: isDark,
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ─── Date Picker ──────────────────────────────────────────────

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // ─── Tags ─────────────────────────────────────────────────────

  void _addTag(String tag) {
    final trimmed = tag.trim();
    if (trimmed.isEmpty || _tags.contains(trimmed) || _tags.length >= 5) return;
    setState(() {
      _tags.add(trimmed);
      _tagController.clear();
    });
  }

  void _removeTag(String tag) => setState(() => _tags.remove(tag));

  // ─── Save ─────────────────────────────────────────────────────

  Future<void> _save() async {
    final uid = context.read<UserProvider>().user?.uid ?? '';
    final isPro = context.read<UserProvider>().user?.isPro ?? false;

    final prescription = PrescriptionModel(
      doctorName: _doctorController.text.trim(),
      hospitalName: _hospitalController.text.trim(),
      diagnosis: _diagnosisController.text.trim(),
      notes: _notesController.text.trim(),
      tags: _tags,
      imageUrls: [],
      date: _selectedDate,
      aiExtracted: _aiExtracted,
      createdAt: DateTime.now(),
    );

    final success = await context.read<PrescriptionProvider>().addPrescription(
          uid: uid,
          isPro: isPro,
          prescription: prescription,
          imageFiles: _imageFiles,
        );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      _showSnack('Prescription saved! ✅');
    } else {
      final error = context.read<PrescriptionProvider>().error;
      _showSnack(error ?? 'Something went wrong, please try again');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ─── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<PrescriptionProvider>();

    return Scaffold(
      backgroundColor: isDark ? CliniqTheme.darkBg : CliniqTheme.lightBg,
      appBar: AppBar(
        backgroundColor: isDark ? CliniqTheme.darkBg : CliniqTheme.lightBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Iconsax.arrow_left,
            color: isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Nai Prescription',
          style: TextStyle(
            color: isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: provider.isUploading ? null : _save,
            child: provider.isUploading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Save',
                    style: TextStyle(
                      color: isDark
                          ? CliniqTheme.darkPrimary
                          : CliniqTheme.lightPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photos
            _SectionLabel(label: 'Photos', isDark: isDark),
            const SizedBox(height: 10),
            _ImagePickerRow(
              images: _imageFiles,
              isDark: isDark,
              isScanning: _isScanning,
              onAdd: _showImageOptions,
              onRemove: (i) => setState(() => _imageFiles.removeAt(i)),
            ),

            // AI Result
            if (_aiExtracted != null && _aiExtracted!.medicines.isNotEmpty) ...[
              const SizedBox(height: 16),
              _AiResultCard(aiExtracted: _aiExtracted!, isDark: isDark),
            ],

            const SizedBox(height: 20),

            // Doctor Name
            _SectionLabel(label: 'Doctor ka naam', isDark: isDark),
            const SizedBox(height: 8),
            _InputField(
              controller: _doctorController,
              hint: 'Dr. Sharma',
              icon: Iconsax.user,
              isDark: isDark,
            ),

            const SizedBox(height: 16),

            // Hospital
            _SectionLabel(label: 'Hospital / Clinic', isDark: isDark),
            const SizedBox(height: 8),
            _InputField(
              controller: _hospitalController,
              hint: 'AIIMS, Apollo...',
              icon: Iconsax.hospital,
              isDark: isDark,
            ),

            const SizedBox(height: 16),

            // Date
            _SectionLabel(label: 'Prescription ki date', isDark: isDark),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark
                      ? CliniqTheme.darkSurface
                      : CliniqTheme.lightSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? CliniqTheme.darkBorder
                        : CliniqTheme.lightBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Iconsax.calendar,
                      size: 18,
                      color: isDark
                          ? CliniqTheme.darkTextMuted
                          : CliniqTheme.lightTextMuted,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      DateFormat('dd MMMM yyyy').format(_selectedDate),
                      style: TextStyle(
                        color: isDark
                            ? CliniqTheme.darkText
                            : CliniqTheme.lightText,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Diagnosis
            _SectionLabel(
                label: 'Bimari / Diagnosis (optional)', isDark: isDark),
            const SizedBox(height: 8),
            _InputField(
              controller: _diagnosisController,
              hint: 'Fever, BP, Thyroid...',
              icon: Iconsax.health,
              isDark: isDark,
            ),

            const SizedBox(height: 16),

            // Tags
            _SectionLabel(label: 'Tags (optional)', isDark: isDark),
            const SizedBox(height: 8),
            _TagInput(
              controller: _tagController,
              tags: _tags,
              isDark: isDark,
              onAdd: _addTag,
              onRemove: _removeTag,
            ),

            const SizedBox(height: 16),

            // Notes
            _SectionLabel(label: 'Notes (optional)', isDark: isDark),
            const SizedBox(height: 8),
            _InputField(
              controller: _notesController,
              hint: 'Any important information...',
              icon: Iconsax.note,
              isDark: isDark,
              maxLines: 3,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─── Section Label ────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// ─── Input Field ──────────────────────────────────────────────────

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isDark;
  final int maxLines;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.isDark,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? CliniqTheme.darkSurface : CliniqTheme.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder,
        ),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(
          color: isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color:
                isDark ? CliniqTheme.darkTextMuted : CliniqTheme.lightTextMuted,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            size: 18,
            color:
                isDark ? CliniqTheme.darkTextMuted : CliniqTheme.lightTextMuted,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }
}

// ─── Image Picker Row ─────────────────────────────────────────────

class _ImagePickerRow extends StatelessWidget {
  final List<File> images;
  final bool isDark;
  final bool isScanning;
  final VoidCallback onAdd;
  final Function(int) onRemove;

  const _ImagePickerRow({
    required this.images,
    required this.isDark,
    required this.isScanning,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Add button
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 80,
              height: 90,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color:
                    isDark ? CliniqTheme.darkSurface : CliniqTheme.lightSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.camera,
                    size: 22,
                    color: isDark
                        ? CliniqTheme.darkPrimary
                        : CliniqTheme.lightPrimary,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add',
                    style: TextStyle(
                      color: isDark
                          ? CliniqTheme.darkPrimary
                          : CliniqTheme.lightPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Image thumbnails
          ...images.asMap().entries.map((entry) {
            final i = entry.key;
            final file = entry.value;
            return Stack(
              children: [
                Container(
                  width: 80,
                  height: 90,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: FileImage(file),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: i == 0 && isScanning
                      ? Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(120),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Scanning...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : null,
                ),
                Positioned(
                  top: 4,
                  right: 14,
                  child: GestureDetector(
                    onTap: () => onRemove(i),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ─── AI Result Card ───────────────────────────────────────────────

class _AiResultCard extends StatelessWidget {
  final AiExtracted aiExtracted;
  final bool isDark;

  const _AiResultCard({required this.aiExtracted, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CliniqTheme.success.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CliniqTheme.success.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Iconsax.magic_star, size: 14, color: CliniqTheme.success),
              SizedBox(width: 6),
              Text(
                'AI Detected',
                style: TextStyle(
                  color: CliniqTheme.success,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...aiExtracted.medicines.take(5).map(
                (m) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: CliniqTheme.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          m,
                          style: TextStyle(
                            color: isDark
                                ? CliniqTheme.darkText
                                : CliniqTheme.lightText,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: 6),
          Text(
            '⚠️ Extracted by AI, please verify with your doctor',
            style: TextStyle(
              color: isDark
                  ? CliniqTheme.darkTextMuted
                  : CliniqTheme.lightTextMuted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tag Input ────────────────────────────────────────────────────

class _TagInput extends StatelessWidget {
  final TextEditingController controller;
  final List<String> tags;
  final bool isDark;
  final Function(String) onAdd;
  final Function(String) onRemove;

  const _TagInput({
    required this.controller,
    required this.tags,
    required this.isDark,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Input
        Container(
          decoration: BoxDecoration(
            color: isDark ? CliniqTheme.darkSurface : CliniqTheme.lightSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder,
            ),
          ),
          child: TextField(
            controller: controller,
            style: TextStyle(
              color: isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
              fontSize: 14,
            ),
            onSubmitted: onAdd,
            decoration: InputDecoration(
              hintText: 'Type a tag, press Enter (BP, Eye, Thyroid...)',
              hintStyle: TextStyle(
                color: isDark
                    ? CliniqTheme.darkTextMuted
                    : CliniqTheme.lightTextMuted,
                fontSize: 13,
              ),
              prefixIcon: Icon(
                Iconsax.tag,
                size: 18,
                color: isDark
                    ? CliniqTheme.darkTextMuted
                    : CliniqTheme.lightTextMuted,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  Iconsax.add,
                  size: 18,
                  color: isDark
                      ? CliniqTheme.darkPrimary
                      : CliniqTheme.lightPrimary,
                ),
                onPressed: () => onAdd(controller.text),
              ),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
        ),

        // Tags chips
        if (tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags
                .map(
                  (tag) => Chip(
                    label: Text(
                      tag,
                      style: TextStyle(
                        color: isDark
                            ? CliniqTheme.darkPrimary
                            : CliniqTheme.lightPrimary,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: isDark
                        ? CliniqTheme.darkPrimary.withAlpha(25)
                        : CliniqTheme.lightPrimary.withAlpha(15),
                    deleteIcon: Icon(
                      Icons.close,
                      size: 14,
                      color: isDark
                          ? CliniqTheme.darkPrimary
                          : CliniqTheme.lightPrimary,
                    ),
                    onDeleted: () => onRemove(tag),
                    side: BorderSide.none,
                    padding: EdgeInsets.zero,
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}

// ─── Sheet Option ─────────────────────────────────────────────────

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _SheetOption({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? CliniqTheme.darkSurface2 : CliniqTheme.lightSurface2,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color:
                  isDark ? CliniqTheme.darkPrimary : CliniqTheme.lightPrimary,
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                color: isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
