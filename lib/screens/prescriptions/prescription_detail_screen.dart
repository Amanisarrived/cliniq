import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../models/prescription_model.dart';

class PrescriptionDetailScreen extends StatefulWidget {
  final PrescriptionModel prescription;
  const PrescriptionDetailScreen({super.key, required this.prescription});

  @override
  State<PrescriptionDetailScreen> createState() =>
      _PrescriptionDetailScreenState();
}

class _PrescriptionDetailScreenState extends State<PrescriptionDetailScreen> {
  int _currentImage = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final p = widget.prescription;

    return Scaffold(
      backgroundColor: isDark ? CliniqTheme.darkBg : CliniqTheme.lightBg,
      appBar: AppBar(
        backgroundColor: isDark ? CliniqTheme.darkBg : CliniqTheme.lightBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Iconsax.arrow_left,
            color: isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Prescription Details',
          style: TextStyle(
            color: isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Images ────────────────────────────────────────
            if (p.imageUrls.isNotEmpty) ...[
              _ImageViewer(
                imageUrls: p.imageUrls,
                currentIndex: _currentImage,
                isDark: isDark,
                onPageChanged: (i) => setState(() => _currentImage = i),
              ),
              const SizedBox(height: 20),
            ],

            // ─── Info Card ─────────────────────────────────────
            _InfoCard(prescription: p, isDark: isDark),

            if (p.aiSummary != null && p.aiSummary!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? CliniqTheme.darkPrimary.withAlpha(20)
                      : CliniqTheme.lightPrimary.withAlpha(12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? CliniqTheme.darkPrimary.withAlpha(50)
                        : CliniqTheme.lightPrimary.withAlpha(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Iconsax.magic_star,
                          size: 15,
                          color: isDark
                              ? CliniqTheme.darkPrimary
                              : CliniqTheme.lightPrimary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'AI Summary',
                          style: TextStyle(
                            color: isDark
                                ? CliniqTheme.darkPrimary
                                : CliniqTheme.lightPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      p.aiSummary!,
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

            // ─── AI Result ─────────────────────────────────────
            if (p.aiExtracted != null &&
                p.aiExtracted!.medicines.isNotEmpty) ...[
              const SizedBox(height: 16),
              _AiResultCard(aiExtracted: p.aiExtracted!, isDark: isDark),
            ],

            // ─── Tags ──────────────────────────────────────────
            if (p.tags.isNotEmpty) ...[
              const SizedBox(height: 16),
              _TagsSection(tags: p.tags, isDark: isDark),
            ],

            // ─── Notes ─────────────────────────────────────────
            if (p.notes.isNotEmpty) ...[
              const SizedBox(height: 16),
              _NotesSection(notes: p.notes, isDark: isDark),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─── Image Viewer ─────────────────────────────────────────────────

class _ImageViewer extends StatelessWidget {
  final List<String> imageUrls;
  final int currentIndex;
  final bool isDark;
  final Function(int) onPageChanged;

  const _ImageViewer({
    required this.imageUrls,
    required this.currentIndex,
    required this.isDark,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 240,
            child: PageView.builder(
              itemCount: imageUrls.length,
              onPageChanged: onPageChanged,
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => _openFullscreen(context, imageUrls[i]),
                child: CachedNetworkImage(
                  imageUrl: imageUrls[i],
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: isDark
                        ? CliniqTheme.darkSurface2
                        : CliniqTheme.lightSurface2,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: isDark
                        ? CliniqTheme.darkSurface2
                        : CliniqTheme.lightSurface2,
                    child: Icon(
                      Iconsax.document_text,
                      color: isDark
                          ? CliniqTheme.darkTextMuted
                          : CliniqTheme.lightTextMuted,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Dots indicator
        if (imageUrls.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              imageUrls.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: i == currentIndex ? 16 : 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: i == currentIndex
                      ? (isDark
                          ? CliniqTheme.darkPrimary
                          : CliniqTheme.lightPrimary)
                      : (isDark
                          ? CliniqTheme.darkBorder
                          : CliniqTheme.lightBorder),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _openFullscreen(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullscreenImage(url: url),
      ),
    );
  }
}

// ─── Fullscreen Image ─────────────────────────────────────────────

class _FullscreenImage extends StatelessWidget {
  final String url;
  const _FullscreenImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          child: CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

// ─── Info Card ────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final PrescriptionModel prescription;
  final bool isDark;

  const _InfoCard({required this.prescription, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final p = prescription;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? CliniqTheme.darkSurface : CliniqTheme.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder,
        ),
      ),
      child: Column(
        children: [
          if (p.doctorName.isNotEmpty)
            _InfoRow(
              icon: Iconsax.user,
              label: 'Doctor',
              value: 'Dr. ${p.doctorName}',
              isDark: isDark,
            ),
          if (p.hospitalName.isNotEmpty) ...[
            _Divider(isDark: isDark),
            _InfoRow(
              icon: Iconsax.hospital,
              label: 'Hospital',
              value: p.hospitalName,
              isDark: isDark,
            ),
          ],
          _Divider(isDark: isDark),
          _InfoRow(
            icon: Iconsax.calendar,
            label: 'Date',
            value: DateFormat('dd MMMM yyyy').format(p.date),
            isDark: isDark,
          ),
          if (p.diagnosis.isNotEmpty) ...[
            _Divider(isDark: isDark),
            _InfoRow(
              icon: Iconsax.health,
              label: 'Diagnosis',
              value: p.diagnosis,
              isDark: isDark,
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color:
                isDark ? CliniqTheme.darkTextMuted : CliniqTheme.lightTextMuted,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: isDark
                  ? CliniqTheme.darkTextMuted
                  : CliniqTheme.lightTextMuted,
              fontSize: 12,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      color: isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder,
    );
  }
}

// ─── AI Result Card ───────────────────────────────────────────────

class _AiResultCard extends StatelessWidget {
  final AiExtracted aiExtracted;
  final bool isDark;

  const _AiResultCard({required this.aiExtracted, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CliniqTheme.success.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CliniqTheme.success.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.magic_star, size: 16, color: CliniqTheme.success),
              const SizedBox(width: 8),
              Text(
                'AI Extracted Medicines',
                style: TextStyle(
                  color: CliniqTheme.success,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('dd MMM').format(aiExtracted.scannedAt),
                style: TextStyle(
                  color: isDark
                      ? CliniqTheme.darkTextMuted
                      : CliniqTheme.lightTextMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...aiExtracted.medicines.map(
            (m) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: CliniqTheme.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      m,
                      style: TextStyle(
                        color: isDark
                            ? CliniqTheme.darkText
                            : CliniqTheme.lightText,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: CliniqTheme.warning.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Iconsax.warning_2, size: 13, color: CliniqTheme.warning),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Extracted by AI — please verify with your doctor',
                    style: TextStyle(
                      color: CliniqTheme.warning,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tags Section ─────────────────────────────────────────────────

class _TagsSection extends StatelessWidget {
  final List<String> tags;
  final bool isDark;

  const _TagsSection({required this.tags, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: TextStyle(
            color: isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags
              .map(
                (tag) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark
                        ? CliniqTheme.darkPrimary.withAlpha(25)
                        : CliniqTheme.lightPrimary.withAlpha(15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      color: isDark
                          ? CliniqTheme.darkPrimary
                          : CliniqTheme.lightPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

// ─── Notes Section ────────────────────────────────────────────────

class _NotesSection extends StatelessWidget {
  final String notes;
  final bool isDark;

  const _NotesSection({required this.notes, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes',
          style: TextStyle(
            color: isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? CliniqTheme.darkSurface : CliniqTheme.lightSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder,
            ),
          ),
          child: Text(
            notes,
            style: TextStyle(
              color: isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
