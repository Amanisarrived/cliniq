import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme.dart';
import '../../../models/reminder_model.dart';

class TodayStrip extends StatefulWidget {
  final List<ReminderModel> reminders;
  final bool isDark;

  const TodayStrip({
    super.key,
    required this.reminders,
    required this.isDark,
  });

  @override
  State<TodayStrip> createState() => _TodayStripState();
}

class _TodayStripState extends State<TodayStrip> {
  final Set<String> _takenKeys = {};

  String _key(ReminderModel r, String slot) => '${r.id}_$slot';

  List<_TodaySlot> get _slots {
    final slots = <_TodaySlot>[];
    for (final r in widget.reminders) {
      if (r.isMorning) {
        slots.add(_TodaySlot(
          reminder: r,
          slot: 'morning',
          time: r.morningTime,
          label: 'Morning',
        ));
      }
      if (r.isAfternoon) {
        slots.add(_TodaySlot(
          reminder: r,
          slot: 'afternoon',
          time: r.afternoonTime,
          label: 'Afternoon',
        ));
      }
      if (r.isNight) {
        slots.add(_TodaySlot(
          reminder: r,
          slot: 'night',
          time: r.nightTime,
          label: 'Night',
        ));
      }
    }
    // Sort by time
    slots.sort((a, b) => a.time.compareTo(b.time));
    return slots;
  }

  @override
  Widget build(BuildContext context) {
    final slots = _slots;
    if (slots.isEmpty) return const SizedBox.shrink();

    final takenCount = slots
        .where((s) => _takenKeys.contains(_key(s.reminder, s.slot)))
        .length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                slots.length > 3 ? "Today — ${slots.length} doses" : "Today",
                style: TextStyle(
                  color: widget.isDark
                      ? CliniqTheme.darkText
                      : CliniqTheme.lightText,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (slots.length > 3)
                Text(
                  '$takenCount/${slots.length} done',
                  style: TextStyle(
                    color: widget.isDark
                        ? CliniqTheme.darkPrimary
                        : CliniqTheme.lightPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                )
              else
                Text(
                  _formatDate(),
                  style: TextStyle(
                    color: widget.isDark
                        ? CliniqTheme.darkTextMuted
                        : CliniqTheme.lightTextMuted,
                    fontSize: 11,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          // Progress bar — only when many
          if (slots.length > 3) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: slots.isEmpty ? 0 : takenCount / slots.length,
                backgroundColor: widget.isDark
                    ? CliniqTheme.darkBorder
                    : const Color(0xFFE8E4F5),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF534AB7),
                ),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 10),
          ],

          // ✅ Smart layout
          slots.length <= 3
              ? _HorizontalCards(
                  slots: slots,
                  takenKeys: _takenKeys,
                  isDark: widget.isDark,
                  onTap: (key) => setState(() {
                    if (_takenKeys.contains(key)) {
                      _takenKeys.remove(key);
                    } else {
                      _takenKeys.add(key);
                    }
                  }),
                  keyBuilder: _key,
                )
              : _CompactList(
                  slots: slots,
                  takenKeys: _takenKeys,
                  isDark: widget.isDark,
                  onTap: (key) => setState(() {
                    if (_takenKeys.contains(key)) {
                      _takenKeys.remove(key);
                    } else {
                      _takenKeys.add(key);
                    }
                  }),
                  keyBuilder: _key,
                ),
        ],
      ),
    );
  }

  String _formatDate() {
    final now = DateTime.now();
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
      'Dec'
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }
}

// ── Horizontal Cards (≤3 slots) ──────────────────────
class _HorizontalCards extends StatelessWidget {
  final List<_TodaySlot> slots;
  final Set<String> takenKeys;
  final bool isDark;
  final Function(String) onTap;
  final String Function(ReminderModel, String) keyBuilder;

