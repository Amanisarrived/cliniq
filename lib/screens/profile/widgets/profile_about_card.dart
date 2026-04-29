import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme.dart';

class ProfileAboutCard extends StatelessWidget {
  final bool isDark;

  const ProfileAboutCard({super.key, required this.isDark});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

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
          _AboutTile(
            icon: Iconsax.info_circle,
            title: 'App Version',
            subtitle: 'v1.0.0',
            isDark: isDark,
            onTap: () {},
          ),
          _Divider(isDark: isDark),
          _AboutTile(
            icon: Iconsax.document_text,
            title: 'Privacy Policy',
            subtitle: 'How we use your data',
            isDark: isDark,
            onTap: () => _launchUrl(
              'https://sites.google.com/view/cliniqai/home',
            ),
          ),
          _Divider(isDark: isDark),
          _AboutTile(
            icon: Iconsax.shield_tick,
            title: 'Terms of Service',
            subtitle: 'Usage terms & conditions',
            isDark: isDark,
            onTap: () => _launchUrl(
              'https://sites.google.com/view/cliniqai/home',
            ),
          ),
          _Divider(isDark: isDark),
          _AboutTile(
            icon: Iconsax.message_question,
            title: 'Help & Support',
            subtitle: 'Get help with Cliniq',
            isDark: isDark,
            onTap: () => _launchUrl(
              'mailto:support@cliniq.app',
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;
  final VoidCallback onTap;

  const _AboutTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
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
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: isDark
                  ? CliniqTheme.darkTextMuted
                  : CliniqTheme.lightTextMuted,
            ),
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
