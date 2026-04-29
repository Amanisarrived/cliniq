import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isDark;

  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isDark ? CliniqTheme.darkSurface : CliniqTheme.lightSurface,
          foregroundColor:
              isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder,
              width: 0.5,
            ),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: isDark
                      ? CliniqTheme.darkPrimary
                      : CliniqTheme.lightPrimary,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _GoogleIcon(),
                  const SizedBox(width: 12),
                  Text(
                    'Continue with Google',
                    style: TextStyle(
                      color:
                          isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GoogleIconPainter()),
    );
  }
}

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    void drawSlice(double start, double sweep, Color color) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      final path = Path()
        ..moveTo(cx, cy)
        ..arcTo(
          Rect.fromCircle(center: Offset(cx, cy), radius: r),
          start,
          sweep,
          false,
        )
        ..close();
      canvas.drawPath(path, paint);
    }

    drawSlice(-0.3, 1.9, const Color(0xFF4285F4));
    drawSlice(1.6, 1.6, const Color(0xFFEA4335));
    drawSlice(3.2, 1.6, const Color(0xFFFBBC05));
    drawSlice(4.8, 1.5, const Color(0xFF34A853));

    // White center
    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.56,
      Paint()..color = Colors.white,
    );

    // Blue bar
    canvas.drawRect(
      Rect.fromLTWH(cx, cy - r * 0.22, r * 0.95, r * 0.44),
      Paint()..color = const Color(0xFF4285F4),
    );
  }

  @override
  bool shouldRepaint(_GoogleIconPainter old) => false;
}