  const _HorizontalCards({
    required this.slots,
    required this.takenKeys,
    required this.isDark,
    required this.onTap,
    required this.keyBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: slots.asMap().entries.map((entry) {
        final slot = entry.value;
        final key = keyBuilder(slot.reminder, slot.slot);
        final taken = takenKeys.contains(key);

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: entry.key < slots.length - 1 ? 8 : 0,
            ),
            child: _HorizontalCard(
              slot: slot,
              taken: taken,
              isDark: isDark,
              onTap: () => onTap(key),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _HorizontalCard extends StatelessWidget {
  final _TodaySlot slot;
  final bool taken;
  final bool isDark;
  final VoidCallback onTap;

  const _HorizontalCard({
    required this.slot,
    required this.taken,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: taken
            ? const Color(0xFFE1F5EE)
            : (isDark ? CliniqTheme.darkSurface : CliniqTheme.lightSurface),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: taken
              ? const Color(0xFF9FE1CB)
              : (isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder),
          width: taken ? 1 : 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Slot label
          Text(
            slot.label.toUpperCase(),
            style: TextStyle(
              color: taken
                  ? const Color(0xFF0F6E56)
                  : (isDark
                      ? CliniqTheme.darkTextMuted
                      : CliniqTheme.lightTextMuted),
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.04,
            ),
          ),

          const SizedBox(height: 6),

          // Medicine name
          Text(
            slot.reminder.medicineName,
            style: TextStyle(
              color: taken
                  ? const Color(0xFF085041)
                  : (isDark ? CliniqTheme.darkText : CliniqTheme.lightText),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 2),

          // Time
          Text(
            _formatTime(slot.time),
            style: TextStyle(
              color: taken
                  ? const Color(0xFF0F6E56)
                  : (isDark
                      ? CliniqTheme.darkPrimary
                      : CliniqTheme.lightPrimary),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          // Button
          GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                color: taken
                    ? const Color(0xFF10B981)
                    : (isDark
                        ? CliniqTheme.darkSurface2
                        : CliniqTheme.lightSurface2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                taken ? '✓ Taken' : 'Take Now',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: taken
                      ? Colors.white
                      : (isDark
                          ? CliniqTheme.darkPrimary
                          : CliniqTheme.lightPrimary),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour > 12
        ? hour - 12
        : hour == 0
            ? 12
            : hour;
    return '$hour12:$minute $period';
  }
}

// ── Compact List (>3 slots) ───────────────────────────
class _CompactList extends StatelessWidget {
  final List<_TodaySlot> slots;
  final Set<String> takenKeys;
  final bool isDark;
  final Function(String) onTap;
  final String Function(ReminderModel, String) keyBuilder;

  const _CompactList({
    required this.slots,
    required this.takenKeys,
    required this.isDark,
    required this.onTap,
    required this.keyBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? CliniqTheme.darkSurface : CliniqTheme.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder,
          width: 0.5,
        ),
      ),
      child: Column(
        children: slots.asMap().entries.map((entry) {
          final i = entry.key;
          final slot = entry.value;
          final key = keyBuilder(slot.reminder, slot.slot);
          final taken = takenKeys.contains(key);
          final isLast = i == slots.length - 1;

          return _CompactItem(
            slot: slot,
            taken: taken,
            isDark: isDark,
            showDivider: !isLast,
            onTap: () => onTap(key),
          );
        }).toList(),
      ),
    );
  }
}

class _CompactItem extends StatelessWidget {
  final _TodaySlot slot;
  final bool taken;
  final bool isDark;
  final bool showDivider;
  final VoidCallback onTap;

  const _CompactItem({
    required this.slot,
    required this.taken,
    required this.isDark,
    required this.showDivider,
    required this.onTap,
  });

  Color get _slotColor {
    switch (slot.slot) {
      case 'morning':
        return const Color(0xFFF59E0B);
      case 'afternoon':
        return const Color(0xFFEF9F27);
      default:
        return const Color(0xFF534AB7);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Opacity(
          opacity: taken ? 0.7 : 1.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            child: Row(
              children: [
                // Icon
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: taken
                        ? const Color(0xFFE1F5EE)
                        : (isDark
                            ? CliniqTheme.darkSurface2
                            : CliniqTheme.lightSurface2),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    taken ? Iconsax.tick_circle : Iconsax.stacks_stx,
                    size: 15,
                    color: taken ? const Color(0xFF0F6E56) : _slotColor,
                  ),
                ),

                const SizedBox(width: 10),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slot.reminder.medicineName,
                        style: TextStyle(
                          color: taken
                              ? (isDark
                                  ? CliniqTheme.darkTextMuted
                                  : CliniqTheme.lightTextMuted)
                              : (isDark
                                  ? CliniqTheme.darkText
                                  : CliniqTheme.lightText),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          decoration: taken ? TextDecoration.lineThrough : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${slot.label} · ${_formatTime(slot.time)}',
                        style: TextStyle(
                          color: taken
                              ? const Color(0xFF10B981)
                              : (isDark
                                  ? CliniqTheme.darkTextMuted
                                  : CliniqTheme.lightTextMuted),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),

                // Action
                GestureDetector(
                  onTap: onTap,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: taken
                          ? const Color(0xFF10B981).withAlpha(20)
                          : (isDark
                              ? CliniqTheme.darkPrimary
                              : CliniqTheme.lightPrimary),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      taken ? 'Done' : 'Take',
                      style: TextStyle(
                        color: taken ? const Color(0xFF10B981) : Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder,
            indent: 12,
            endIndent: 12,
          ),
      ],
    );
  }

  String _formatTime(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour > 12
        ? hour - 12
        : hour == 0
            ? 12
            : hour;
    return '$hour12:$minute $period';
  }
}

// ── Data Model ────────────────────────────────────────
class _TodaySlot {
  final ReminderModel reminder;
  final String slot;
  final String time;
  final String label;

  const _TodaySlot({
    required this.reminder,
    required this.slot,
    required this.time,
    required this.label,
  });
}
