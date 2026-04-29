import 'package:cliniq/providers/sickeness_guide_provider.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme.dart';

class GuideInputBar extends StatelessWidget {
  final TextEditingController symptomsController;
  final TextEditingController answersController;
  final TextEditingController followUpController;
  final bool isDark;
  final GuideStatus status;
  final bool canFollowUp;
  final int followUpsRemaining;
  final VoidCallback onSubmitSymptoms;
  final VoidCallback onSubmitAnswers;
  final VoidCallback onSubmitFollowUp;
  final VoidCallback onChanged;

  const GuideInputBar({
    super.key,
    required this.symptomsController,
    required this.answersController,
    required this.followUpController,
    required this.isDark,
    required this.status,
    required this.canFollowUp,
    required this.followUpsRemaining,
    required this.onSubmitSymptoms,
    required this.onSubmitAnswers,
    required this.onSubmitFollowUp,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isLoading = status == GuideStatus.questioning ||
        status == GuideStatus.guiding ||
        status == GuideStatus.followingUp;

    final isWaitingAnswer = status == GuideStatus.waitingAnswer;
    final isSuccess = status == GuideStatus.success;
    final isDone = status == GuideStatus.noCredits ||
        status == GuideStatus.error ||
        (isSuccess && !canFollowUp);

    TextEditingController controller;
    VoidCallback onSubmit;
    String hint;

    if (isWaitingAnswer) {
      controller = answersController;
      onSubmit = onSubmitAnswers;
      hint = 'Type your answers here...';
    } else if (isSuccess && canFollowUp) {
      controller = followUpController;
      onSubmit = onSubmitFollowUp;
      hint = 'Ask a follow-up question... ($followUpsRemaining left)';
    } else {
      controller = symptomsController;
      onSubmit = onSubmitSymptoms;
      hint = 'Describe your symptoms...';
    }

    final hasText = controller.text.trim().isNotEmpty;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: isDark ? CliniqTheme.darkSurface : CliniqTheme.lightSurface,
        border: Border(
          top: BorderSide(
            color: isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder,
            width: 0.5,
          ),
        ),
      ),
      child: isDone
          ? Center(
              child: Text(
                !canFollowUp && isSuccess
                    ? 'Follow-up limit reached • Start over for new symptoms'
                    : 'Start over to ask new symptoms',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark
                      ? CliniqTheme.darkTextMuted
                      : CliniqTheme.lightTextMuted,
                  fontSize: 11,
                ),
              ),
            )
          : Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? CliniqTheme.darkBg : CliniqTheme.lightBg,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark
                            ? CliniqTheme.darkBorder
                            : CliniqTheme.lightBorder,
                      ),
                    ),
                    child: TextField(
                      controller: controller,
                      maxLines: 3,
                      minLines: 1,
                      onChanged: (_) => onChanged(),
                      style: TextStyle(
                        color: isDark
                            ? CliniqTheme.darkText
                            : CliniqTheme.lightText,
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: TextStyle(
                          color: isDark
                              ? CliniqTheme.darkTextMuted
                              : CliniqTheme.lightTextMuted,
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: (!isLoading && hasText) ? onSubmit : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: (!isLoading && hasText)
                          ? (isDark
                              ? CliniqTheme.darkPrimary
                              : CliniqTheme.lightPrimary)
                          : (isDark
                              ? CliniqTheme.darkSurface2
                              : CliniqTheme.lightSurface2),
                      shape: BoxShape.circle,
                    ),
                    child: isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            Iconsax.send_1,
                            size: 18,
                            color: (!isLoading && hasText)
                                ? Colors.white
                                : (isDark
                                    ? CliniqTheme.darkTextMuted
                                    : CliniqTheme.lightTextMuted),
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}
