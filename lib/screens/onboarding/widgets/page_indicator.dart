import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class PageIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;
  final bool isDark;

  const PageIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? (isDark ? CliniqTheme.darkPrimary : CliniqTheme.lightPrimary)
                : (isDark ? CliniqTheme.darkSurface2 : CliniqTheme.lightBorder),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
