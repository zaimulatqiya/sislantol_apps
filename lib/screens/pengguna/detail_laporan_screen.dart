import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../models/laporan_model.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/common/badge_status.dart';

class DetailLaporanScreen extends StatelessWidget {
  const DetailLaporanScreen({super.key});

  ImageProvider _getImageProvider(String url) {
    if (kIsWeb) return NetworkImage(url);
    if (url.startsWith('data:image')) return MemoryImage(base64Decode(url.split(',').last));
    if (url.startsWith('http')) return NetworkImage(url);
    return FileImage(File(url));
  }

  void _showImagePreview(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: Image(
                image: _getImageProvider(url),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final LaporanModel laporan =
        ModalRoute.of(context)!.settings.arguments as LaporanModel;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detail Laporan',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.primary.withOpacity(0.04),
                        blurRadius: 24,
                        offset: const Offset(0, 8))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ID: #${laporan.id}',
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _formatDate(laporan.createdAt),
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const Divider(height: 32, color: AppColors.border),
                    _buildInfoRow(
                        'Jenis Kejadian',
                        laporan.displayJenisKejadian.toUpperCase(),
                        Icons.warning_amber_rounded),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                        'Lokasi', laporan.lokasi, Icons.location_on_outlined),
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Icon(Icons.description_outlined,
                            size: 18, color: AppColors.textMuted),
                        SizedBox(width: 8),
                        Text('Deskripsi',
                            style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      laporan.displayDeskripsi.isEmpty ? 'Tidak ada deskripsi tambahan.' : laporan.displayDeskripsi,
                      style: TextStyle(
                          fontSize: 14,
                          color: laporan.displayDeskripsi.isEmpty ? AppColors.textHint : AppColors.textPrimary,
                          fontStyle: laporan.displayDeskripsi.isEmpty ? FontStyle.italic : FontStyle.normal,
                          height: 1.5),
                    ),
                    if (laporan.fotoUrls != null && laporan.fotoUrls!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Row(
                        children: [
                          Icon(Icons.photo_outlined,
                              size: 18, color: AppColors.textMuted),
                          SizedBox(width: 8),
                          Text('Foto Bukti',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Image display
                      SizedBox(
                        height: 150,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: laporan.fotoUrls!.length,
                          itemBuilder: (context, index) {
                            final String url = laporan.fotoUrls![index];
                            return GestureDetector(
                              onTap: () => _showImagePreview(context, url),
                              child: Container(
                                width: 150,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySurface,
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: _getImageProvider(url),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    ]
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Status Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.primary.withOpacity(0.04),
                        blurRadius: 24,
                        offset: const Offset(0, 8))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status Penanganan',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Status Saat Ini:',
                            style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textBody,
                                fontWeight: FontWeight.w500)),
                        BadgeStatus(status: laporan.status),
                      ],
                    ),
                    if (laporan.petugasNama != null) ...[
                      const Divider(height: 32, color: AppColors.border),
                      _buildInfoRow('Petugas Ditugaskan', laporan.petugasNama!,
                          Icons.engineering_outlined),
                    ],
                    if (laporan.catatanPetugas != null) ...[
                      const SizedBox(height: 16),
                      const Row(
                        children: [
                          Icon(Icons.notes_outlined,
                              size: 18, color: AppColors.textMuted),
                          SizedBox(width: 8),
                          Text('Catatan Petugas',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        laporan.catatanPetugas!,
                        style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                            height: 1.5),
                      ),
                    ],
                    if (laporan.selesaiAt != null) ...[
                      const SizedBox(height: 16),
                      _buildInfoRow(
                          'Waktu Selesai',
                          _formatDate(laporan.selesaiAt!),
                          Icons.check_circle_outline),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
