import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../models/penugasan_model.dart';
import '../../core/constants/app_colors.dart';
import '../common/badge_status.dart';

class TugasCard extends StatelessWidget {
  final PenugasanModel tugas;
  final VoidCallback onTap;

  const TugasCard({
    super.key,
    required this.tugas,
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
                  'Tugas ID: #${tugas.id}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                BadgeStatus(status: tugas.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.assignment_ind_outlined,
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
                        tugas.displayJenisKejadian.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        tugas.lokasi,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textBody,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 12, color: AppColors.textHint),
                          const SizedBox(width: 6),
                          Text(
                            _formatDate(tugas.createdAt),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textHint),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                const Center(
                  child: Icon(
                    Icons.chevron_right,
                    color: AppColors.textHint,
                    size: 20,
                  ),
                )
              ],
            ),
            if (tugas.fotoBuktiUrl != null || (tugas.catatanPenutup != null && tugas.catatanPenutup!.isNotEmpty)) ...[
              const Padding(
                padding: EdgeInsets.only(top: 16, bottom: 12),
                child: Divider(height: 1, color: AppColors.border),
              ),
              if (tugas.fotoBuktiUrl != null) ...[
                const Text(
                  'Foto Bukti Penanganan:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: _getImageProvider(tugas.fotoBuktiUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (tugas.catatanPenutup != null && tugas.catatanPenutup!.isNotEmpty) ...[
                const Text(
                  'Catatan Penutup:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  tugas.catatanPenutup!,
                  style: const TextStyle(fontSize: 13, color: AppColors.textBody, fontStyle: FontStyle.italic),
                ),
              ],
            ]
          ],
        ),
      ),
    );
  }

  ImageProvider _getImageProvider(String url) {
    if (kIsWeb) return NetworkImage(url);
    if (url.startsWith('data:image')) return MemoryImage(base64Decode(url.split(',').last));
    if (url.startsWith('http')) return NetworkImage(url);
    return FileImage(File(url));
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
