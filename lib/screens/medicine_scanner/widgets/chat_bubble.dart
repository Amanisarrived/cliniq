import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../models/chat_message_model.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isDark;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return switch (message.contentType) {
      ContentType.text => message.messageType == MessageType.user
          ? _UserTextBubble(text: message.text ?? '', isDark: isDark)
          : _AiTextBubble(text: message.text ?? '', isDark: isDark),
      ContentType.image => _UserImageBubble(
          imagePath: message.imagePath ?? '',
          isDark: isDark,
        ),
      ContentType.loading => _LoadingBubble(isDark: isDark),
      ContentType.result => const SizedBox.shrink(),
      ContentType.sessionLimit => const SizedBox.shrink(),
    };
  }
}

// ── User Text ─────────────────────────────────────────
class _UserTextBubble extends StatelessWidget {
  final String text;
  final bool isDark;

  const _UserTextBubble({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isDark ? CliniqTheme.darkPrimary : CliniqTheme.lightPrimary,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(14),
            bottomLeft: Radius.circular(14),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

// ── AI Text ───────────────────────────────────────────
class _AiTextBubble extends StatelessWidget {
  final String text;
  final bool isDark;

  const _AiTextBubble({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AiAvatar(isDark: isDark),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  isDark ? CliniqTheme.darkSurface : CliniqTheme.lightSurface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(14),
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
              border: Border.all(
                color:
                    isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder,
                width: 0.5,
              ),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── User Image ────────────────────────────────────────
class _UserImageBubble extends StatelessWidget {
  final String imagePath;
  final bool isDark;

  const _UserImageBubble({
    required this.imagePath,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 160,
        height: 120,
        decoration: BoxDecoration(
          color: isDark ? CliniqTheme.darkPrimary : CliniqTheme.lightPrimary,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(14),
            bottomLeft: Radius.circular(14),
            bottomRight: Radius.circular(4),
          ),
        ),
        padding: const EdgeInsets.all(6),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            File(imagePath),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(
                Icons.broken_image_outlined,
                color: Colors.white54,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Loading Dots ──────────────────────────────────────
class _LoadingBubble extends StatefulWidget {
  final bool isDark;
  const _LoadingBubble({required this.isDark});

  @override
  State<_LoadingBubble> createState() => _LoadingBubbleState();
}

class _LoadingBubbleState extends State<_LoadingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AiAvatar(isDark: widget.isDark),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: widget.isDark
                ? CliniqTheme.darkSurface
                : CliniqTheme.lightSurface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(14),
              bottomLeft: Radius.circular(14),
              bottomRight: Radius.circular(14),
            ),
            border: Border.all(
              color: widget.isDark
                  ? CliniqTheme.darkBorder
                  : CliniqTheme.lightBorder,
              width: 0.5,
            ),
          ),
          child: AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Dot(opacity: _anim.value, isDark: widget.isDark),
                const SizedBox(width: 4),
                _Dot(
                  opacity: (_anim.value - 0.2).clamp(0.2, 1.0),
                  isDark: widget.isDark,
                ),
                const SizedBox(width: 4),
                _Dot(
                  opacity: (_anim.value - 0.4).clamp(0.1, 1.0),
                  isDark: widget.isDark,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  final double opacity;
  final bool isDark;

  const _Dot({required this.opacity, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: (isDark ? CliniqTheme.darkPrimary : CliniqTheme.lightPrimary)
            .withAlpha((opacity * 255).toInt()),
        shape: BoxShape.circle,
      ),
    );
  }
}

// ── AI Avatar ─────────────────────────────────────────
class _AiAvatar extends StatelessWidget {
  final bool isDark;
  const _AiAvatar({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(9),
      child: Image.asset(
        'assets/images/cliniq_logo (1).png',
        width: 28,
        height: 28,
        fit: BoxFit.cover,
      ),
    );
  }
}
