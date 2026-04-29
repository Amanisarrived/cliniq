import 'package:cliniq/providers/sickeness_guide_provider.dart';
import 'package:cliniq/screens/sickness/widgets/symptoms_chips.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/user_provider.dart';
import 'widgets/ai_bubble.dart';
import 'widgets/user_bubble.dart';
import 'widgets/loading_dots.dart';
import 'widgets/guide_content.dart';
import 'widgets/no_credits_content.dart';
import 'widgets/guide_input_bar.dart';

class SicknessGuideScreen extends StatefulWidget {
  const SicknessGuideScreen({super.key});

  @override
  State<SicknessGuideScreen> createState() => _SicknessGuideScreenState();
}

class _SicknessGuideScreenState extends State<SicknessGuideScreen> {
  final _symptomsController = TextEditingController();
  final _answersController = TextEditingController();
  final _followUpController = TextEditingController();
  final _scrollController = ScrollController();
  final List<String> _selectedChips = [];

  @override
  void dispose() {
    _symptomsController.dispose();
    _answersController.dispose();
    _followUpController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onChipTap(String chip) {
    setState(() {
      if (_selectedChips.contains(chip)) {
        _selectedChips.remove(chip);
      } else {
        _selectedChips.add(chip);
      }
      _symptomsController.text = _selectedChips.join(', ');
      _symptomsController.selection = TextSelection.fromPosition(
        TextPosition(offset: _symptomsController.text.length),
      );
    });
  }

  Future<void> _submitSymptoms() async {
    final text = _symptomsController.text.trim();
    if (text.isEmpty) return;
    FocusScope.of(context).unfocus();
    await context.read<SicknessGuideProvider>().submitSymptoms(text);
    if (!mounted) return;
    _scrollToBottom();
  }

  Future<void> _submitAnswers() async {
    final text = _answersController.text.trim();
    if (text.isEmpty) return;
    FocusScope.of(context).unfocus();
    await context.read<SicknessGuideProvider>().submitAnswers(text);
    if (!mounted) return;
    _answersController.clear();
    _scrollToBottom();
  }

  Future<void> _submitFollowUp() async {
    final text = _followUpController.text.trim();
    if (text.isEmpty) return;
    FocusScope.of(context).unfocus();
    await context.read<SicknessGuideProvider>().submitFollowUp(text);
    if (!mounted) return;
    _followUpController.clear();
    setState(() {});
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _reset() {
    context.read<SicknessGuideProvider>().reset();
    setState(() {
      _selectedChips.clear();
      _symptomsController.clear();
      _answersController.clear();
      _followUpController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<SicknessGuideProvider>();
    final user = context.watch<UserProvider>().user;

    return Scaffold(
      backgroundColor: isDark ? CliniqTheme.darkBg : CliniqTheme.lightBg,
      appBar: _buildAppBar(isDark, user),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Welcome bubble ──
                  AiBubble(
                    isDark: isDark,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi! 👋 Tell me your symptoms and I\'ll ask a couple of questions to give you the best guide.',
                          style: TextStyle(
                            color: isDark
                                ? CliniqTheme.darkText
                                : CliniqTheme.lightText,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 14),
                        SymptomChips(
                          selected: _selectedChips,
                          onTap: provider.status == GuideStatus.idle
                              ? _onChipTap
                              : (_) {},
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),

                  // ── User symptoms ──
                  if (provider.status != GuideStatus.idle &&
                      provider.symptoms.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    UserBubble(text: provider.symptoms, isDark: isDark),
                  ],

                  // ── Questioning loading ──
                  if (provider.status == GuideStatus.questioning) ...[
                    const SizedBox(height: 16),
                    AiBubble(
                      isDark: isDark,
                      child: LoadingDots(isDark: isDark),
                    ),
                  ],

                  // ── AI questions ──
                  if (provider.questions != null &&
                      provider.status != GuideStatus.idle) ...[
                    const SizedBox(height: 16),
                    AiBubble(
                      isDark: isDark,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'To give you a better guide, I have a couple of questions:',
                            style: TextStyle(
                              color: isDark
                                  ? CliniqTheme.darkTextMuted
                                  : CliniqTheme.lightTextMuted,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            provider.questions!,
                            style: TextStyle(
                              color: isDark
                                  ? CliniqTheme.darkText
                                  : CliniqTheme.lightText,
                              fontSize: 13,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // ── User answers ──
                  if (provider.status != GuideStatus.waitingAnswer &&
                      provider.status != GuideStatus.questioning &&
                      provider.status != GuideStatus.idle &&
                      provider.guide != null) ...[
                    const SizedBox(height: 16),
                    UserBubble(
                      text: 'Here are my answers ✓',
                      isDark: isDark,
                    ),
                  ],

                  // ── Guiding loading ──
                  if (provider.status == GuideStatus.guiding) ...[
                    const SizedBox(height: 16),
                    AiBubble(
                      isDark: isDark,
                      child: LoadingDots(isDark: isDark),
                    ),
                  ],

                  // ── Final guide ──
                  if (provider.guide != null) ...[
                    const SizedBox(height: 16),
                    AiBubble(
                      isDark: isDark,
                      child: GuideContent(
                        guide: provider.guide!,
                        isDark: isDark,
                      ),
                    ),
                  ],

                  // ── Follow ups ──
                  if (provider.followUps.isNotEmpty)
                    ...provider.followUps.map(
                      (fu) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          UserBubble(text: fu.question, isDark: isDark),
                          if (fu.answer != null) ...[
                            const SizedBox(height: 16),
                            AiBubble(
                              isDark: isDark,
                              child: Text(
                                fu.answer!,
                                style: TextStyle(
                                  color: isDark
                                      ? CliniqTheme.darkText
                                      : CliniqTheme.lightText,
                                  fontSize: 13,
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                  // ── Follow up loading ──
                  if (provider.status == GuideStatus.followingUp) ...[
                    const SizedBox(height: 16),
                    AiBubble(
                      isDark: isDark,
                      child: LoadingDots(isDark: isDark),
                    ),
                  ],

                  // ── Follow up limit ──
                  if (provider.status == GuideStatus.success &&
                      !provider.canFollowUp) ...[
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark
                              ? CliniqTheme.darkSurface2
                              : CliniqTheme.lightSurface2,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Follow-up limit reached',
                          style: TextStyle(
                            color: isDark
                                ? CliniqTheme.darkTextMuted
                                : CliniqTheme.lightTextMuted,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ],

                  // ── Start over ──
                  if (provider.status == GuideStatus.success ||
                      provider.status == GuideStatus.noCredits ||
                      provider.status == GuideStatus.error) ...[
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton.icon(
                        onPressed: _reset,
                        icon: Icon(
                          Iconsax.refresh,
                          size: 14,
                          color: isDark
                              ? CliniqTheme.darkTextMuted
                              : CliniqTheme.lightTextMuted,
                        ),
                        label: Text(
                          'Start over',
                          style: TextStyle(
                            color: isDark
                                ? CliniqTheme.darkTextMuted
                                : CliniqTheme.lightTextMuted,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],

                  // ── No credits ──
                  if (provider.status == GuideStatus.noCredits) ...[
                    const SizedBox(height: 16),
                    AiBubble(
                      isDark: isDark,
                      child: NoCreditsContent(isDark: isDark),
                    ),
                  ],

                  // ── Error ──
                  if (provider.status == GuideStatus.error) ...[
                    const SizedBox(height: 16),
                    AiBubble(
                      isDark: isDark,
                      child: Row(
                        children: [
                          Icon(Iconsax.warning_2,
                              size: 14, color: CliniqTheme.danger),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              provider.error ??
                                  'Something went wrong. Please try again.',
                              style: TextStyle(
                                color: CliniqTheme.danger,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // ── Input Bar ──
          GuideInputBar(
            symptomsController: _symptomsController,
            answersController: _answersController,
            followUpController: _followUpController,
            isDark: isDark,
            status: provider.status,
            canFollowUp: provider.canFollowUp,
            followUpsRemaining: provider.followUpsRemaining,
            onSubmitSymptoms: _submitSymptoms,
            onSubmitAnswers: _submitAnswers,
            onSubmitFollowUp: _submitFollowUp,
            onChanged: () => setState(() {}),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(bool isDark, dynamic user) {
    return AppBar(
      backgroundColor: isDark ? CliniqTheme.darkBg : CliniqTheme.lightBg,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Iconsax.arrow_left,
          color: isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/images/cliniq_logo (1).png',
              width: 32,
              height: 32,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Health Guide',
                style: TextStyle(
                  color: isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'AI powered • Not a doctor',
                style: TextStyle(
                  color: isDark
                      ? CliniqTheme.darkTextMuted
                      : CliniqTheme.lightTextMuted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        if (user != null)
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color:
                  isDark ? CliniqTheme.darkSurface2 : CliniqTheme.lightSurface2,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: CliniqTheme.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  user.isPro ? 'Pro' : '${user.totalCredits} credits',
                  style: TextStyle(
                    color:
                        isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
