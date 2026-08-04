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
        .eq('is_deleted_by_petugas', false)
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
        pelaporNama: laporanData?['pelapor_nama'],
        nomorPolisi: laporanData?['nomor_polisi'],
        menujuLokasiAt: data['menuju_lokasi_at'] != null ? DateTime.parse(data['menuju_lokasi_at']) : null,
        tibaLokasiAt: data['tiba_lokasi_at'] != null ? DateTime.parse(data['tiba_lokasi_at']) : null,
        prosesAt: data['proses_at'] != null ? DateTime.parse(data['proses_at']) : null,
        selesaiAt: data['selesai_at'] != null ? DateTime.parse(data['selesai_at']) : null,
        fotoBuktiUrl: data['foto_bukti_url'],
        catatanPenutup: data['catatan_penutup'],
        fotoKejadianUrls: parsedFotoUrls,
      );
    }).toList();
  }

  Future<void> updateStatusPenugasan(String penugasanId, String status) async {
    // 1. Ambil laporanId dan timestamp terkait
    final data = await supabase
        .from('penugasan')
        .select('laporan_id, menuju_lokasi_at, tiba_lokasi_at, proses_at')
        .eq('id', penugasanId)
        .single();
    final laporanId = data['laporan_id'];

    Map<String, dynamic> updateData = {'status': status};
    final nowIso = DateTime.now().toUtc().toIso8601String();

    if (status == 'menuju' && data['menuju_lokasi_at'] == null) {
      updateData['menuju_lokasi_at'] = nowIso;
    } else if (status == 'tiba' && data['tiba_lokasi_at'] == null) {
      updateData['tiba_lokasi_at'] = nowIso;
    } else if (status == 'proses' && data['proses_at'] == null) {
      updateData['proses_at'] = nowIso;
    }

    // 2. Update status dan timestamp di tabel penugasan
    await supabase.from('penugasan').update(updateData).eq('id', penugasanId);

    // 3. Sinkronisasi status ke tabel laporan agar Pengguna & Admin juga melihat updatenya
    await supabase.from('laporan').update({
      'status': status,
    }).eq('id', laporanId);
  }

  Future<void> selesaikanTugas({
    required String penugasanId,
    required String laporanId,
    required List<String> fotoPaths,
    required String catatanPenutup,
  }) async {
    List<String> fotoUrls = [];

    for (int i = 0; i < fotoPaths.length; i++) {
      final file = File(fotoPaths[i]);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_penyelesaian_$i.jpg';
      final bucketPath = '$laporanId/$fileName';

      // 1. Upload foto bukti ke storage
      await supabase.storage.from('bukti-penyelesaian').upload(
            bucketPath,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      // 2. Dapatkan URL publik dari foto yang diunggah
      final fotoUrl = supabase.storage.from('bukti-penyelesaian').getPublicUrl(bucketPath);
      fotoUrls.add(fotoUrl);
    }

    final joinedUrls = fotoUrls.join(',');

    // 3. Update status penugasan menjadi selesai beserta catatannya
    await supabase.from('penugasan').update({
      'status': 'selesai',
      'foto_bukti_url': joinedUrls,
      'catatan_penutup': catatanPenutup,
      'selesai_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', penugasanId);

    // 4. Update status laporan menjadi selesai di tabel laporan
    await supabase.from('laporan').update({
      'status': 'selesai',
    }).eq('id', laporanId);
  }

  Future<void> deletePenugasan(String penugasanId) async {
    // Delete single assignment
    final parsedId = int.tryParse(penugasanId);
    if (parsedId == null) throw Exception("ID Penugasan tidak valid");
    await supabase.rpc('soft_delete_penugasan', params: {'p_penugasan_id': parsedId});
  }

  Future<void> deleteAllPenugasanByPetugas(String petugasId) async {
    // Delete all assignments related to this petugas
    await supabase.from('penugasan').update({'is_deleted_by_petugas': true}).eq('petugas_id', petugasId);
  }
}
