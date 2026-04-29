import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class MoodSelector extends StatelessWidget {
  final int? selectedMood;
  final Function(int) onMoodSelected;
  final bool isDark;

  const MoodSelector({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
    required this.isDark,
  });

  static const List<_MoodData> _moods = [
    _MoodData(value: 1, emoji: '😴', label: 'Exhausted'),
    _MoodData(value: 2, emoji: '😐', label: 'Okay'),
    _MoodData(value: 3, emoji: '🙂', label: 'Good'),
    _MoodData(value: 4, emoji: '😊', label: 'Great'),
    _MoodData(value: 5, emoji: '🤩', label: 'Amazing'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _moods.map((mood) {
        final isSelected = selectedMood == mood.value;
        return GestureDetector(
          onTap: () => onMoodSelected(mood.value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark
                      ? CliniqTheme.darkPrimary.withAlpha(40)
                      : CliniqTheme.lightPrimary.withAlpha(25))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? (isDark
                        ? CliniqTheme.darkPrimary
                        : CliniqTheme.lightPrimary)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Text(
                  mood.emoji,
                  style: TextStyle(
                    fontSize: isSelected ? 32 : 26,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mood.label,
                  style: TextStyle(
                    color: isSelected
                        ? (isDark
                            ? CliniqTheme.darkPrimary
                            : CliniqTheme.lightPrimary)
                        : (isDark
                            ? CliniqTheme.darkTextMuted
                            : CliniqTheme.lightTextMuted),
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
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

class _MoodData {
  final int value;
  final String emoji;
  final String label;

  const _MoodData({
    required this.value,
    required this.emoji,
    required this.label,
  });
}
