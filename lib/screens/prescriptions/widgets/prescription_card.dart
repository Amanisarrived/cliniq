import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../core/theme.dart';
import '../../../models/prescription_model.dart';

class PrescriptionCard extends StatelessWidget {
  final PrescriptionModel prescription;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const PrescriptionCard({
    super.key,
    required this.prescription,
    required this.isDark,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = prescription.imageUrls.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? CliniqTheme.darkSurface : CliniqTheme.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Image (top, full width) ──────────────
            if (hasImage)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: prescription.imageUrls.first,
                      width: double.infinity,
                      height: 140,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        height: 140,
                        color: isDark
                            ? CliniqTheme.darkSurface2
                            : CliniqTheme.lightSurface2,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        height: 140,
                        color: isDark
                            ? CliniqTheme.darkSurface2
                            : CliniqTheme.lightSurface2,
                        child: Icon(
                          Iconsax.document_text,
                          size: 32,
                          color: isDark
                              ? CliniqTheme.darkTextMuted
                              : CliniqTheme.lightTextMuted,
                        ),
                      ),
                    ),
                  ),

                  // Delete button on image
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onDelete,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(140),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Iconsax.trash,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Multiple images count badge
                  if (prescription.imageUrls.length > 1)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(140),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Iconsax.gallery,
                              size: 11,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${prescription.imageUrls.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

            // ─── Info ────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row — Doctor + Delete (no image case)
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          prescription.doctorName.isNotEmpty
                              ? 'Dr. ${prescription.doctorName}'
                              : 'No doctor name',
                          style: TextStyle(
                            color: isDark
                                ? CliniqTheme.darkText
                                : CliniqTheme.lightText,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!hasImage)
                        GestureDetector(
                          onTap: onDelete,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: CliniqTheme.danger.withAlpha(15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Iconsax.trash,
                              size: 15,
                              color: CliniqTheme.danger.withAlpha(200),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Hospital + Date row
                  Row(
                    children: [
                      if (prescription.hospitalName.isNotEmpty) ...[
                        Icon(
                          Iconsax.hospital,
                          size: 11,
                          color: isDark
                              ? CliniqTheme.darkTextMuted
                              : CliniqTheme.lightTextMuted,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            prescription.hospitalName,
                            style: TextStyle(
                              color: isDark
                                  ? CliniqTheme.darkTextMuted
                                  : CliniqTheme.lightTextMuted,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Icon(
                        Iconsax.calendar,
                        size: 11,
                        color: isDark
                            ? CliniqTheme.darkTextMuted
                            : CliniqTheme.lightTextMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd MMM yyyy').format(prescription.date),
                        style: TextStyle(
                          color: isDark
                              ? CliniqTheme.darkTextMuted
                              : CliniqTheme.lightTextMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),

                  // AI Summary
                  if (prescription.aiSummary != null &&
                      prescription.aiSummary!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? CliniqTheme.darkPrimary.withAlpha(15)
                            : CliniqTheme.lightPrimary.withAlpha(10),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark
                              ? CliniqTheme.darkPrimary.withAlpha(30)
                              : CliniqTheme.lightPrimary.withAlpha(20),
                        ),
                      ),
                      child: Text(
                        prescription.aiSummary!,
                        style: TextStyle(
                          color: isDark
                              ? CliniqTheme.darkTextMuted
                              : CliniqTheme.lightTextMuted,
                          fontSize: 10,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],

                  // Tags + AI badge
                  if (prescription.aiExtracted != null ||
                      prescription.tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (prescription.aiExtracted != null)
                          _Badge(
                            label: 'AI Scanned',
                            color: CliniqTheme.success,
                            isDark: isDark,
                          ),
                        if (prescription.aiExtracted != null &&
                            prescription.tags.isNotEmpty)
                          const SizedBox(width: 6),
                        if (prescription.tags.isNotEmpty)
                          _Badge(
                            label: prescription.tags.first,
                            color: isDark
                                ? CliniqTheme.darkPrimary
                                : CliniqTheme.lightPrimary,
                            isDark: isDark,
                          ),
                        if (prescription.tags.length > 1)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text(
                              '+${prescription.tags.length - 1}',
                              style: TextStyle(
                                color: isDark
                                    ? CliniqTheme.darkTextMuted
                                    : CliniqTheme.lightTextMuted,
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Badge ────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final bool isDark;

  const _Badge({
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
