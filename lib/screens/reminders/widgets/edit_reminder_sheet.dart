import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../models/reminder_model.dart';
import '../../../providers/reminders_provider.dart';

class EditReminderSheet extends StatefulWidget {
  final ReminderModel reminder;
  final bool isDark;

  const EditReminderSheet({
    super.key,
    required this.reminder,
    required this.isDark,
  });

  @override
  State<EditReminderSheet> createState() => _EditReminderSheetState();
}

class _EditReminderSheetState extends State<EditReminderSheet> {
  late TextEditingController _nameController;
  late TextEditingController _notesController;

  late bool _isMorning;
  late bool _isAfternoon;
  late bool _isNight;
  late String _morningTime;
  late String _afternoonTime;
  late String _nightTime;
  late DateTime _startDate;
  DateTime? _endDate;
  late String _familyMember;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final r = widget.reminder;
    _nameController = TextEditingController(text: r.medicineName);
    _notesController = TextEditingController(text: r.notes ?? '');
    _isMorning = r.isMorning;
    _isAfternoon = r.isAfternoon;
    _isNight = r.isNight;
    _morningTime = r.morningTime;
    _afternoonTime = r.afternoonTime;
    _nightTime = r.nightTime;
    _startDate = r.startDate;
    _endDate = r.endDate;
    _familyMember = r.familyMember;
  }

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

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) return;
    if (!_isMorning && !_isAfternoon && !_isNight) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select at least one time'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final updated = widget.reminder.copyWith(
      medicineName: _nameController.text.trim(),
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
    );

    await context.read<RemindersProvider>().updateReminder(updated);

    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:
            widget.isDark ? CliniqTheme.darkSurface : CliniqTheme.lightSurface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
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

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Text(
                  'Edit Reminder',
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

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name field
                  _label('Medicine Name', isDark: widget.isDark),
                  const SizedBox(height: 8),
                  _textField(
                    controller: _nameController,
                    hint: 'e.g. Paracetamol 500mg',
                    isDark: widget.isDark,
                  ),

                  const SizedBox(height: 16),

                  _label('Reminder Times', isDark: widget.isDark),
                  const SizedBox(height: 8),

                  _timeSlot(
                    label: 'Morning',
                    icon: Icons.wb_sunny_outlined,
                    time: _morningTime,
                    isSelected: _isMorning,
                    isDark: widget.isDark,
                    onToggle: () => setState(() => _isMorning = !_isMorning),
                    onTimeTap: () => _pickTime('morning'),
                  ),
                  const SizedBox(height: 8),
                  _timeSlot(
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
                  _timeSlot(
                    label: 'Night',
                    icon: Icons.nightlight_outlined,
                    time: _nightTime,
                    isSelected: _isNight,
                    isDark: widget.isDark,
                    onToggle: () => setState(() => _isNight = !_isNight),
                    onTimeTap: () => _pickTime('night'),
                  ),

                  const SizedBox(height: 16),

                  _label('For', isDark: widget.isDark),
                  const SizedBox(height: 8),
                  _familySelector(),

                  const SizedBox(height: 16),

                  _label('Notes (Optional)', isDark: widget.isDark),
                  const SizedBox(height: 8),
                  _textField(
                    controller: _notesController,
                    hint: 'e.g. Take after meals',
                    isDark: widget.isDark,
                    maxLines: 2,
                  ),

                  const SizedBox(height: 24),

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
                              'Save Changes',
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
  }

  Widget _label(String text, {required bool isDark}) {
    return Text(
      text,
      style: TextStyle(
        color: isDark ? CliniqTheme.darkTextMuted : CliniqTheme.lightTextMuted,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required bool isDark,
    int maxLines = 1,
  }) {
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

  Widget _timeSlot({
    required String label,
    required IconData icon,
    required String time,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onToggle,
    required VoidCallback onTimeTap,
  }) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
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
                      ? Colors.transparent
                      : (isDark
                          ? CliniqTheme.darkBorder
                          : CliniqTheme.lightBorder),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      size: 12, color: Colors.white)
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
                    ? (isDark ? CliniqTheme.darkText : CliniqTheme.lightText)
                    : (isDark
                        ? CliniqTheme.darkTextMuted
                        : CliniqTheme.lightTextMuted),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: isSelected ? onTimeTap : null,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
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
      ),
    );
  }

  Widget _familySelector() {
    const members = ['Self', 'Spouse', 'Mother', 'Father', 'Child', 'Other'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: members.map((m) {
        final isSelected = _familyMember == m;
        return GestureDetector(
          onTap: () => setState(() => _familyMember = m),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? (widget.isDark
                      ? CliniqTheme.darkPrimary
                      : CliniqTheme.lightPrimary)
                  : (widget.isDark ? CliniqTheme.darkBg : CliniqTheme.lightBg),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : (widget.isDark
                        ? CliniqTheme.darkBorder
                        : CliniqTheme.lightBorder),
                width: 0.5,
              ),
            ),
            child: Text(
              m,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (widget.isDark
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
