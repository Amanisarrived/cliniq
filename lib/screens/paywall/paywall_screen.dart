import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../core/theme.dart';
import '../../providers/purchase_provider.dart';
import '../../providers/user_provider.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PurchaseProvider>().loadOfferings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<PurchaseProvider>();

    return Scaffold(
      backgroundColor: isDark ? CliniqTheme.darkBg : CliniqTheme.lightBg,
      body: SafeArea(
        child: Column(
          children: [
            // ─── AppBar ───────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Iconsax.arrow_left,
                      color:
                          isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // ─── Scrollable Content ───────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: Column(
                  children: [
                    // ─── Logo ─────────────────────
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: (isDark
                                    ? CliniqTheme.darkPrimary
                                    : CliniqTheme.lightPrimary)
                                .withAlpha(80),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Image.asset(
                          'assets/images/cliniq_logo (1).png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'Cliniq Pro',
                      style: TextStyle(
                        color: isDark
                            ? CliniqTheme.darkText
                            : CliniqTheme.lightText,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Unlimited access to all features',
                      style: TextStyle(
                        color: isDark
                            ? CliniqTheme.darkTextMuted
                            : CliniqTheme.lightTextMuted,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ─── Features List ─────────────
                    _FeaturesList(isDark: isDark),

                    const SizedBox(height: 32),

                    // ─── Pricing Card ──────────────
                    if (provider.isLoading)
                      const CircularProgressIndicator()
                    else if (provider.offerings?.current != null)
                      _PricingCard(
                        offerings: provider.offerings!,
                        isDark: isDark,
                        onPurchase: (package) async {
                          await context
                              .read<PurchaseProvider>()
                              .purchase(package);
                          if (!mounted) return;
                          final p = context.read<PurchaseProvider>();
                          if (p.status == PurchaseStatus.success) {
                            final uid = context.read<UserProvider>().user?.uid;
                            if (uid != null) {
                              context.read<UserProvider>().listenToUser(uid);
                            }
                            _showSuccess();
                          } else if (p.error != null) {
                            _showError(p.error!);
                          }
                        },
                        isLoading: provider.isLoading,
                      )
                    else
                      _NoOfferingsCard(isDark: isDark),

                    const SizedBox(height: 16),

                    // ─── Restore ──────────────────
                    TextButton(
                      onPressed: () async {
                        await context
                            .read<PurchaseProvider>()
                            .restorePurchases();
                        if (!mounted) return;
                        final p = context.read<PurchaseProvider>();
                        if (p.isPro) {
                          final uid = context.read<UserProvider>().user?.uid;
                          if (uid != null) {
                            context.read<UserProvider>().listenToUser(uid);
                          }
                          _showSuccess();
                        } else if (p.error != null) {
                          _showError(p.error!);
                        }
                      },
                      child: Text(
                        'Restore Purchases',
                        style: TextStyle(
                          color: isDark
                              ? CliniqTheme.darkTextMuted
                              : CliniqTheme.lightTextMuted,
                          fontSize: 13,
                        ),
                      ),
                    ),

                    // ─── Error ────────────────────
                    if (provider.error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          provider.error!,
                          style: const TextStyle(
                            color: CliniqTheme.danger,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    const SizedBox(height: 16),

                    // ─── Terms ────────────────────
                    Text(
                      'Subscription auto-renews monthly. Cancel anytime.',
                      style: TextStyle(
                        color: isDark
                            ? CliniqTheme.darkTextMuted
                            : CliniqTheme.lightTextMuted,
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccess() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎉 Welcome to Cliniq Pro!'),
        backgroundColor: CliniqTheme.success,
      ),
    );
  }

  void _showError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: CliniqTheme.danger,
      ),
    );
  }
}

// ─── Features List ────────────────────────────────────────────────

class _FeaturesList extends StatelessWidget {
  final bool isDark;
  const _FeaturesList({required this.isDark});

  static const List<_Feature> _features = [
    _Feature(
      icon: Iconsax.flash,
      title: 'Unlimited AI Scans',
      subtitle: 'Scan as many medicines as you want',
    ),
    _Feature(
      icon: Iconsax.document_text,
      title: 'Unlimited Prescriptions',
      subtitle: 'Save all your prescriptions',
    ),
    _Feature(
      icon: Iconsax.health,
      title: 'Unlimited Health Guides',
      subtitle: 'Get health guidance anytime',
    ),
    _Feature(
      icon: Iconsax.gallery,
      title: 'Multiple Photos',
      subtitle: 'Add up to 5 photos per prescription',
    ),
    _Feature(
      icon: Iconsax.notification,
      title: 'Priority Support',
      subtitle: 'Get help when you need it',
    ),
  ];

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
      child: Column(
        children: _features
            .map((f) => _FeatureTile(feature: f, isDark: isDark))
            .toList(),
      ),
    );
  }
}

class _Feature {
  final IconData icon;
  final String title;
  final String subtitle;
  const _Feature({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class _FeatureTile extends StatelessWidget {
  final _Feature feature;
  final bool isDark;

  const _FeatureTile({required this.feature, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDark
                  ? CliniqTheme.darkPrimary.withAlpha(25)
                  : CliniqTheme.lightPrimary.withAlpha(15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              feature.icon,
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
                  feature.title,
                  style: TextStyle(
                    color:
                        isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  feature.subtitle,
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
          const Icon(
            Iconsax.tick_circle,
            size: 18,
            color: CliniqTheme.success,
          ),
        ],
      ),
    );
  }
}

// ─── Pricing Card ─────────────────────────────────────────────────

class _PricingCard extends StatelessWidget {
  final Offerings offerings;
  final bool isDark;
  final Function(Package) onPurchase;
  final bool isLoading;

  const _PricingCard({
    required this.offerings,
    required this.isDark,
    required this.onPurchase,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final package = offerings.current?.availablePackages.firstOrNull;
    if (package == null) return const SizedBox.shrink();

    final price = package.storeProduct.priceString;

    return Container(
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
            color: (isDark ? CliniqTheme.darkPrimary : CliniqTheme.lightPrimary)
                .withAlpha(80),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text(
                  '/month',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            '🎉 Early Bird Price — Limited Time!',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: isLoading ? null : () => onPurchase(package),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor:
                    isDark ? CliniqTheme.darkPrimary : CliniqTheme.lightPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: isDark
                            ? CliniqTheme.darkPrimary
                            : CliniqTheme.lightPrimary,
                      ),
                    )
                  : const Text(
                      'Upgrade to Pro',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── No Offerings Card ────────────────────────────────────────────

class _NoOfferingsCard extends StatelessWidget {
  final bool isDark;
  const _NoOfferingsCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? CliniqTheme.darkSurface : CliniqTheme.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Iconsax.warning_2,
            color: CliniqTheme.warning,
            size: 32,
          ),
          const SizedBox(height: 10),
          Text(
            'Plans unavailable',
            style: TextStyle(
              color: isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Please check your connection and try again',
            style: TextStyle(
              color: isDark
                  ? CliniqTheme.darkTextMuted
                  : CliniqTheme.lightTextMuted,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
