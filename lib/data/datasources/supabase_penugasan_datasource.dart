import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/penugasan_model.dart';

class SupabasePenugasanDataSource {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<PenugasanModel>> getPenugasanByPetugas(String petugasId) async {
    // Gunakan relasi (JOIN) ke tabel laporan untuk mengambil jenis_kejadian, lokasi, dan deskripsi
    final response = await supabase
        .from('penugasan')
        .select('*, laporan(*)')
        .eq('petugas_id', petugasId)
        .order('created_at', ascending: false);

    return response.map((data) {
      final laporanData = data['laporan'] as Map<String, dynamic>?;
      
      List<String>? parsedFotoUrls;
      if (laporanData != null && laporanData['foto_urls'] != null) {
        parsedFotoUrls = List<String>.from(laporanData['foto_urls']);
      }
      
      return PenugasanModel(
        id: data['id'].toString(),
        laporanId: data['laporan_id'].toString(),
        petugasId: data['petugas_id'],
        jenisKejadian: laporanData?['jenis_kejadian'] ?? 'Tidak diketahui',
        lokasi: laporanData?['lokasi'] ?? 'Tidak diketahui',
        deskripsi: laporanData?['deskripsi'] ?? '-',
        catatanAdmin: data['catatan_admin'] ?? '-',
        status: data['status'],
        createdAt: DateTime.parse(data['created_at']),
        fotoBuktiUrl: data['foto_bukti_url'],
        catatanPenutup: data['catatan_penutup'],
        fotoKejadianUrls: parsedFotoUrls,
      );
    }).toList();
  }

  Future<void> updateStatusPenugasan(String penugasanId, String status) async {
    // 1. Ambil laporanId terkait
    final data = await supabase.from('penugasan').select('laporan_id').eq('id', penugasanId).single();
    final laporanId = data['laporan_id'];

    // 2. Update status di tabel penugasan
    await supabase.from('penugasan').update({
      'status': status,
    }).eq('id', penugasanId);

    // 3. Sinkronisasi status ke tabel laporan agar Pengguna & Admin juga melihat updatenya
    await supabase.from('laporan').update({
      'status': status,
    }).eq('id', laporanId);
  }

  Future<void> selesaikanTugas({
    required String penugasanId,
    required String laporanId,
    required String fotoPath,
    required String catatanPenutup,
  }) async {
    final file = File(fotoPath);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_penyelesaian.jpg';
    final bucketPath = '$laporanId/$fileName';

    // 1. Upload foto bukti ke storage
    await supabase.storage.from('bukti-penyelesaian').upload(
          bucketPath,
          file,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );

    // 2. Dapatkan URL publik dari foto yang diunggah
    final fotoUrl = supabase.storage.from('bukti-penyelesaian').getPublicUrl(bucketPath);

    // 3. Update status penugasan menjadi selesai beserta catatannya
    await supabase.from('penugasan').update({
      'status': 'selesai',
      'foto_bukti_url': fotoUrl,
      'catatan_penutup': catatanPenutup,
      'selesai_at': DateTime.now().toIso8601String(),
    }).eq('id', penugasanId);

    // 4. Update status laporan menjadi selesai di tabel laporan
    await supabase.from('laporan').update({
      'status': 'selesai',
    }).eq('id', laporanId);
  }
}
