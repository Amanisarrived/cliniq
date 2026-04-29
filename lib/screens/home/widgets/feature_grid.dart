import 'package:cliniq/screens/news/news_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/routes.dart';
import '../../../screens/prescriptions/prescription_list_screen.dart';
import 'feature_card.dart';

class FeatureGrid extends StatelessWidget {
  final bool isDark;
  const FeatureGrid({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final features = [
      _FeatureData(
        icon: HugeIcons.strokeRoundedMedicineBottle01,
        line1: 'Medicine',
        line2: 'Scanner',
        subtitle: 'Tap to scan',
        iconBg: isDark ? const Color(0xFF2C2842) : const Color(0xFFEEEDFE),
        iconColor: isDark ? const Color(0xFFC0BAF0) : const Color(0xFF534AB7),
        cornerColor: isDark ? const Color(0xFF201D30) : const Color(0xFFF5F3FC),
        route: AppRoutes.medicineScanner,
      ),
      _FeatureData(
        icon: HugeIcons.strokeRoundedNews,
        line1: 'Health',
        line2: 'News',
        subtitle: 'Latest updates',
        iconBg: isDark ? const Color(0xFF0D1A2E) : const Color(0xFFE6F1FB),
        iconColor: isDark ? const Color(0xFF85B7EB) : const Color(0xFF185FA5),
        cornerColor: isDark ? const Color(0xFF0A1520) : const Color(0xFFEEF5FC),
        route: AppRoutes.news,
      ),
      _FeatureData(
        icon: HugeIcons.strokeRoundedHeartCheck,
        line1: 'Health',
        line2: 'Guide',
        subtitle: 'Check symptoms',
        iconBg: isDark ? const Color(0xFF0D2420) : const Color(0xFFE1F5EE),
        iconColor: isDark ? const Color(0xFF5DCAA5) : const Color(0xFF0F6E56),
        cornerColor: isDark ? const Color(0xFF0A1E1A) : const Color(0xFFF0FBF7),
        route: AppRoutes.sicknessGuide,
      ),
      _FeatureData(
        icon: HugeIcons.strokeRoundedMedicalFile,
        line1: 'My',
        line2: 'Prescriptions',
        subtitle: 'Save & share',
        iconBg: isDark ? const Color(0xFF2A1A0A) : const Color(0xFFFAEEDA),
        iconColor: isDark ? const Color(0xFFEF9F27) : const Color(0xFF854F0B),
        cornerColor: isDark ? const Color(0xFF201408) : const Color(0xFFFDF6EE),
        route: AppRoutes.prescriptions,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 0.95,
      children: features
          .map(
            (f) => FeatureCard(
              icon: f.icon,
              line1: f.line1,
              line2: f.line2,
              subtitle: f.subtitle,
              iconBgColor: f.iconBg,
              iconColor: f.iconColor,
              cornerColor: f.cornerColor,
              isDark: isDark,
              onTap: () {
                if (f.route == AppRoutes.prescriptions) {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (_) => const PrescriptionListScreen(),
                    ),
                  );
                } else if (f.route == AppRoutes.news) {
                  // ✅ ADD
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (_) => const NewsScreen(),
                    ),
                  );
                } else {
                  context.push(f.route);
                }
              },
            ),
          )
          .toList(),
    );
  }
}

class _FeatureData {
  final dynamic icon;
  final String line1;
  final String line2;
  final String subtitle;
  final Color iconBg;
  final Color iconColor;
  final Color cornerColor;
  final String route;

  const _FeatureData({
    required this.icon,
    required this.line1,
    required this.line2,
    required this.subtitle,
    required this.iconBg,
    required this.iconColor,
    required this.cornerColor,
    required this.route,
  });
}
