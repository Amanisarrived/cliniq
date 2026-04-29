import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../providers/user_provider.dart';

class HomeHeader extends StatelessWidget {
  final bool isDark;
  const HomeHeader({super.key, required this.isDark});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning 🌤️';
    if (hour < 17) return 'Good afternoon ☀️';
    return 'Good evening 🌙';
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select<UserProvider, dynamic>(
      (p) => p.user,
    );

    final name =
        user?.name.isNotEmpty == true ? user!.name.split(' ').first : 'there';

    return Row(
      children: [
        // ─── Greeting + Name ──────────────────
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: TextStyle(
                  color: isDark
                      ? CliniqTheme.darkTextMuted
                      : CliniqTheme.lightTextMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Hello, $name',
                style: TextStyle(
                  color: isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
        ),

        // ─── Notification Bell ────────────────
        GestureDetector(
          onTap: () {},
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color:
                  isDark ? CliniqTheme.darkSurface : CliniqTheme.lightSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color:
                    isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder,
                width: 0.5,
              ),
            ),
            child: Icon(
              Icons.notifications_outlined,
              size: 18,
              color: isDark
                  ? CliniqTheme.darkTextMuted
                  : CliniqTheme.lightTextMuted,
            ),
          ),
        ),
      ],
    );
  }
}
