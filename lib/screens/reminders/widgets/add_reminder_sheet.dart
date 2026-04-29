import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../models/reminder_model.dart';
import '../../../providers/reminders_provider.dart';

class AddReminderSheet extends StatefulWidget {
  final bool isDark;

  const AddReminderSheet({super.key, required this.isDark});

  @override
  State<AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends State<AddReminderSheet> {
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isMorning = true;
  bool _isAfternoon = false;
  bool _isNight = false;

  String _morningTime = '08:00';
  String _afternoonTime = '14:00';
  String _nightTime = '21:00';

  DateTime _startDate = DateTime.now();
  DateTime? _endDate;

  String _familyMember = 'Self';
  bool _isSaving = false;
  String? _imagePath;
  final _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickTime(String slot) async {
    final parts = slot == 'morning'
        ? _morningTime.split(':')
        : slot == 'afternoon'
        ? _afternoonTime.split(':')
        : _nightTime.split(':');

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      ),
    );

    if (picked == null) return;

    final formatted =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';

    setState(() {
      if (slot == 'morning') _morningTime = formatted;
      if (slot == 'afternoon') _afternoonTime = formatted;
      if (slot == 'night') _nightTime = formatted;
    });
  }

  Future<void> _pickDate({bool isEnd = false}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isEnd
          ? (_endDate ?? DateTime.now().add(const Duration(days: 7)))
          : _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked == null) return;
    setState(() {
      if (isEnd) {
        _endDate = picked;
      } else {
        _startDate = picked;
      }
    });
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter medicine name'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!_isMorning && !_isAfternoon && !_isNight) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one time'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final reminder = ReminderModel(
      medicineName: _nameController.text.trim(),
      imagePath: _imagePath,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      isMorning: _isMorning,
      isAfternoon: _isAfternoon,
      isNight: _isNight,
      morningTime: _morningTime,
      afternoonTime: _afternoonTime,
      nightTime: _nightTime,
      startDate: _startDate,
      endDate: _endDate,
      familyMember: _familyMember,
      createdAt: DateTime.now(),
    );

    final success =
    await context.read<RemindersProvider>().addReminder(reminder);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.pop(context);
    }
  }

  Future<void> _pickImage() async {
    final isDark = widget.isDark;
    showModalBottomSheet(
      context: context,
      backgroundColor:
      isDark ? CliniqTheme.darkSurface : CliniqTheme.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt,
                  color: isDark
                      ? CliniqTheme.darkPrimary
                      : CliniqTheme.lightPrimary),
              title: Text('Camera',
                  style: TextStyle(
                      color: isDark
                          ? CliniqTheme.darkText
                          : CliniqTheme.lightText)),
              onTap: () async {
                Navigator.pop(context);
                final picked = await _picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 80,
                );
                if (picked != null) {
                  setState(() => _imagePath = picked.path);
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library,
                  color: isDark
                      ? CliniqTheme.darkPrimary
                      : CliniqTheme.lightPrimary),
              title: Text('Gallery',
                  style: TextStyle(
                      color: isDark
                          ? CliniqTheme.darkText
                          : CliniqTheme.lightText)),
              onTap: () async {
                Navigator.pop(context);
                final picked = await _picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 80,
                );
                if (picked != null) {
                  setState(() => _imagePath = picked.path);
                }
              },
            ),
            if (_imagePath != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Photo',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _imagePath = null);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 1.0,
      minChildSize: 0.5,
      maxChildSize: 1.0,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: widget.isDark
                ? CliniqTheme.darkSurface
                : CliniqTheme.lightSurface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Column(
            children: [
              // ─── Handle ───────────────────────────
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? CliniqTheme.darkBorder
                      : CliniqTheme.lightBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // ─── Header ───────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Text(
                      'Add Reminder',
                      style: TextStyle(
                        color: widget.isDark
                            ? CliniqTheme.darkText
                            : CliniqTheme.lightText,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.close_rounded,
                        color: widget.isDark
                            ? CliniqTheme.darkTextMuted
                            : CliniqTheme.lightTextMuted,
                      ),
                    ),
                  ],
                ),
              ),

              // ─── Scrollable Content ───────────────
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Medicine Photo
                      _Label('Medicine Photo (Optional)',
                          isDark: widget.isDark),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 100,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: widget.isDark
                                ? CliniqTheme.darkBg
                                : CliniqTheme.lightBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: widget.isDark
                                  ? CliniqTheme.darkBorder
                                  : CliniqTheme.lightBorder,
                              width: 0.5,
                            ),
                          ),
                          child: _imagePath != null
                              ? Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  File(_imagePath!),
                                  width: double.infinity,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 6,
                                right: 6,
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _imagePath = null),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                              : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 28,
                                color: widget.isDark
                                    ? CliniqTheme.darkPrimary
                                    : CliniqTheme.lightPrimary,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Add photo',
                                style: TextStyle(
                                  color: widget.isDark
                                      ? CliniqTheme.darkTextMuted
                                      : CliniqTheme.lightTextMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Medicine name
                      _Label('Medicine Name', isDark: widget.isDark),
                      const SizedBox(height: 8),
                      _TextField(
                        controller: _nameController,
                        hint: 'e.g. Paracetamol 500mg',
                        isDark: widget.isDark,
                      ),
                      const SizedBox(height: 16),

                      // Time selection
                      _Label('Reminder Times', isDark: widget.isDark),
                      const SizedBox(height: 8),
                      _TimeSlot(
                        label: 'Morning',
                        icon: Icons.wb_sunny_outlined,
                        time: _morningTime,
                        isSelected: _isMorning,
                        isDark: widget.isDark,
                        onToggle: () =>
                            setState(() => _isMorning = !_isMorning),
                        onTimeTap: () => _pickTime('morning'),
                      ),
                      const SizedBox(height: 8),
                      _TimeSlot(
                        label: 'Afternoon',
                        icon: Icons.wb_cloudy_outlined,
                        time: _afternoonTime,
                        isSelected: _isAfternoon,
                        isDark: widget.isDark,
                        onToggle: () =>
                            setState(() => _isAfternoon = !_isAfternoon),
                        onTimeTap: () => _pickTime('afternoon'),
                      ),
                      const SizedBox(height: 8),
                      _TimeSlot(
                        label: 'Night',
                        icon: Icons.nightlight_outlined,
                        time: _nightTime,
                        isSelected: _isNight,
                        isDark: widget.isDark,
                        onToggle: () => setState(() => _isNight = !_isNight),
                        onTimeTap: () => _pickTime('night'),
                      ),
                      const SizedBox(height: 16),

                      // Start date
                      _Label('Start Date', isDark: widget.isDark),
                      const SizedBox(height: 8),
                      _DatePicker(
                        date: _startDate,
                        isDark: widget.isDark,
                        onTap: () => _pickDate(),
                      ),
                      const SizedBox(height: 16),

                      // End date
                      _Label('End Date (Optional)', isDark: widget.isDark),
                      const SizedBox(height: 8),
                      _DatePicker(
                        date: _endDate,
                        isDark: widget.isDark,
                        hint: 'No end date',
                        onTap: () => _pickDate(isEnd: true),
                      ),
                      const SizedBox(height: 16),

                      // Family member
                      _Label('For', isDark: widget.isDark),
                      const SizedBox(height: 8),
                      _FamilySelector(
                        selected: _familyMember,
                        isDark: widget.isDark,
                        onChanged: (v) => setState(() => _familyMember = v),
                      ),
                      const SizedBox(height: 16),

                      // Notes
                      _Label('Notes (Optional)', isDark: widget.isDark),
                      const SizedBox(height: 8),
                      _TextField(
                        controller: _notesController,
                        hint: 'e.g. Take after meals',
                        isDark: widget.isDark,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 24),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.isDark
                                ? CliniqTheme.darkPrimary
                                : CliniqTheme.lightPrimary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : const Text(
                            'Set Reminder',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(
                        height: MediaQuery.of(context).viewInsets.bottom,
                      ),
                    ],
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

// ── Helper Widgets ────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  final bool isDark;

  const _Label(this.text, {required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: isDark ? CliniqTheme.darkTextMuted : CliniqTheme.lightTextMuted,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool isDark;
  final int maxLines;

  const _TextField({
    required this.controller,
    required this.hint,
    required this.isDark,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
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
        filled: true,
        fillColor: isDark ? CliniqTheme.darkBg : CliniqTheme.lightBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder,
            width: 0.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder,
            width: 0.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? CliniqTheme.darkPrimary : CliniqTheme.lightPrimary,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }
}

class _TimeSlot extends StatelessWidget {
  final String label;
  final IconData icon;
  final String time;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onToggle;
  final VoidCallback onTimeTap;

  const _TimeSlot({
    required this.label,
    required this.icon,
    required this.time,
    required this.isSelected,
    required this.isDark,
    required this.onToggle,
    required this.onTimeTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark
            ? CliniqTheme.darkPrimary.withAlpha(20)
            : CliniqTheme.lightPrimary.withAlpha(10))
            : (isDark ? CliniqTheme.darkBg : CliniqTheme.lightBg),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? (isDark
              ? CliniqTheme.darkPrimary.withAlpha(100)
              : CliniqTheme.lightPrimary.withAlpha(80))
              : (isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder),
          width: isSelected ? 1 : 0.5,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark
                        ? CliniqTheme.darkPrimary
                        : CliniqTheme.lightPrimary)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected
                          ? (isDark
                          ? CliniqTheme.darkPrimary
                          : CliniqTheme.lightPrimary)
                          : (isDark
                          ? CliniqTheme.darkBorder
                          : CliniqTheme.lightBorder),
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                    Icons.check_rounded,
                    size: 12,
                    color: Colors.white,
                  )
                      : null,
                ),
                const SizedBox(width: 10),
                Icon(
                  icon,
                  size: 16,
                  color: isSelected
                      ? (isDark
                      ? CliniqTheme.darkPrimary
                      : CliniqTheme.lightPrimary)
                      : (isDark
                      ? CliniqTheme.darkTextMuted
                      : CliniqTheme.lightTextMuted),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? (isDark
                        ? CliniqTheme.darkText
                        : CliniqTheme.lightText)
                        : (isDark
                        ? CliniqTheme.darkTextMuted
                        : CliniqTheme.lightTextMuted),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: isSelected ? onTimeTap : null,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark
                    ? CliniqTheme.darkPrimary.withAlpha(30)
                    : CliniqTheme.lightPrimary.withAlpha(20))
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                time,
                style: TextStyle(
                  color: isSelected
                      ? (isDark
                      ? CliniqTheme.darkPrimary
                      : CliniqTheme.lightPrimary)
                      : (isDark
                      ? CliniqTheme.darkBorder
                      : CliniqTheme.lightBorder),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DatePicker extends StatelessWidget {
  final DateTime? date;
  final bool isDark;
  final String? hint;
  final VoidCallback onTap;

  const _DatePicker({
    required this.date,
    required this.isDark,
    this.hint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? CliniqTheme.darkBg : CliniqTheme.lightBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color:
              isDark ? CliniqTheme.darkPrimary : CliniqTheme.lightPrimary,
            ),
            const SizedBox(width: 10),
            Text(
              date != null
                  ? '${date!.day}/${date!.month}/${date!.year}'
                  : (hint ?? 'Select date'),
              style: TextStyle(
                color: date != null
                    ? (isDark ? CliniqTheme.darkText : CliniqTheme.lightText)
                    : (isDark
                    ? CliniqTheme.darkTextMuted
                    : CliniqTheme.lightTextMuted),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FamilySelector extends StatelessWidget {
  final String selected;
  final bool isDark;
  final ValueChanged<String> onChanged;

  const _FamilySelector({
    required this.selected,
    required this.isDark,
    required this.onChanged,
  });

  static const List<String> _members = [
    'Self',
    'Spouse',
    'Mother',
    'Father',
    'Child',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _members.map((member) {
        final isSelected = selected == member;
        return GestureDetector(
          onTap: () => onChanged(member),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark
                  ? CliniqTheme.darkPrimary
                  : CliniqTheme.lightPrimary)
                  : (isDark ? CliniqTheme.darkBg : CliniqTheme.lightBg),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? (isDark
                    ? CliniqTheme.darkPrimary
                    : CliniqTheme.lightPrimary)
                    : (isDark
                    ? CliniqTheme.darkBorder
                    : CliniqTheme.lightBorder),
                width: isSelected ? 1 : 0.5,
              ),
            ),
            child: Text(
              member,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDark
                    ? CliniqTheme.darkTextMuted
                    : CliniqTheme.lightTextMuted),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}