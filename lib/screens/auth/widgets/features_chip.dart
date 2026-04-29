import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class FeatureChips extends StatelessWidget {
  final bool isDark;
  const FeatureChips({super.key, required this.isDark});

  static const List<_ChipData> _chips = [
    _ChipData(emoji: '💊', label: 'Medicine\nScanner'),
    _ChipData(emoji: '🩺', label: 'Health\nGuide'),
    _ChipData(emoji: '🏥', label: 'Find\nHospitals'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _chips
          .map((chip) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: chip == _chips.last ? 0 : 8,
                  ),
                  child: _FeatureChip(
                    data: chip,
                    isDark: isDark,
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final _ChipData data;
  final bool isDark;

  const _FeatureChip({
    required this.data,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 6,
      ),
      decoration: BoxDecoration(
        color: isDark ? CliniqTheme.darkSurface : CliniqTheme.lightSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Text(
            data.emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 8),
          Text(
            data.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark
                  ? CliniqTheme.darkTextMuted
                  : CliniqTheme.lightTextMuted,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipData {
  final String emoji;
  final String label;
  const _ChipData({required this.emoji, required this.label});
}
