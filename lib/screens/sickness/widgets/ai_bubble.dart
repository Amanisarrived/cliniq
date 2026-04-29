import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class AiBubble extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const AiBubble({
    super.key,
    required this.child,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Logo ─────────────────────────────
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            'assets/images/cliniq_logo (1).png',
            width: 30,
            height: 30,
            fit: BoxFit.cover,
          ),
        ),

        const SizedBox(width: 10),

        // ─── Bubble ───────────────────────────
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color:
                  isDark ? CliniqTheme.darkSurface : CliniqTheme.lightSurface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(
                color:
                    isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder,
                width: 0.5,
              ),
            ),
            child: child,
          ),
        ),
      ],
    );
  }
}
