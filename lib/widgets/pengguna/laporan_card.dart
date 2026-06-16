import 'package:flutter/material.dart';
import '../../models/laporan_model.dart';
import '../../core/constants/app_colors.dart';
import '../common/badge_status.dart';

class LaporanCard extends StatelessWidget {
  final LaporanModel laporan;
  final VoidCallback onTap;

  const LaporanCard({
    super.key,
    required this.laporan,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(laporan.createdAt),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textHint,
                  ),
                ),
                BadgeStatus(status: laporan.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIconKejadian(),
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        laporan.displayJenisKejadian.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        laporan.lokasi,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textBody,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textHint,
                  size: 20,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconKejadian() {
    switch (laporan.jenisKejadian.toLowerCase()) {
      case 'mogok':
        return Icons.car_crash_outlined;
      case 'kecelakaan':
        return Icons.warning_amber_rounded;
      case 'hambatan':
        return Icons.block;
      default:
        return Icons.info_outline;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
