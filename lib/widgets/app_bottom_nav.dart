import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../core/theme.dart';
import '../core/routes.dart';

class AppBottomNav extends StatelessWidget {
  final String currentRoute;

  const AppBottomNav({
    super.key,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? CliniqTheme.darkSurface : CliniqTheme.lightSurface,
        border: Border(
          top: BorderSide(
            color: isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Iconsax.home,
                label: 'Home',
                isActive: currentRoute == AppRoutes.home,
                isDark: isDark,
                onTap: () => context.go(AppRoutes.home),
              ),
              _NavItem(
                icon: Iconsax.notification_1,
                label: 'Reminders',
                isActive: currentRoute == AppRoutes.reminders,
                isDark: isDark,
                onTap: () => context.go(AppRoutes.reminders),
              ),
              _NavItem(
                icon: Iconsax.health,
                label: 'Diary',
                isActive: currentRoute == AppRoutes.diary,
                isDark: isDark,
                onTap: () => context.go(AppRoutes.diary),
              ),
              _NavItem(
                icon: Iconsax.user,
                label: 'Profile',
                isActive: currentRoute == AppRoutes.profile,
                isDark: isDark,
                onTap: () => context.go(AppRoutes.profile),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor =
        isDark ? CliniqTheme.darkPrimary : CliniqTheme.lightPrimary;
    final inactiveColor =
        isDark ? CliniqTheme.darkTextMuted : CliniqTheme.lightTextMuted;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 22,
            color: isActive ? activeColor : inactiveColor,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: isActive ? activeColor : inactiveColor,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: isActive ? 4 : 0,
            height: isActive ? 4 : 0,
            decoration: BoxDecoration(
              color: activeColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
