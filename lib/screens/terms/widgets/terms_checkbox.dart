import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class TermsCheckbox extends StatelessWidget {
  final String text;
  final bool value;
  final ValueChanged<bool?> onChanged;
  final bool isDark;

  const TermsCheckbox({
    super.key,
    required this.text,
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: value
              ? (isDark
                  ? CliniqTheme.darkPrimary.withAlpha(30)
                  : CliniqTheme.lightPrimary.withAlpha(15))
              : (isDark ? CliniqTheme.darkSurface : CliniqTheme.lightSurface),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: value
                ? (isDark
                    ? CliniqTheme.darkPrimary.withAlpha(120)
                    : CliniqTheme.lightPrimary.withAlpha(100))
                : (isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder),
            width: value ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: value
                    ? (isDark
                        ? CliniqTheme.darkPrimary
                        : CliniqTheme.lightPrimary)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: value
                      ? (isDark
                          ? CliniqTheme.darkPrimary
                          : CliniqTheme.lightPrimary)
                      : (isDark
                          ? CliniqTheme.darkBorder
                          : CliniqTheme.lightBorder),
                  width: 1.5,
                ),
              ),
              child: value
                  ? const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),

            const SizedBox(width: 12),

            // Text
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
