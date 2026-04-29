import 'package:cliniq/core/theme.dart';
import 'package:cliniq/models/diary_entry_model.dart';
import 'package:cliniq/providers/diary_provider.dart';
import 'package:cliniq/screens/diary/widgets/mood_selector.dart';
import 'package:cliniq/screens/diary/widgets/symptom_chips.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // State
  int? _selectedMood;
  List<String> _selectedSymptoms = [];
  int _waterGlasses = 4;
  List<DiaryMedicine> _medicines = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Load medicines from reminders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _medicines = context.read<DiaryProvider>().getMedicinesForCheckIn();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0 && _selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your mood')),
      );
      return;
    }

    if (_currentStep < 3) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _save();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);

    final success = await context.read<DiaryProvider>().saveCheckIn(
          mood: _selectedMood!,
          symptoms: _selectedSymptoms,
          waterGlasses: _waterGlasses,
          medicines: _medicines,
        );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          'Daily Check-in',
          style: TextStyle(
            color: isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          // ─── Progress Bar ─────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: List.generate(4, (i) {
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                    decoration: BoxDecoration(
                      color: i <= _currentStep
                          ? (isDark
                              ? CliniqTheme.darkPrimary
                              : CliniqTheme.lightPrimary)
                          : (isDark
                              ? CliniqTheme.darkBorder
                              : CliniqTheme.lightBorder),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 8),

          // Step label
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${_currentStep + 1} of 4',
                style: TextStyle(
                  color: isDark
                      ? CliniqTheme.darkTextMuted
                      : CliniqTheme.lightTextMuted,
                  fontSize: 11,
                ),
              ),
            ),
          ),

          // ─── Pages ────────────────────────────
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // Step 1 — Mood
                _StepPage(
                  isDark: isDark,
                  title: 'How are you feeling today? 🌟',
                  subtitle: 'Select your mood',
                  child: MoodSelector(
                    selectedMood: _selectedMood,
                    onMoodSelected: (mood) =>
                        setState(() => _selectedMood = mood),
                    isDark: isDark,
                  ),
                ),

                // Step 2 — Symptoms
                _StepPage(
                  isDark: isDark,
                  title: 'Any symptoms? 🤒',
                  subtitle: 'Select all that apply',
                  child: DiarySymptomChips(
                    selected: _selectedSymptoms,
                    onTap: (symptom) {
                      setState(() {
                        if (_selectedSymptoms.contains(symptom)) {
                          _selectedSymptoms.remove(symptom);
                        } else {
                          _selectedSymptoms.add(symptom);
                        }
                      });
                    },
                    isDark: isDark,
                  ),
                ),

                // Step 3 — Medicines
                _StepPage(
                  isDark: isDark,
                  title: 'Did you take your medicines? 💊',
                  subtitle: 'Mark what you took today',
                  child: _medicines.isEmpty
                      ? _NoMedicinesWidget(isDark: isDark)
                      : _MedicineChecklist(
                          medicines: _medicines,
                          isDark: isDark,
                          onToggle: (index) {
                            setState(() {
                              _medicines[index] = _medicines[index]
                                  .copyWith(taken: !_medicines[index].taken);
                            });
                          },
                        ),
                ),

                // Step 4 — Water
                _StepPage(
                  isDark: isDark,
                  title: 'How much water did you drink? 💧',
                  subtitle: 'Tap to adjust',
                  child: _WaterSelector(
                    glasses: _waterGlasses,
                    isDark: isDark,
                    onChanged: (val) => setState(() => _waterGlasses = val),
                  ),
                ),
              ],
            ),
          ),

          // ─── Buttons ──────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              MediaQuery.of(context).padding.bottom + 20,
            ),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _prevStep,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                          color: isDark
                              ? CliniqTheme.darkBorder
                              : CliniqTheme.lightBorder,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Back',
                        style: TextStyle(
                          color: isDark
                              ? CliniqTheme.darkText
                              : CliniqTheme.lightText,
                        ),
                      ),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? CliniqTheme.darkPrimary
                          : CliniqTheme.lightPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _currentStep == 3 ? 'Save ✅' : 'Next →',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step Page ────────────────────────────────────────────────────

class _StepPage extends StatelessWidget {
  final bool isDark;
  final String title;
  final String subtitle;
  final Widget child;

  const _StepPage({
    required this.isDark,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: isDark
                  ? CliniqTheme.darkTextMuted
                  : CliniqTheme.lightTextMuted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 28),
          child,
        ],
      ),
    );
  }
}

