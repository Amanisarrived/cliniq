import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedLogo extends StatefulWidget {
  const AnimatedLogo({super.key});

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with TickerProviderStateMixin {
  // Single controller — cost efficient
  late AnimationController _masterController;
  late AnimationController _pulseController;
  late AnimationController _breathController;

  late Animation<double> _scaleAnim;
  late Animation<double> _pulseAnim;
  late Animation<double> _breathAnim;
  late Animation<double> _rotateAnim;

  @override
  void initState() {
    super.initState();

    // Master — scale in once
    _masterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _rotateAnim = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    // Pulse — ECG line repeating
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    _pulseAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.linear,
      ),
    );

    // Breath — slow glow in/out
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _breathAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _breathController,
        curve: Curves.easeInOut,
      ),
    );

    // Start after small delay
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _masterController.forward();
    });
  }

  @override
  void dispose() {
    _masterController.dispose();
    _pulseController.dispose();
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      // ✅ Merge only what changes together
      animation: Listenable.merge([
        _scaleAnim,
        _pulseAnim,
        _breathAnim,
      ]),
      builder: (context, _) {
        return Transform.scale(
          scale: _scaleAnim.value,
          child: Transform.rotate(
            angle: _rotateAnim.value,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                color: const Color(0xFF1E1040),
                boxShadow: [
                  // Outer glow — breathes
                  BoxShadow(
                    color: const Color(0xFF7C75D8)
                        .withAlpha((80 * _breathAnim.value).toInt()),
                    blurRadius: 28 * _breathAnim.value,
                    spreadRadius: 4 * _breathAnim.value,
                  ),
                  // Inner sharp shadow
                  BoxShadow(
                    color: const Color(0xFF4C1D95)
                        .withAlpha((120 * _breathAnim.value).toInt()),
                    blurRadius: 12,
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: CustomPaint(
                painter: _LogoPainter(
                  breathValue: _breathAnim.value,
                  pulseValue: _pulseAnim.value,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LogoPainter extends CustomPainter {
  final double breathValue;
  final double pulseValue;

  const _LogoPainter({
    required this.breathValue,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = size.width * 0.27;

    // ── BG subtle inner circle ──
    final bgPaint = Paint()
      ..color = const Color(0xFF2D1B69).withAlpha((40 * breathValue).toInt())
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(cx, cy),
      radius * 1.4,
      bgPaint,
    );

    // ── Letter C Arc ──
    final rect = Rect.fromCircle(
      center: Offset(cx + 3, cy),
      radius: radius,
    );

    // Glow layer first
    final glowPaint = Paint()
      ..color = const Color(0xFF9F7AEA).withAlpha((80 * breathValue).toInt())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    final cPath = Path()..addArc(rect, 0.65, 5.0);
    canvas.drawPath(cPath, glowPaint);

    // Main C stroke
    final cPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(cPath, cPaint);

    // ── Tip positions ──
    const topAngle = 0.65;
    const bottomAngle = 0.65 + 5.0;

    final topTip = Offset(
      cx + 3 + radius * math.cos(topAngle),
      cy + radius * math.sin(topAngle),
    );
    final bottomTip = Offset(
      cx + 3 + radius * math.cos(bottomAngle),
      cy + radius * math.sin(bottomAngle),
    );

    // ── Neural nodes at tips ──
    _drawNode(canvas, topTip, breathValue, large: true);
    _drawNode(canvas, bottomTip, breathValue, large: true);

    // ── Mini constellation lines from top tip ──
    _drawConstellation(canvas, topTip, breathValue, isTop: true);
    _drawConstellation(canvas, bottomTip, breathValue, isTop: false);

    // ── Animated ECG Pulse inside C ──
    _drawEcgPulse(canvas, cx, cy, radius, pulseValue, breathValue);
  }

  void _drawNode(
    Canvas canvas,
    Offset center,
    double breath, {
    bool large = false,
  }) {
    final size = large ? 4.5 : 2.5;

    // Glow ring
    final glowPaint = Paint()
      ..color = const Color(0xFF9F7AEA).withAlpha((100 * breath).toInt())
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(center, size * 1.8 * breath, glowPaint);

    // Core dot
    final dotPaint = Paint()
      ..color = const Color(0xFFE0D7FF)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size, dotPaint);
  }

  void _drawConstellation(
    Canvas canvas,
    Offset origin,
    double breath, {
    required bool isTop,
  }) {
    final linePaint = Paint()
      ..color = const Color(0xFFC4B5FD).withAlpha((120 * breath).toInt())
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    final dir = isTop ? -1.0 : 1.0;

    // 3 lines from each tip
    final points = [
      Offset(origin.dx + 9, origin.dy + dir * 9),
      Offset(origin.dx + 14, origin.dy + dir * 2),
      Offset(origin.dx + 7, origin.dy + dir * 16),
    ];

    for (final point in points) {
      canvas.drawLine(origin, point, linePaint);
      _drawNode(canvas, point, breath);
    }
  }

  void _drawEcgPulse(
    Canvas canvas,
    double cx,
    double cy,
    double radius,
    double pulse,
    double breath,
  ) {
    final startX = cx - radius * 0.55;
    final endX = cx + radius * 0.05;
    final baseY = cy + radius * 0.2;
    final totalW = endX - startX;

    // Trail effect — faded old pulse
    if (pulse > 0.15) {
      final trailPaint = Paint()
        ..color = const Color(0xFF7C75D8).withAlpha((40 * breath).toInt())
        ..strokeWidth = 1.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final trailPath = _buildEcgPath(
        startX,
        baseY,
        totalW,
        math.max(0, pulse - 0.15),
      );
      canvas.drawPath(trailPath, trailPaint);
    }

    // Main pulse line
    final ecgPaint = Paint()
      ..color = const Color(0xFFB794F4).withAlpha((180 * breath).toInt())
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final ecgPath = _buildEcgPath(startX, baseY, totalW, pulse);
    canvas.drawPath(ecgPath, ecgPaint);

    // Glowing head dot at current pulse position
    if (pulse > 0.05 && pulse < 0.98) {
      final headPos = _getEcgPosition(startX, baseY, totalW, pulse);
      if (headPos != null) {
        final headPaint = Paint()
          ..color = const Color(0xFFE9D5FF).withAlpha((200 * breath).toInt())
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(headPos, 3, headPaint);
      }
    }
  }

  Path _buildEcgPath(
    double startX,
    double baseY,
    double totalW,
    double progress,
  ) {
    final path = Path();
    final p = progress.clamp(0.0, 1.0);
    final curX = startX + totalW * p;

    path.moveTo(startX, baseY);

    final pts = [
      [0.25, 0.0],
      [0.38, -0.0],
      [0.45, -14.0],
      [0.52, 8.0],
      [0.60, -5.0],
      [0.70, 0.0],
      [1.0, 0.0],
    ];

    for (final pt in pts) {
      final x = startX + totalW * pt[0];
      final y = baseY + pt[1];
      if (x <= curX) {
        path.lineTo(x, y);
      } else {
        final prevX = path.getBounds().right;
        final t = (curX - prevX) / (x - prevX);
        final prevY = baseY;
        path.lineTo(curX, prevY + (y - prevY) * t);
        break;
      }
    }

    return path;
  }

  Offset? _getEcgPosition(
    double startX,
    double baseY,
    double totalW,
    double progress,
  ) {
    final p = progress.clamp(0.0, 1.0);
    final curX = startX + totalW * p;
    double y = baseY;
    if (p > 0.45 && p < 0.52) {
      y = baseY - 14 * ((p - 0.45) / 0.07);
    } else if (p >= 0.52 && p < 0.60) {
      y = baseY + 8 * ((p - 0.52) / 0.08);
    } else if (p >= 0.60 && p < 0.70) {
      y = baseY - 5 * ((p - 0.60) / 0.10);
    }

    return Offset(curX, y);
  }

  @override
  bool shouldRepaint(_LogoPainter old) =>
      old.breathValue != breathValue || old.pulseValue != pulseValue;
}
