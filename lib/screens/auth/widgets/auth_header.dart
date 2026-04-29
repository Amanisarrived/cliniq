import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class AuthHeader extends StatelessWidget {
  final bool isDark;
  const AuthHeader({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo Mark
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isDark ? CliniqTheme.darkSurface : CliniqTheme.lightSurface2,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder,
              width: 0.5,
            ),
          ),
          child: Center(
            child: CustomPaint(
              size: const Size(28, 28),
              painter: _CLogoPainter(
                color:
                    isDark ? CliniqTheme.darkAccent : CliniqTheme.lightPrimary,
              ),
            ),
          ),
        ),

        const SizedBox(height: 28),

        // Title
        Text(
          'Your health,\nunderstood.',
          style: TextStyle(
            color: isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
            height: 1.2,
          ),
        ),

        const SizedBox(height: 10),

        // Subtitle
        Text(
          'Scan medicines, get guidance,\nfind hospitals — all in one place.',
          style: TextStyle(
            color:
                isDark ? CliniqTheme.darkTextMuted : CliniqTheme.lightTextMuted,
            fontSize: 14,
            height: 1.6,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _CLogoPainter extends CustomPainter {
  final Color color;
  const _CLogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(
      center: Offset(size.width / 2 + 2, size.height / 2),
      radius: size.width * 0.38,
    );
    canvas.drawArc(rect, 0.7, 4.88, false, paint);

    // Node dot
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.38),
      2,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(_CLogoPainter old) => old.color != color;
}
