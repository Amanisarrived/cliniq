import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../models/diary_entry_model.dart';

class WeeklySummaryCard extends StatelessWidget {
  final Map<String, dynamic> stats;
  final bool isDark;

  const WeeklySummaryCard({
    super.key,
    required this.stats,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) return const SizedBox.shrink();

    final avgMood = (stats['avgMood'] as double?) ?? 0;
    final avgWater = (stats['avgWater'] as double?) ?? 0;
    final adherence = (stats['adherence'] as int?) ?? 0;
    final checkInDays = (stats['checkInDays'] as int?) ?? 0;
    final entries = (stats['entries'] as List<DiaryEntryModel>?) ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? CliniqTheme.darkSurface : CliniqTheme.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                '📊',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 8),
              Text(
                'This Week',
                style: TextStyle(
                  color: isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '$checkInDays/7 days',
                style: TextStyle(
                  color: isDark
                      ? CliniqTheme.darkTextMuted
                      : CliniqTheme.lightTextMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Stats row
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  emoji: _getMoodEmoji(avgMood),
                  label: 'Avg Mood',
                  value: _getMoodLabel(avgMood),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatItem(
                  emoji: '💧',
                  label: 'Avg Water',
                  value: '${avgWater.toStringAsFixed(1)}g',
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatItem(
                  emoji: '💊',
                  label: 'Medicines',
                  value: '$adherence%',
                  isDark: isDark,
                  valueColor: adherence >= 80
                      ? CliniqTheme.success
                      : adherence >= 50
                          ? CliniqTheme.warning
                          : CliniqTheme.danger,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Mood timeline
          if (entries.isNotEmpty) ...[
            Text(
              'Mood this week',
              style: TextStyle(
                color: isDark
                    ? CliniqTheme.darkTextMuted
                    : CliniqTheme.lightTextMuted,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            _MoodTimeline(entries: entries, isDark: isDark),
          ],
        ],
      ),
    );
  }

  String _getMoodEmoji(double mood) {
    if (mood >= 4.5) return '🤩';
    if (mood >= 3.5) return '😊';
    if (mood >= 2.5) return '🙂';
    if (mood >= 1.5) return '😐';
    return '😴';
  }

  String _getMoodLabel(double mood) {
    if (mood >= 4.5) return 'Amazing';
    if (mood >= 3.5) return 'Great';
    if (mood >= 2.5) return 'Good';
    if (mood >= 1.5) return 'Okay';
    return 'Low';
  }
}

// ─── Stat Item ────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final bool isDark;
  final Color? valueColor;

  const _StatItem({
    required this.emoji,
    required this.label,
    required this.value,
    required this.isDark,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? CliniqTheme.darkBg : CliniqTheme.lightBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: valueColor ??
                  (isDark ? CliniqTheme.darkText : CliniqTheme.lightText),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: isDark
                  ? CliniqTheme.darkTextMuted
                  : CliniqTheme.lightTextMuted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Mood Timeline ────────────────────────────────────────────────

class _MoodTimeline extends StatelessWidget {
  final List<DiaryEntryModel> entries;
  final bool isDark;

  const _MoodTimeline({required this.entries, required this.isDark});

  @override
  Widget build(BuildContext context) {
    // Last 7 days
    final now = DateTime.now();
    final days = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return day;
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((day) {
        final dateStr = day.toIso8601String().split('T')[0];
        final entry = entries.firstWhere(
          (e) => e.date.toIso8601String().split('T')[0] == dateStr,
          orElse: () => DiaryEntryModel(
            date: day,
            mood: 0,
            symptoms: [],
            waterGlasses: 0,
            medicines: [],
            createdAt: day,
          ),
        );

        final hasEntry = entry.mood > 0;

        return Column(
          children: [
            Text(
              hasEntry ? entry.moodEmoji : '○',
              style: TextStyle(
                fontSize: hasEntry ? 18 : 14,
                color: hasEntry
                    ? null
                    : (isDark
                        ? CliniqTheme.darkBorder
                        : CliniqTheme.lightBorder),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _dayLabel(day),
              style: TextStyle(
                color: isDark
                    ? CliniqTheme.darkTextMuted
                    : CliniqTheme.lightTextMuted,
                fontSize: 9,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  String _dayLabel(DateTime day) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return days[day.weekday - 1];
  }
}
