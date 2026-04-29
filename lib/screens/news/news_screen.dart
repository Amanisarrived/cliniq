import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/news_provider.dart';
import 'widgets/news_card.dart';
import 'widgets/news_empty_state.dart';
import 'widgets/news_error_state.dart';
import 'widgets/news_header.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<NewsProvider>().fetchNews();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<NewsProvider>();

    return Scaffold(
      backgroundColor: isDark ? CliniqTheme.darkBg : CliniqTheme.lightBg,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ──────────────────────────
            NewsHeader(
              isDark: isDark,
              isLoading: provider.isLoading,
              onRefresh: () => context.read<NewsProvider>().refresh(),
            ),

            const SizedBox(height: 16),

            // ─── Content ─────────────────────────
            Expanded(
              child: _buildContent(context, isDark, provider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    bool isDark,
    NewsProvider provider,
  ) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return NewsErrorState(
        isDark: isDark,
        onRetry: () => context.read<NewsProvider>().fetchNews(),
      );
    }

    if (!provider.hasNews) {
      return NewsEmptyState(isDark: isDark);
    }

    return RefreshIndicator(
      onRefresh: () => context.read<NewsProvider>().refresh(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        itemCount: provider.news.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final news = provider.news[index];
          return NewsCard(
            news: news,
            isDark: isDark,
          );
        },
      ),
    );
  }
}
