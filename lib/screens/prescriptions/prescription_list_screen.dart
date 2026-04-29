import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/prescription_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/prescription_model.dart';
import 'add_prescription_screen.dart';
import 'prescription_detail_screen.dart';
import 'widgets/prescription_card.dart';

class PrescriptionListScreen extends StatefulWidget {
  const PrescriptionListScreen({super.key});

  @override
  State<PrescriptionListScreen> createState() =>
      _Pr9yMnTm4NSzvG9rrwjM2ec8xZgh1cafXH8();
}

class _Pr9yMnTm4NSzvG9rrwjM2ec8xZgh1cafXH8
    extends State<PrescriptionListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<UserProvider>().user?.uid;
      if (uid != null) {
        context.read<PrescriptionProvider>().listenToPrescriptions(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<PrescriptionProvider>();
    final userProvider = context.watch<UserProvider>();
    final isPro = userProvider.user?.isPro ?? false;
    final prescriptions = provider.prescriptions;

    return Scaffold(
      backgroundColor: isDark ? CliniqTheme.darkBg : CliniqTheme.lightBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(isDark: isDark),
            if (!isPro)
              _FreeLimitBanner(isDark: isDark, count: prescriptions.length),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : prescriptions.isEmpty
                      ? _EmptyState(isDark: isDark)
                      : _PrescriptionList(
                          prescriptions: prescriptions,
                          isDark: isDark,
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          _AddFab(isDark: isDark, isPro: isPro, count: prescriptions.length),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final bool isDark;
  const _Header({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark
                  ? CliniqTheme.darkPrimary.withAlpha(30)
                  : CliniqTheme.lightPrimary.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Iconsax.document_text,
              color:
                  isDark ? CliniqTheme.darkPrimary : CliniqTheme.lightPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Prescription Vault',
                style: TextStyle(
                  color: isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Keep your prescriptions safe',
                style: TextStyle(
                  color: isDark
                      ? CliniqTheme.darkTextMuted
                      : CliniqTheme.lightTextMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FreeLimitBanner extends StatelessWidget {
  final bool isDark;
  final int count;
  const _FreeLimitBanner({required this.isDark, required this.count});

  @override
  Widget build(BuildContext context) {
    final remaining = PrescriptionProvider.freePrescriptionLimit - count;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? CliniqTheme.darkPrimary.withAlpha(25)
            : CliniqTheme.lightPrimary.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? CliniqTheme.darkPrimary.withAlpha(60)
              : CliniqTheme.lightPrimary.withAlpha(40),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Iconsax.info_circle,
            size: 16,
            color: isDark ? CliniqTheme.darkPrimary : CliniqTheme.lightPrimary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              remaining > 0
                  ? '$remaining prescription${remaining == 1 ? '' : 's'} remaining on free plan'
                  : 'Free limit reached! Upgrade to Pro for unlimited',
              style: TextStyle(
                color:
                    isDark ? CliniqTheme.darkPrimary : CliniqTheme.lightPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrescriptionList extends StatelessWidget {
  final List<PrescriptionModel> prescriptions;
  final bool isDark;

  const _PrescriptionList({
    required this.prescriptions,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      itemCount: prescriptions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final p = prescriptions[index];
        return PrescriptionCard(
          prescription: p,
          isDark: isDark,
          onTap: () => Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (_) => PrescriptionDetailScreen(prescription: p),
            ),
          ),
          onDelete: () => _confirmDelete(context, p),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, PrescriptionModel p) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor:
          isDark ? CliniqTheme.darkSurface : CliniqTheme.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color:
                    isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Icon(Iconsax.trash, color: CliniqTheme.danger, size: 32),
            const SizedBox(height: 12),
            Text(
              'Delete Prescription?',
              style: TextStyle(
                color: isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'This prescription will be permanently deleted',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark
                    ? CliniqTheme.darkTextMuted
                    : CliniqTheme.lightTextMuted,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                        color: isDark
                            ? CliniqTheme.darkBorder
                            : CliniqTheme.lightBorder,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: isDark
                            ? CliniqTheme.darkText
                            : CliniqTheme.lightText,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      final uid = context.read<UserProvider>().user?.uid ?? '';
                      await context
                          .read<PrescriptionProvider>()
                          .deletePrescription(uid, p);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CliniqTheme.danger,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.white),
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

class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color:
                  isDark ? CliniqTheme.darkSurface2 : CliniqTheme.lightSurface2,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Iconsax.document_text,
              size: 36,
              color: isDark
                  ? CliniqTheme.darkTextMuted
                  : CliniqTheme.lightTextMuted,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No prescriptions yet',
            style: TextStyle(
              color: isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap the + button below to add one',
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
}

class _AddFab extends StatefulWidget {
  final bool isDark;
  final bool isPro;
  final int count;

  const _AddFab({
    required this.isDark,
    required this.isPro,
    required this.count,
  });

  @override
  State<_AddFab> createState() => _AddFabState();
}

class _AddFabState extends State<_AddFab> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _widthFactor;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _widthFactor = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _opacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canAdd = widget.isPro ||
        widget.count < PrescriptionProvider.freePrescriptionLimit;

    return GestureDetector(
      onTap: canAdd
          ? () => Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (_) => const AddPrescriptionScreen(),
                ),
              )
          : () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Free limit reached! Upgrade to Pro for unlimited'),
                ),
              ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: widget.isDark
                  ? CliniqTheme.darkPrimary
                  : CliniqTheme.lightPrimary,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: (widget.isDark
                          ? CliniqTheme.darkPrimary
                          : CliniqTheme.lightPrimary)
                      .withAlpha(100),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ✅ Text animates away
                ClipRect(
                  child: Align(
                    alignment: Alignment.centerRight,
                    widthFactor: 1.0 - _widthFactor.value,
                    child: FadeTransition(
                      opacity: ReverseAnimation(_opacity),
                      child: const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Text(
                          'Add Prescription',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ✅ Icon always visible
                const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
