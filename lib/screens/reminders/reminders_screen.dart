import 'package:cliniq/screens/reminders/widgets/today_section.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/reminders_provider.dart';
import '../../models/reminder_model.dart';
import 'widgets/add_reminder_sheet.dart';
import 'widgets/edit_reminder_sheet.dart';
import 'widgets/reminder_card.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<RemindersProvider>().loadReminders();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _showAddSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.read<RemindersProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      // ✅ rootNavigator: true — bottom nav hide hoga
      useRootNavigator: true,
      builder: (_) => ChangeNotifierProvider.value(
        value: provider,
        child: AddReminderSheet(isDark: isDark),
      ),
    );
  }

  void _showEditSheet(ReminderModel reminder) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.read<RemindersProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (_) => ChangeNotifierProvider.value(
        value: provider,
        child: EditReminderSheet(
          reminder: reminder,
          isDark: isDark,
        ),
      ),
    );
  }

  void _showDeleteDialog(ReminderModel reminder) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor:
            isDark ? CliniqTheme.darkSurface : CliniqTheme.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Delete Reminder?',
          style: TextStyle(
            color: isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Remove reminder for ${reminder.medicineName}? This cannot be undone.',
          style: TextStyle(
            color:
                isDark ? CliniqTheme.darkTextMuted : CliniqTheme.lightTextMuted,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark
                    ? CliniqTheme.darkTextMuted
                    : CliniqTheme.lightTextMuted,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<RemindersProvider>().deleteReminder(reminder.id!);
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: CliniqTheme.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLoading = context.select<RemindersProvider, bool>(
      (p) => p.isLoading,
    );
    final todayReminders =
        context.select((RemindersProvider p) => p.todayReminders);
    final allReminders =
        context.select((RemindersProvider p) => p.allReminders);

    return Scaffold(
      backgroundColor: isDark ? CliniqTheme.darkBg : CliniqTheme.lightBg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            children: [
              // ── Header ──
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reminders',
                            style: TextStyle(
                              color: isDark
                                  ? CliniqTheme.darkText
                                  : CliniqTheme.lightText,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            allReminders.isEmpty
                                ? 'No medicines added'
                                : '${allReminders.length} medicine${allReminders.length == 1 ? '' : 's'} · ${todayReminders.length} active today',
                            style: TextStyle(
                              color: isDark
                                  ? CliniqTheme.darkTextMuted
                                  : CliniqTheme.lightTextMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Add button
                    GestureDetector(
                      onTap: _showAddSheet,
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: isDark
                              ? CliniqTheme.darkPrimary
                              : CliniqTheme.lightPrimary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Iconsax.add,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Content ──
              Expanded(
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: isDark
                              ? CliniqTheme.darkPrimary
                              : CliniqTheme.lightPrimary,
                          strokeWidth: 2,
                        ),
                      )
                    : allReminders.isEmpty
                        ? _EmptyState(
                            isDark: isDark,
                            onAdd: _showAddSheet,
                          )
                        : SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Today strip
                                if (todayReminders.isNotEmpty)
                                  TodayStrip(
                                    reminders: todayReminders,
                                    isDark: isDark,
                                  ),

                                // All reminders header
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(18, 0, 18, 10),
                                  child: Row(
                                    children: [
                                      Text(
                                        'ALL REMINDERS',
                                        style: TextStyle(
                                          color: isDark
                                              ? CliniqTheme.darkTextMuted
                                              : CliniqTheme.lightTextMuted,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.06,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '${allReminders.length} total',
                                        style: TextStyle(
                                          color: isDark
                                              ? CliniqTheme.darkPrimary
                                              : CliniqTheme.lightPrimary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Cards
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  itemCount: allReminders.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 8),
                                  itemBuilder: (context, index) {
                                    final r = allReminders[index];
                                    return ReminderCard(
                                      reminder: r,
                                      isDark: isDark,
                                      onToggle: () => context
                                          .read<RemindersProvider>()
                                          .toggleReminder(
                                            r.id!,
                                            !r.isActive,
                                          ),
                                      onEdit: () => _showEditSheet(r),
                                      onDelete: () => _showDeleteDialog(r),
                                    );
                                  },
                                ),

                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool isDark;
  final VoidCallback onAdd;

  const _EmptyState({
    required this.isDark,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color:
                    isDark ? CliniqTheme.darkSurface : CliniqTheme.lightSurface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color:
                      isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder,
                  width: 0.5,
                ),
              ),
              child: Icon(
                Iconsax.sticker,
                size: 36,
                color:
                    isDark ? CliniqTheme.darkPrimary : CliniqTheme.lightPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No reminders yet',
              style: TextStyle(
                color: isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your medicines and never miss a dose again',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark
                    ? CliniqTheme.darkTextMuted
                    : CliniqTheme.lightTextMuted,
                fontSize: 13,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Iconsax.add, size: 18),
                label: const Text(
                  'Add First Reminder',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? CliniqTheme.darkPrimary
                      : CliniqTheme.lightPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
