import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class WelcomeMessages extends StatelessWidget {
  final bool isDark;
  const WelcomeMessages({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Welcome bubble
        _AiBubble(
          isDark: isDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello! 👋 I\'m your medicine assistant.',
                style: TextStyle(
                  color: isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Scan or type any medicine to understand it better.',
                style: TextStyle(
                  color: isDark
                      ? CliniqTheme.darkTextMuted
                      : CliniqTheme.lightTextMuted,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Options bubble
        _AiBubble(
          isDark: isDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You can:',
                style: TextStyle(
                  color: isDark
                      ? CliniqTheme.darkTextMuted
                      : CliniqTheme.lightTextMuted,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 8),
              _OptionRow(
                emoji: '📷',
                text: 'Take a photo of medicine',
                isDark: isDark,
              ),
              const SizedBox(height: 6),
              _OptionRow(
                emoji: '🖼️',
                text: 'Upload from gallery',
                isDark: isDark,
              ),
              const SizedBox(height: 6),
              _OptionRow(
                emoji: '⌨️',
                text: 'Type medicine name',
                isDark: isDark,
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Disclaimer
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFFAEEDA),
              width: 0.5,
            ),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '⚠️',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'For information only. Always consult a doctor before taking any medicine.',
                  style: const TextStyle(
                    color: Color(0xFF854F0B),
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AiBubble extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const _AiBubble({required this.child, required this.isDark});

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
            child: child,
          ),
        ),
      ],
    );
  }
}

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

class _OptionRow extends StatelessWidget {
  final String emoji;
  final String text;
  final bool isDark;

  const _OptionRow({
    required this.emoji,
    required this.text,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: isDark ? CliniqTheme.darkSurface2 : CliniqTheme.lightBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
