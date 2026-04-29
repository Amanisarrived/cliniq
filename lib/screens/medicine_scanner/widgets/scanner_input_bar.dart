import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme.dart';

class ScannerInputBar extends StatefulWidget {
  final bool isDark;
  final bool isEnabled;
  final Function(File) onImageSelected;
  final Function(String) onTextSubmit;

  const ScannerInputBar({
    super.key,
    required this.isDark,
    required this.isEnabled,
    required this.onImageSelected,
    required this.onTextSubmit,
  });

  @override
  State<ScannerInputBar> createState() => _ScannerInputBarState();
}

class _ScannerInputBarState extends State<ScannerInputBar> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onTextSubmit(text);
    _controller.clear();
  }

  Future<void> _showImageOptions() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ImageOptionsSheet(
        isDark: widget.isDark,
        onCamera: () async {
          Navigator.pop(context);
          await _pickImage(ImageSource.camera);
        },
        onGallery: () async {
          Navigator.pop(context);
          await _pickImage(ImageSource.gallery);
        },
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1080,
      );
      if (picked == null) return;
      if (!mounted) return;
      widget.onImageSelected(File(picked.path));
    } catch (e) {
      debugPrint('Image pick error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color:
            widget.isDark ? CliniqTheme.darkSurface : CliniqTheme.lightSurface,
        border: Border(
          top: BorderSide(
            color: widget.isDark
                ? CliniqTheme.darkBorder
                : CliniqTheme.lightBorder,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // + Button
          GestureDetector(
            onTap: widget.isEnabled ? _showImageOptions : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: widget.isEnabled
                    ? (widget.isDark
                        ? CliniqTheme.darkSurface2
                        : CliniqTheme.lightSurface2)
                    : (widget.isDark
                        ? CliniqTheme.darkBorder
                        : CliniqTheme.lightBorder),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.isEnabled
                      ? (widget.isDark
                          ? CliniqTheme.darkPrimary.withAlpha(80)
                          : CliniqTheme.lightPrimary.withAlpha(60))
                      : Colors.transparent,
                  width: 0.5,
                ),
              ),
              child: Icon(
                Icons.add_rounded,
                size: 20,
                color: widget.isEnabled
                    ? (widget.isDark
                        ? CliniqTheme.darkPrimary
                        : CliniqTheme.lightPrimary)
                    : (widget.isDark
                        ? CliniqTheme.darkTextMuted
                        : CliniqTheme.lightTextMuted),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Text input
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: widget.isDark ? CliniqTheme.darkBg : CliniqTheme.lightBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: _controller,
                enabled: widget.isEnabled,
                style: TextStyle(
                  color: widget.isDark
                      ? CliniqTheme.darkText
                      : CliniqTheme.lightText,
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  hintText: widget.isEnabled
                      ? 'Type medicine name...'
                      : 'No scans remaining...',
                  hintStyle: TextStyle(
                    color: widget.isDark
                        ? CliniqTheme.darkTextMuted
                        : CliniqTheme.lightTextMuted,
                    fontSize: 13,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                ),
                onSubmitted: (_) => _onSend(),
                textInputAction: TextInputAction.send,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Send button
          GestureDetector(
            onTap: widget.isEnabled ? _onSend : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: widget.isEnabled
                    ? (widget.isDark
                        ? CliniqTheme.darkPrimary
                        : CliniqTheme.lightPrimary)
                    : (widget.isDark
                        ? CliniqTheme.darkBorder
                        : CliniqTheme.lightBorder),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_upward_rounded,
                size: 18,
                color: widget.isEnabled
                    ? Colors.white
                    : (widget.isDark
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

// ── Image Options Bottom Sheet ────────────────────────
class _ImageOptionsSheet extends StatelessWidget {
  final bool isDark;
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  const _ImageOptionsSheet({
    required this.isDark,
    required this.onCamera,
    required this.onGallery,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? CliniqTheme.darkSurface : CliniqTheme.lightSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder,
          width: 0.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
            child: Text(
              'Choose Option',
              style: TextStyle(
                color: isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          // Camera
          _OptionTile(
            icon: Icons.camera_alt_outlined,
            title: 'Camera',
            subtitle: 'Take a photo of medicine',
            isDark: isDark,
            onTap: onCamera,
            isPrimary: true,
          ),

          Divider(
            color: isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder,
            height: 0.5,
            indent: 16,
            endIndent: 16,
          ),

          // Gallery
          _OptionTile(
            icon: Icons.photo_library_outlined,
            title: 'Gallery',
            subtitle: 'Upload from photos',
            isDark: isDark,
            onTap: onGallery,
            isPrimary: false,
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
  final VoidCallback onTap;
  final bool isPrimary;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.onTap,
    required this.isPrimary,
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
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isPrimary
                    ? (isDark
                        ? CliniqTheme.darkPrimary
                        : CliniqTheme.lightPrimary)
                    : (isDark
                        ? CliniqTheme.darkSurface2
                        : CliniqTheme.lightSurface2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isPrimary
                    ? Colors.white
                    : (isDark
                        ? CliniqTheme.darkPrimary
                        : CliniqTheme.lightPrimary),
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color:
                        isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
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
      ),
    );
  }
}
