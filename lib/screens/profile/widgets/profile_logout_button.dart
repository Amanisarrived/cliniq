import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../core/routes.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/user_provider.dart';

class ProfileLogoutButton extends StatefulWidget {
  final bool isDark;

  const ProfileLogoutButton({super.key, required this.isDark});

  @override
  State<ProfileLogoutButton> createState() => _ProfileLogoutButtonState();
}

class _ProfileLogoutButtonState extends State<ProfileLogoutButton> {
  bool _isLoading = false;

  Future<void> _logout() async {
    final confirmed = await _showConfirmDialog();
    if (!confirmed) return;

    setState(() => _isLoading = true);

    await context.read<AuthProvider>().signOut();
    if (!mounted) return;

    context.read<UserProvider>().clearUser();
    if (!mounted) return;

    setState(() => _isLoading = false);
    context.go(AppRoutes.login);
  }

  Future<bool> _showConfirmDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: widget.isDark
                ? CliniqTheme.darkSurface
                : CliniqTheme.lightSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Log Out?',
              style: TextStyle(
                color: widget.isDark
                    ? CliniqTheme.darkText
                    : CliniqTheme.lightText,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            content: Text(
              'Are you sure you want to log out?',
              style: TextStyle(
                color: widget.isDark
                    ? CliniqTheme.darkTextMuted
                    : CliniqTheme.lightTextMuted,
                fontSize: 14,
              ),
            ),
            actions: [
              TextButton(
                // ✅ dialogContext use karo
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: widget.isDark
                        ? CliniqTheme.darkTextMuted
                        : CliniqTheme.lightTextMuted,
                  ),
                ),
              ),
              TextButton(
                // ✅ dialogContext use karo
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text(
                  'Log Out',
                  style: TextStyle(
                    color: CliniqTheme.danger,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        onPressed: _isLoading ? null : _logout,
        icon: _isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: CliniqTheme.danger,
                ),
              )
            : const Icon(
                Iconsax.logout,
                size: 18,
                color: CliniqTheme.danger,
              ),
        label: const Text(
          'Log Out',
          style: TextStyle(
            color: CliniqTheme.danger,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(
            color: CliniqTheme.danger,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
