import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/chat_message_model.dart';
import '../../providers/scanner_provider.dart';
import '../../providers/user_provider.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/scan_result_card.dart';
import 'widgets/scanner_app_bar.dart';
import 'widgets/scanner_input_bar.dart';
import 'widgets/session_limit_card.dart';
import 'widgets/welcome_messages.dart';

class MedicineScannerScreen extends StatefulWidget {
  const MedicineScannerScreen({super.key});

  @override
  State<MedicineScannerScreen> createState() => _MedicineScannerScreenState();
}

class _MedicineScannerScreenState extends State<MedicineScannerScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<ScannerProvider>();
      if (provider.messages.isEmpty) {
        provider.loadLastSession();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _onImageSelected(File image) async {
    final scannerProvider = context.read<ScannerProvider>();
    final userProvider = context.read<UserProvider>();
    final credits = userProvider.user?.totalCredits ?? 0;
    await scannerProvider.scanFromImage(image, credits);
    _scrollToBottom();
  }

  Future<void> _onTextSubmit(String text) async {
    final scannerProvider = context.read<ScannerProvider>();
    final userProvider = context.read<UserProvider>();
    final credits = userProvider.user?.totalCredits ?? 0;

    final hasScanned = scannerProvider.messages.any(
      (m) => m.contentType == ContentType.result,
    );

    if (hasScanned) {
      await scannerProvider.sendFollowUp(text, credits);
    } else {
      await scannerProvider.scanFromText(text, credits);
    }
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final credits = context.select<UserProvider, int>(
      (p) => p.user?.totalCredits ?? 0,
    );

    final messages = context.select<ScannerProvider, List<ChatMessage>>(
      (p) => p.messages,
    );

    final isLimitReached = context.select<ScannerProvider, bool>(
      (p) => p.isLimitReached,
    );

    final canSend = context.select<ScannerProvider, bool>(
          (p) => p.canSendMessage,
        ) &&
        credits > 0;

    return Scaffold(
      backgroundColor: isDark ? CliniqTheme.darkBg : CliniqTheme.lightBg,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            ScannerAppBar(
              isDark: isDark,
              creditsLeft: credits,
            ),

            // Chat Area
            Expanded(
              child: messages.isEmpty
                  ? ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        WelcomeMessages(isDark: isDark),
                      ],
                    )
                  : ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length + (isLimitReached ? 1 : 0),
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        // Session limit card at end
                        if (isLimitReached && index == messages.length) {
                          return SessionLimitCard(
                            isDark: isDark,
                            onWatchAd: () {
                              // TODO: show rewarded ad
                            },
                            onUpgrade: () {
                              // TODO: upgrade screen
                            },
                          );
                        }

                        final message = messages[index];

                        // Result card
                        if (message.contentType == ContentType.result) {
                          return ScanResultCard(
                            result: message.scanResult!,
                            isDark: isDark,
                          );
                        }

                        return ChatBubble(
                          message: message,
                          isDark: isDark,
                        );
                      },
                    ),
            ),

            // Input Bar
            ScannerInputBar(
              isDark: isDark,
              isEnabled: canSend,
              onImageSelected: _onImageSelected,
              onTextSubmit: _onTextSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
