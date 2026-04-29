import 'package:cliniq/screens/diary/widgets/checkin_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/diary_provider.dart';
import 'widgets/streak_banner.dart';
import 'widgets/weekly_summary_card.dart';
import '../../models/diary_entry_model.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic> _weeklyStats = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await context.read<DiaryProvider>().loadToday();
      if (!mounted) return;
      await context.read<DiaryProvider>().loadAllEntries();
      if (!mounted) return;
      final stats = await context.read<DiaryProvider>().getWeeklyStats();
      if (!mounted) return;
      setState(() => _weeklyStats = stats);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _openCheckIn(bool isDark) async {
    final result = await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => const CheckInScreen()),
    );
    if (!mounted) return;
    if (result == true) {
      await context.read<DiaryProvider>().loadToday();
      if (!mounted) return;
      await context.read<DiaryProvider>().loadAllEntries();
      if (!mounted) return;
      final stats = await context.read<DiaryProvider>().getWeeklyStats();
      if (!mounted) return;
      setState(() => _weeklyStats = stats);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<DiaryProvider>();

    return Scaffold(
      backgroundColor: isDark ? CliniqTheme.darkBg : CliniqTheme.lightBg,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ──────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sehat Diary',
                        style: TextStyle(
                          color: isDark
                              ? CliniqTheme.darkText
                              : CliniqTheme.lightText,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Track your daily health',
                        style: TextStyle(
                          color: isDark
                              ? CliniqTheme.darkTextMuted
                              : CliniqTheme.lightTextMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (provider.streak > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35).withAlpha(20),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFFF6B35).withAlpha(60),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Text(
                            '${provider.streak}',
                            style: const TextStyle(
                              color: Color(0xFFFF6B35),
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ─── Tab Bar ──────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? CliniqTheme.darkSurface
                      : CliniqTheme.lightSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: isDark
                        ? CliniqTheme.darkPrimary
                        : CliniqTheme.lightPrimary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: isDark
                      ? CliniqTheme.darkTextMuted
                      : CliniqTheme.lightTextMuted,
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: const [
                    Tab(text: 'Today'),
                    Tab(text: 'History'),
                    Tab(text: 'Insights'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ─── Tab Views ────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _TodayTab(
                    isDark: isDark,
                    provider: provider,
                    weeklyStats: _weeklyStats,
                    onCheckIn: () => _openCheckIn(isDark),
                  ),
                  _HistoryTab(
                    isDark: isDark,
                    entries: provider.allEntries,
                  ),
                  _InsightsTab(
                    isDark: isDark,
                    weeklyStats: _weeklyStats,
                    entries: provider.allEntries,
                    aiInsights: provider.aiInsights,
                    isGeneratingInsights: provider.isGeneratingInsights,
                    daysUntilNextInsight: provider.daysUntilNextInsight,
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

// ─── Today Tab ────────────────────────────────────────────────────

class _TodayTab extends StatelessWidget {
  final bool isDark;
  final DiaryProvider provider;
  final Map<String, dynamic> weeklyStats;
  final VoidCallback onCheckIn;

  const _TodayTab({
    required this.isDark,
    required this.provider,
    required this.weeklyStats,
    required this.onCheckIn,
  });

  @override
  Widget build(BuildContext context) {
    final hasCheckedIn = provider.hasCheckedInToday;
    final today = provider.todayEntry;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (provider.streak > 0) ...[
            StreakBanner(streak: provider.streak, isDark: isDark),
            const SizedBox(height: 16),
          ],
          if (!hasCheckedIn)
            _CheckInPrompt(isDark: isDark, onCheckIn: onCheckIn)
          else
            _TodaySummary(isDark: isDark, entry: today!),
          const SizedBox(height: 20),
          if (weeklyStats.isNotEmpty) ...[
            Text(
              'THIS WEEK',
              style: TextStyle(
                color: isDark
                    ? CliniqTheme.darkTextMuted
                    : CliniqTheme.lightTextMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),
            WeeklySummaryCard(stats: weeklyStats, isDark: isDark),
          ],
        ],
      ),
    );
  }
}

// ─── Check-in Prompt ─────────────────────────────────────────────

class _CheckInPrompt extends StatelessWidget {
  final bool isDark;
  final VoidCallback onCheckIn;

  const _CheckInPrompt({required this.isDark, required this.onCheckIn});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCheckIn,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isDark ? CliniqTheme.darkPrimary : CliniqTheme.lightPrimary,
              isDark
                  ? CliniqTheme.darkPrimary.withAlpha(180)
                  : CliniqTheme.lightPrimary.withAlpha(180),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color:
                  (isDark ? CliniqTheme.darkPrimary : CliniqTheme.lightPrimary)
                      .withAlpha(80),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🌟 Aaj ka check-in',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'How are you feeling today?',
                    style: TextStyle(
                      color: Colors.white.withAlpha(200),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(30),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Start Check-in →',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Text('📋', style: TextStyle(fontSize: 48)),
          ],
        ),
      ),
    );
  }
}

// ─── Today Summary ────────────────────────────────────────────────

class _TodaySummary extends StatelessWidget {
  final bool isDark;
  final DiaryEntryModel entry;

  const _TodaySummary({required this.isDark, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? CliniqTheme.darkSurface : CliniqTheme.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: CliniqTheme.success.withAlpha(60),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(entry.moodEmoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today — ${entry.moodLabel}',
                    style: TextStyle(
                      color:
                          isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Text(
                    '✅ Check-in complete!',
                    style: TextStyle(
                      color: CliniqTheme.success,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _TodayChip(
                label: '💧 ${entry.waterGlasses}g',
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              if (entry.symptoms.isEmpty)
                _TodayChip(label: '✅ No symptoms', isDark: isDark)
              else
                _TodayChip(
                  label: '⚠️ ${entry.symptoms.length} symptoms',
                  isDark: isDark,
                ),
              const SizedBox(width: 8),
              if (entry.medicines.isNotEmpty)
                _TodayChip(
                  label:
                      '💊 ${entry.medicinesTakenCount}/${entry.medicines.length}',
                  isDark: isDark,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TodayChip extends StatelessWidget {
  final String label;
  final bool isDark;

  const _TodayChip({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? CliniqTheme.darkBg : CliniqTheme.lightBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ─── History Tab ──────────────────────────────────────────────────

class _HistoryTab extends StatelessWidget {
  final bool isDark;
  final List<DiaryEntryModel> entries;

  const _HistoryTab({
    required this.isDark,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📔', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'No entries yet',
              style: TextStyle(
                color: isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Start your first check-in!',
              style: TextStyle(
                color: isDark
                    ? CliniqTheme.darkTextMuted
                    : CliniqTheme.lightTextMuted,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _HistoryCard(entry: entry, isDark: isDark);
      },
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final DiaryEntryModel entry;
  final bool isDark;

  const _HistoryCard({required this.entry, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? CliniqTheme.darkSurface : CliniqTheme.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                '${entry.date.day}',
                style: TextStyle(
                  color: isDark
                      ? CliniqTheme.darkPrimary
                      : CliniqTheme.lightPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                _monthLabel(entry.date.month),
                style: TextStyle(
                  color: isDark
                      ? CliniqTheme.darkTextMuted
                      : CliniqTheme.lightTextMuted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Container(
            width: 1,
            height: 40,
            color: isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(entry.moodEmoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      entry.moodLabel,
                      style: TextStyle(
                        color: isDark
                            ? CliniqTheme.darkText
                            : CliniqTheme.lightText,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    '💧 ${entry.waterGlasses}g',
                    if (entry.symptoms.isNotEmpty) '⚠️ ${entry.symptoms.first}',
                    if (entry.medicines.isNotEmpty)
                      '💊 ${entry.medicinesTakenCount}/${entry.medicines.length}',
                  ].join(' · '),
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
        ],
      ),
    );
  }

  String _monthLabel(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}

// ─── Insights Tab ─────────────────────────────────────────────────

class _InsightsTab extends StatelessWidget {
  final bool isDark;
  final Map<String, dynamic> weeklyStats;
  final List<DiaryEntryModel> entries;
  final String? aiInsights;
  final bool isGeneratingInsights;
  final int daysUntilNextInsight;

  const _InsightsTab({
    required this.isDark,
    required this.weeklyStats,
    required this.entries,
    required this.aiInsights,
    required this.isGeneratingInsights,
    required this.daysUntilNextInsight,
  });

  @override
  Widget build(BuildContext context) {
    if (weeklyStats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('✨', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'Not enough data yet',
              style: TextStyle(
                color: isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Check-in for a few days to see insights',
              style: TextStyle(
                color: isDark
                    ? CliniqTheme.darkTextMuted
                    : CliniqTheme.lightTextMuted,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    final avgMood = (weeklyStats['avgMood'] as double?) ?? 0;
    final avgWater = (weeklyStats['avgWater'] as double?) ?? 0;
    final adherence = (weeklyStats['adherence'] as int?) ?? 0;
    final checkInDays = (weeklyStats['checkInDays'] as int?) ?? 0;
    final symptomCount =
        (weeklyStats['symptomCount'] as Map<String, int>?) ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WeeklySummaryCard(stats: weeklyStats, isDark: isDark),
          const SizedBox(height: 20),

          Text(
            'INSIGHTS',
            style: TextStyle(
              color: isDark
                  ? CliniqTheme.darkTextMuted
                  : CliniqTheme.lightTextMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),

          _InsightCard(
            emoji: '😊',
            title: 'Mood',
            insight: avgMood >= 3.5
                ? 'Your mood has been great this week! Keep it up.'
                : avgMood >= 2.5
                    ? 'Your mood has been average. Try to get more rest.'
                    : 'Your mood has been low. Consider talking to someone.',
            color: isDark ? CliniqTheme.darkPrimary : CliniqTheme.lightPrimary,
            isDark: isDark,
          ),
          const SizedBox(height: 10),

          _InsightCard(
            emoji: '💧',
            title: 'Hydration',
            insight: avgWater >= 8
                ? 'Excellent hydration! You\'re drinking enough water.'
                : avgWater >= 5
                    ? 'Good hydration. Try to drink ${(8 - avgWater).round()} more glasses daily.'
                    : 'You need to drink more water. Aim for 8 glasses daily.',
            color: const Color(0xFF185FA5),
            isDark: isDark,
          ),
          const SizedBox(height: 10),

          if (adherence > 0) ...[
            _InsightCard(
              emoji: '💊',
              title: 'Medicine Adherence',
              insight: adherence >= 80
                  ? 'Great job taking your medicines regularly! $adherence% adherence.'
                  : adherence >= 50
                      ? 'Try to be more consistent with medicines. $adherence% adherence.'
                      : 'You\'re missing medicines often. Set reminders to help.',
              color:
                  adherence >= 80 ? CliniqTheme.success : CliniqTheme.warning,
              isDark: isDark,
            ),
            const SizedBox(height: 10),
          ],

          if (symptomCount.isNotEmpty) ...[
            _InsightCard(
              emoji: '⚠️',
              title: 'Common Symptoms',
              insight:
                  'Most frequent: ${symptomCount.entries.reduce((a, b) => a.value > b.value ? a : b).key}. '
                  'If persisting, consider consulting a doctor.',
              color: CliniqTheme.warning,
              isDark: isDark,
            ),
            const SizedBox(height: 10),
          ],

          _InsightCard(
            emoji: '🔥',
            title: 'Consistency',
            insight: checkInDays >= 6
                ? 'Amazing! You\'ve checked in $checkInDays/7 days this week!'
                : checkInDays >= 4
                    ? 'Good effort! $checkInDays/7 days. Try to check in daily.'
                    : 'You\'ve only checked in $checkInDays days. Daily check-ins give better insights.',
            color: const Color(0xFFFF6B35),
            isDark: isDark,
          ),

          const SizedBox(height: 20),

          // ─── AI Analysis ──────────────────────
          Text(
            'AI ANALYSIS',
            style: TextStyle(
              color: isDark
                  ? CliniqTheme.darkTextMuted
                  : CliniqTheme.lightTextMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),

          if (aiInsights != null) ...[
            // ✅ AI Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    isDark
                        ? CliniqTheme.darkPrimary.withAlpha(30)
                        : CliniqTheme.lightPrimary.withAlpha(20),
                    Colors.transparent,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? CliniqTheme.darkPrimary.withAlpha(60)
                      : CliniqTheme.lightPrimary.withAlpha(40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('✨', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(
                        'AI Health Coach',
                        style: TextStyle(
                          color: isDark
                              ? CliniqTheme.darkPrimary
                              : CliniqTheme.lightPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    aiInsights!,
                    style: TextStyle(
                      color:
                          isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ✅ Days remaining
            Center(
              child: Text(
                daysUntilNextInsight == 0
                    ? 'You can generate a new analysis!'
                    : 'Next analysis in $daysUntilNextInsight days',
                style: TextStyle(
                  color: isDark
                      ? CliniqTheme.darkTextMuted
                      : CliniqTheme.lightTextMuted,
                  fontSize: 11,
                ),
              ),
            ),
          ] else ...[
            // ✅ Generate button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: isGeneratingInsights
                    ? null
                    : () => context.read<DiaryProvider>().generateAiInsights(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? CliniqTheme.darkPrimary
                      : CliniqTheme.lightPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: isGeneratingInsights
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('✨', style: TextStyle(fontSize: 16)),
                label: Text(
                  isGeneratingInsights
                      ? 'Analyzing...'
                      : 'Generate AI Analysis',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Insight Card ─────────────────────────────────────────────────

class _InsightCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String insight;
  final Color color;
  final bool isDark;

  const _InsightCard({
    required this.emoji,
    required this.title,
    required this.insight,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? CliniqTheme.darkSurface : CliniqTheme.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withAlpha(isDark ? 60 : 40),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 18)),
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
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight,
                  style: TextStyle(
                    color:
                        isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
                    fontSize: 12,
                    height: 1.5,
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
