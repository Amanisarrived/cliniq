import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme.dart';

class ProfileSettingsCard extends StatelessWidget {
  final bool isDark;
  final VoidCallback onThemeToggle;

  const ProfileSettingsCard({
    super.key,
    required this.isDark,
    required this.onThemeToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? CliniqTheme.darkSurface : CliniqTheme.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder,
        ),
      ),
      child: Column(
        children: [
          _SettingsTile(
            icon: isDark ? Iconsax.moon : Iconsax.sun_1,
            title: isDark ? 'Dark Mode' : 'Light Mode',
            subtitle: 'Toggle app theme',
            isDark: isDark,
            trailing: Switch(
              value: isDark,
              onChanged: (_) => onThemeToggle(),
              activeColor:
                  isDark ? CliniqTheme.darkPrimary : CliniqTheme.lightPrimary,
            ),
            onTap: onThemeToggle,
          ),
          _Divider(isDark: isDark),
          _SettingsTile(
            icon: Iconsax.notification,
            title: 'Notifications',
            subtitle: 'Manage reminder alerts',
            isDark: isDark,
            trailing: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: isDark
                  ? CliniqTheme.darkTextMuted
                  : CliniqTheme.lightTextMuted,
            ),
            onTap: () {}, // Future
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;
  final Widget trailing;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isDark
                    ? CliniqTheme.darkSurface2
                    : CliniqTheme.lightSurface2,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                icon,
                size: 18,
                color:
                    isDark ? CliniqTheme.darkPrimary : CliniqTheme.lightPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color:
                          isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isDark
                          ? CliniqTheme.darkTextMuted
                          : CliniqTheme.lightTextMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder,
    );
  }
}
