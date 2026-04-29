import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class SymptomChips extends StatelessWidget {
  final List<String> selected;
  final Function(String) onTap;
  final bool isDark;

  const SymptomChips({
    super.key,
    required this.selected,
    required this.onTap,
    required this.isDark,
  });

  static const List<String> _chips = [
    'Fever',
    'Cold & Cough',
    'Headache',
    'Stomach Pain',
    'Vomiting',
    'Diarrhea',
    'Weakness',
    'Body Pain',
    'Sore Throat',
    'Dizziness',
    'Chest Pain',
    'Back Pain',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Common Symptoms',
          style: TextStyle(
            color:
                isDark ? CliniqTheme.darkTextMuted : CliniqTheme.lightTextMuted,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _chips.map((chip) {
            final isSelected = selected.contains(chip);
            return GestureDetector(
              onTap: () => onTap(chip),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
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
                  chip,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
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