// ─── Medicine Checklist ───────────────────────────────────────────

class _MedicineChecklist extends StatelessWidget {
  final List<DiaryMedicine> medicines;
  final bool isDark;
  final Function(int) onToggle;

  const _MedicineChecklist({
    required this.medicines,
    required this.isDark,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: medicines.asMap().entries.map((entry) {
        final i = entry.key;
        final m = entry.value;
        return GestureDetector(
          onTap: () => onToggle(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: m.taken
                  ? CliniqTheme.success.withAlpha(20)
                  : (isDark
                      ? CliniqTheme.darkSurface
                      : CliniqTheme.lightSurface),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: m.taken
                    ? CliniqTheme.success.withAlpha(100)
                    : (isDark
                        ? CliniqTheme.darkBorder
                        : CliniqTheme.lightBorder),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: m.taken ? CliniqTheme.success : Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: m.taken
                          ? CliniqTheme.success
                          : (isDark
                              ? CliniqTheme.darkBorder
                              : CliniqTheme.lightBorder),
                      width: 1.5,
                    ),
                  ),
                  child: m.taken
                      ? const Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: Colors.white,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    m.medicineName,
                    style: TextStyle(
                      color: m.taken
                          ? CliniqTheme.success
                          : (isDark
                              ? CliniqTheme.darkText
                              : CliniqTheme.lightText),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      decoration: m.taken
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                ),
                Text(
                  m.taken ? 'Taken ✅' : 'Not yet',
                  style: TextStyle(
                    color: m.taken
                        ? CliniqTheme.success
                        : (isDark
                            ? CliniqTheme.darkTextMuted
                            : CliniqTheme.lightTextMuted),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── No Medicines Widget ──────────────────────────────────────────

class _NoMedicinesWidget extends StatelessWidget {
  final bool isDark;
  const _NoMedicinesWidget({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? CliniqTheme.darkSurface : CliniqTheme.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder,
        ),
      ),
      child: Column(
        children: [
          const Text('💊', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            'No medicines added',
            style: TextStyle(
              color: isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Add reminders to track your medicines here',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark
                  ? CliniqTheme.darkTextMuted
                  : CliniqTheme.lightTextMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Water Selector ───────────────────────────────────────────────

class _WaterSelector extends StatelessWidget {
  final int glasses;
  final bool isDark;
  final Function(int) onChanged;

  const _WaterSelector({
    required this.glasses,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Big display
        Text(
          '💧' * (glasses > 8 ? 8 : glasses),
          style: const TextStyle(fontSize: 32),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 20),

        Text(
          '$glasses glasses',
          style: TextStyle(
            color: isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),

        Text(
          glasses >= 8
              ? 'Excellent hydration! 🎉'
              : glasses >= 5
                  ? 'Good job! Keep drinking'
                  : 'Try to drink more water',
          style: TextStyle(
            color:
                isDark ? CliniqTheme.darkTextMuted : CliniqTheme.lightTextMuted,
            fontSize: 13,
          ),
        ),

        const SizedBox(height: 28),

        // Slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor:
                isDark ? CliniqTheme.darkPrimary : CliniqTheme.lightPrimary,
            inactiveTrackColor:
                isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder,
            thumbColor:
                isDark ? CliniqTheme.darkPrimary : CliniqTheme.lightPrimary,
            overlayColor:
                (isDark ? CliniqTheme.darkPrimary : CliniqTheme.lightPrimary)
                    .withAlpha(30),
            trackHeight: 6,
          ),
          child: Slider(
            value: glasses.toDouble(),
            min: 0,
            max: 12,
            divisions: 12,
            onChanged: (val) => onChanged(val.round()),
          ),
        ),

        // Quick buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [2, 4, 6, 8, 10].map((val) {
            final isSelected = glasses == val;
            return GestureDetector(
              onTap: () => onChanged(val),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark
                          ? CliniqTheme.darkPrimary
                          : CliniqTheme.lightPrimary)
                      : (isDark
                          ? CliniqTheme.darkSurface
                          : CliniqTheme.lightSurface),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? (isDark
                            ? CliniqTheme.darkPrimary
                            : CliniqTheme.lightPrimary)
                        : (isDark
                            ? CliniqTheme.darkBorder
                            : CliniqTheme.lightBorder),
                  ),
                ),
                child: Text(
                  '$val',
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isDark
                            ? CliniqTheme.darkText
                            : CliniqTheme.lightText),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
