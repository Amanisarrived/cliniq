import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme.dart';
import '../../../models/news_model.dart';

class NewsCard extends StatelessWidget {
  final NewsModel news;
  final bool isDark;

  const NewsCard({
    super.key,
    required this.news,
    required this.isDark,
  });

  Future<void> _openUrl() async {
    final uri = Uri.parse(news.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openUrl,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? CliniqTheme.darkSurface : CliniqTheme.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Image ───────────────────────────
            if (news.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: CachedNetworkImage(
                  imageUrl: news.imageUrl,
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    height: 160,
                    color: isDark
                        ? CliniqTheme.darkSurface2
                        : CliniqTheme.lightSurface2,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 160,
                    color: isDark
                        ? CliniqTheme.darkSurface2
                        : CliniqTheme.lightSurface2,
                    child: Icon(
                      Icons.newspaper_rounded,
                      size: 40,
                      color: isDark
                          ? CliniqTheme.darkTextMuted
                          : CliniqTheme.lightTextMuted,
                    ),
                  ),
                ),
              ),

            // ─── Info ────────────────────────────
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source + Time
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? CliniqTheme.darkPrimary.withAlpha(25)
                              : CliniqTheme.lightPrimary.withAlpha(15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          news.source,
                          style: TextStyle(
                            color: isDark
                                ? CliniqTheme.darkPrimary
                                : CliniqTheme.lightPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        news.formattedDate,
                        style: TextStyle(
                          color: isDark
                              ? CliniqTheme.darkTextMuted
                              : CliniqTheme.lightTextMuted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Title
                  Text(
                    news.title,
                    style: TextStyle(
                      color:
                          isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (news.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      news.description,
                      style: TextStyle(
                        color: isDark
                            ? CliniqTheme.darkTextMuted
                            : CliniqTheme.lightTextMuted,
                        fontSize: 12,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 10),

                  // Read more
                  Row(
                    children: [
                      Text(
                        'Read full article',
                        style: TextStyle(
                          color: isDark
                              ? CliniqTheme.darkPrimary
                              : CliniqTheme.lightPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_outward_rounded,
                        size: 12,
                        color: isDark
                            ? CliniqTheme.darkPrimary
                            : CliniqTheme.lightPrimary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
