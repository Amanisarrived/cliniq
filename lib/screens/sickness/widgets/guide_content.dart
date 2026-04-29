import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme.dart';

class GuideContent extends StatelessWidget {
  final String guide;
  final bool isDark;

  const GuideContent({
    super.key,
    required this.guide,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final lines = guide
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...lines.map((line) => _buildLine(line)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: CliniqTheme.warning.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Iconsax.warning_2, size: 12, color: CliniqTheme.warning),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'This is general information only. Always consult a doctor.',
                  style: TextStyle(
                    color: CliniqTheme.warning,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLine(String line) {
    final isHeader = RegExp(r'^[🤔🏠❌🏥🚨⚕️]').hasMatch(line);
    final isWarning = line.startsWith('🚨');
    final isDisclaimer = line.startsWith('⚕️');
    final isBullet = line.startsWith('-');

    if (isDisclaimer) return const SizedBox.shrink();

    if (isHeader) {
      return Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 4),
        child: Text(
          line.replaceAll('*', ''),
          style: TextStyle(
            color: isWarning ? CliniqTheme.danger : const Color(0xFF534AB7),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    if (isBullet) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4, left: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: isWarning
                      ? CliniqTheme.danger
                      : (isDark
                          ? CliniqTheme.darkTextMuted
                          : CliniqTheme.lightTextMuted),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                line.substring(1).trim(),
                style: TextStyle(
                  color: isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        line,
        style: TextStyle(
          color: isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
          fontSize: 13,
          height: 1.5,
        ),
      ),
    );
  }
}
