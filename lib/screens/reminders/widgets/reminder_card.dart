import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme.dart';
import '../../../models/reminder_model.dart';

class ReminderCard extends StatelessWidget {
  final ReminderModel reminder;
  final bool isDark;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ReminderCard({
    super.key,
    required this.reminder,
    required this.isDark,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  void _showOptions(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _OptionsSheet(
        reminder: reminder,
        isDark: isDark,
        onEdit: () {
          Navigator.pop(context);
          onEdit();
        },
        onToggle: () {
          Navigator.pop(context);
          onToggle();
        },
        onDelete: () {
          Navigator.pop(context);
          onDelete();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isActive = reminder.isActive;

    return GestureDetector(
      onLongPress: () => _showOptions(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? CliniqTheme.darkSurface : CliniqTheme.lightSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive
                ? (isDark
                    ? CliniqTheme.darkPrimary.withAlpha(60)
                    : CliniqTheme.lightPrimary.withAlpha(40))
                : (isDark ? CliniqTheme.darkBorder : const Color(0xFFF0EEF8)),
            width: isActive ? 1 : 0.5,
          ),
        ),
        child: Row(
          children: [
            // ── Icon ──
            // ── Icon / Image ──
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isActive
                    ? (isDark
                        ? CliniqTheme.darkSurface2
                        : CliniqTheme.lightSurface2)
                    : (isDark ? CliniqTheme.darkBg : const Color(0xFFF5F3FC)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: reminder.imagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(
                        File(reminder.imagePath!),
                        width: 46,
                        height: 46,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Iconsax.sticker,
                          size: 22,
                          color: isActive
                              ? (isDark
                                  ? CliniqTheme.darkPrimary
                                  : CliniqTheme.lightPrimary)
                              : (isDark
                                  ? CliniqTheme.darkTextMuted
                                  : CliniqTheme.lightTextMuted),
                        ),
                      ),
                    )
                  : Icon(
                      Iconsax.sticker,
                      size: 22,
                      color: isActive
                          ? (isDark
                              ? CliniqTheme.darkPrimary
                              : CliniqTheme.lightPrimary)
                          : (isDark
                              ? CliniqTheme.darkTextMuted
                              : CliniqTheme.lightTextMuted),
                    ),
            ),

            const SizedBox(width: 12),

            // ── Info ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.medicineName,
                    style: TextStyle(
                      color: isActive
                          ? (isDark
                              ? CliniqTheme.darkText
                              : CliniqTheme.lightText)
                          : (isDark
                              ? CliniqTheme.darkTextMuted
                              : CliniqTheme.lightTextMuted),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Time chips or paused badge
                  isActive
                      ? Wrap(
                          spacing: 5,
                          children: reminder.activeTimes
                              .map(
                                (t) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? CliniqTheme.darkPrimary.withAlpha(25)
                                        : CliniqTheme.lightPrimary
                                            .withAlpha(15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    t,
                                    style: TextStyle(
                                      color: isDark
                                          ? CliniqTheme.darkPrimary
                                          : CliniqTheme.lightPrimary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? CliniqTheme.darkBg
                                : const Color(0xFFF5F3FC),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Paused',
                            style: TextStyle(
                              color: isDark
                                  ? CliniqTheme.darkTextMuted
                                  : CliniqTheme.lightTextMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                  if (reminder.familyMember != 'Self') ...[
                    const SizedBox(height: 4),
                    Text(
                      'For: ${reminder.familyMember}',
                      style: TextStyle(
                        color: isDark
                            ? CliniqTheme.darkTextMuted
                            : CliniqTheme.lightTextMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 10),

            // ── Right Actions ──
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Toggle
                GestureDetector(
                  onTap: onToggle,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 44,
                    height: 24,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: isActive
                          ? (isDark
                              ? CliniqTheme.darkPrimary
                              : CliniqTheme.lightPrimary)
                          : (isDark
                              ? CliniqTheme.darkBorder
                              : const Color(0xFFE8E4F5)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 300),
                      alignment: isActive
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // More options
                GestureDetector(
                  onTap: () => _showOptions(context),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isDark
                          ? CliniqTheme.darkSurface2
                          : const Color(0xFFF5F3FC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Iconsax.more,
                      size: 16,
                      color: isDark
                          ? CliniqTheme.darkTextMuted
                          : CliniqTheme.lightTextMuted,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Options Sheet ─────────────────────────────────────
class _OptionsSheet extends StatelessWidget {
  final ReminderModel reminder;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _OptionsSheet({
    required this.reminder,
    required this.isDark,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? CliniqTheme.darkSurface : CliniqTheme.lightSurface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder,
          width: 0.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Medicine name + times
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark
                        ? CliniqTheme.darkSurface2
                        : CliniqTheme.lightSurface2,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Iconsax.sticker,
                    size: 20,
                    color: isDark
                        ? CliniqTheme.darkPrimary
                        : CliniqTheme.lightPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.medicineName,
                      style: TextStyle(
                        color: isDark
                            ? CliniqTheme.darkText
                            : CliniqTheme.lightText,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      reminder.activeTimes.join(' · '),
                      style: TextStyle(
                        color: isDark
                            ? CliniqTheme.darkTextMuted
                            : CliniqTheme.lightTextMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Divider(
            color: isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder,
            height: 1,
          ),

          // Edit
          _OptionTile(
            icon: Iconsax.edit,
            title: 'Edit Reminder',
            subtitle: 'Change time, days or medicine',
            isDark: isDark,
            color: isDark ? CliniqTheme.darkPrimary : CliniqTheme.lightPrimary,
            bgColor:
                isDark ? CliniqTheme.darkSurface2 : CliniqTheme.lightSurface2,
            onTap: onEdit,
          ),

          Divider(
            color: isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder,
            height: 1,
            indent: 16,
            endIndent: 16,
          ),

          // Pause/Resume
          _OptionTile(
            icon: reminder.isActive ? Iconsax.pause : Iconsax.play,
            title: reminder.isActive ? 'Pause Reminder' : 'Resume Reminder',
            subtitle: reminder.isActive
                ? 'Stop without deleting'
                : 'Start getting notifications again',
            isDark: isDark,
            color:
                isDark ? CliniqTheme.darkTextMuted : CliniqTheme.lightTextMuted,
            bgColor: isDark ? CliniqTheme.darkBg : const Color(0xFFF5F3FC),
            onTap: onToggle,
          ),

          Divider(
            color: isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder,
            height: 1,
            indent: 16,
            endIndent: 16,
          ),

          // Delete
          _OptionTile(
            icon: Iconsax.trash,
            title: 'Delete Reminder',
            subtitle: 'This cannot be undone',
            isDark: isDark,
            color: CliniqTheme.danger,
            bgColor: CliniqTheme.danger.withAlpha(20),
            onTap: onDelete,
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: color.withAlpha(150),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
