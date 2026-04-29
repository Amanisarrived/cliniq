import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class DiarySymptomChips extends StatelessWidget {
  final List<String> selected;
  final Function(String) onTap;
  final bool isDark;

  const DiarySymptomChips({
    super.key,
    required this.selected,
    required this.onTap,
    required this.isDark,
  });

  static const List<String> _symptoms = [
    'Headache',
    'Fever',
    'Fatigue',
    'Stomach Pain',
    'Cough',
    'Cold',
    'Nausea',
    'Dizziness',
    'Body Pain',
    'Sore Throat',
    'Insomnia',
    'Anxiety',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // None option
        GestureDetector(
          onTap: () {
            if (selected.isNotEmpty) {
              for (final s in List.from(selected)) {
                onTap(s);
              }
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: selected.isEmpty
                  ? CliniqTheme.success.withAlpha(25)
                  : (isDark
                      ? CliniqTheme.darkSurface
                      : CliniqTheme.lightSurface),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected.isEmpty
                    ? CliniqTheme.success
                    : (isDark
                        ? CliniqTheme.darkBorder
                        : CliniqTheme.lightBorder),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '✅',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 8),
                Text(
                  'Feeling fine — no symptoms',
                  style: TextStyle(
                    color: selected.isEmpty
                        ? CliniqTheme.success
                        : (isDark
                            ? CliniqTheme.darkText
                            : CliniqTheme.lightText),
                    fontSize: 13,
                    fontWeight:
                        selected.isEmpty ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Symptom chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _symptoms.map((symptom) {
            final isSelected = selected.contains(symptom);
            return GestureDetector(
              onTap: () => onTap(symptom),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? CliniqTheme.danger.withAlpha(20)
                      : (isDark
                          ? CliniqTheme.darkSurface
                          : CliniqTheme.lightSurface),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? CliniqTheme.danger.withAlpha(150)
                        : (isDark
                            ? CliniqTheme.darkBorder
                            : CliniqTheme.lightBorder),
                  ),
                ),
                child: Text(
                  symptom,
                  style: TextStyle(
                    color: isSelected
                        ? CliniqTheme.danger
                        : (isDark
                            ? CliniqTheme.darkText
                            : CliniqTheme.lightText),
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
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
