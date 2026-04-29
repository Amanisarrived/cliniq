import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../providers/user_provider.dart';

class ProfileUserCard extends StatelessWidget {
  final UserModel? user;
  final bool isDark;

  const ProfileUserCard({
    super.key,
    required this.user,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? CliniqTheme.darkSurface : CliniqTheme.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder,
        ),
      ),
      child: Row(
        children: [
          // ─── Avatar ──────────────────────────────
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color:
                  isDark ? CliniqTheme.darkSurface2 : CliniqTheme.lightSurface2,
            ),
            child: user?.photoUrl.isNotEmpty == true
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedNetworkImage(
                      imageUrl: user!.photoUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _AvatarPlaceholder(
                        name: user?.name ?? '',
                        isDark: isDark,
                      ),
                      errorWidget: (_, __, ___) => _AvatarPlaceholder(
                        name: user?.name ?? '',
                        isDark: isDark,
                      ),
                    ),
                  )
                : _AvatarPlaceholder(
                    name: user?.name ?? '',
                    isDark: isDark,
                  ),
          ),

          const SizedBox(width: 14),

          // ─── Info ────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name.isNotEmpty == true ? user!.name : 'User',
                  style: TextStyle(
                    color:
                        isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  user?.email ?? '',
                  style: TextStyle(
                    color: isDark
                        ? CliniqTheme.darkTextMuted
                        : CliniqTheme.lightTextMuted,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),

                // Plan badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: user?.isPro == true
                        ? CliniqTheme.warning.withAlpha(25)
                        : (isDark
                            ? CliniqTheme.darkPrimary.withAlpha(25)
                            : CliniqTheme.lightPrimary.withAlpha(15)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        user?.isPro == true
                            ? Icons.workspace_premium_rounded
                            : Icons.person_outline_rounded,
                        size: 12,
                        color: user?.isPro == true
                            ? CliniqTheme.warning
                            : (isDark
                                ? CliniqTheme.darkPrimary
                                : CliniqTheme.lightPrimary),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        user?.isPro == true ? 'Pro Member' : 'Free Plan',
                        style: TextStyle(
                          color: user?.isPro == true
                              ? CliniqTheme.warning
                              : (isDark
                                  ? CliniqTheme.darkPrimary
                                  : CliniqTheme.lightPrimary),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  final String name;
  final bool isDark;

  const _AvatarPlaceholder({required this.name, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'U',
        style: TextStyle(
          color: isDark ? CliniqTheme.darkPrimary : CliniqTheme.lightPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
