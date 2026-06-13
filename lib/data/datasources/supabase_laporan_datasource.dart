import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/laporan_model.dart';

class SupabaseLaporanDataSource {
  final _supabase = Supabase.instance.client;

  LaporanModel _mapToModel(Map<String, dynamic> json) {
    return LaporanModel(
      id: json['id'].toString(),
      userId: json['user_id'] ?? '',
      pelaporNama: json['pelapor_nama'] ?? '',
      pelaporNoHp: json['pelapor_no_hp'] ?? '',
      jenisKejadian: json['jenis_kejadian'] ?? 'lainnya',
      lokasi: json['lokasi'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      fotoUrls: json['foto_urls'] != null ? List<String>.from(json['foto_urls']) : null,
      status: json['status'] ?? 'menunggu',
      createdAt: DateTime.parse(json['created_at']),
      // Note: petugasNama and catatanPetugas usually fetched from relation or penugasan table, 
      // but for simplicity we map directly if available in a view, or leave null for now
      petugasNama: null,
      catatanPetugas: json['alasan_tolak'],
      selesaiAt: null,
    );
  }

  Future<List<LaporanModel>> getLaporanByUser(String userId) async {
    try {
      final response = await _supabase
          .from('laporan')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return (response as List).map((data) => _mapToModel(data)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data laporan: $e');
    }
  }

  Future<List<LaporanModel>> getAllLaporan() async {
    try {
      final response = await _supabase
          .from('laporan')
          .select()
          .order('created_at', ascending: false);
      
      return (response as List).map((data) => _mapToModel(data)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil semua data laporan: $e');
    }
  }

  Future<void> addLaporan(LaporanModel laporan) async {
    try {
      // 1. Upload semua foto ke Storage (jika ada) terlebih dahulu
      // Karena RLS tidak mengizinkan pengguna untuk melakukan UPDATE laporan
      final List<String> uploadedUrls = [];

      if (laporan.fotoUrls != null && laporan.fotoUrls!.isNotEmpty) {
        for (int i = 0; i < laporan.fotoUrls!.length; i++) {
          final localPath = laporan.fotoUrls![i];
          final file = File(localPath);
          
          if (await file.exists()) {
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            // Gunakan userId dan timestamp untuk penamaan folder/file
            final filePath = 'user-${laporan.userId}/foto-$timestamp-$i.jpg';

            await _supabase.storage
                .from('bukti-kejadian')
                .upload(filePath, file);

            // Dapatkan public URL
            final url = _supabase.storage
                .from('bukti-kejadian')
                .getPublicUrl(filePath);

            uploadedUrls.add(url);
          }
        }
      }

      // 2. Buat laporan dengan menyertakan URL foto
      await _supabase.from('laporan').insert({
        'user_id': laporan.userId,
        'pelapor_nama': laporan.pelaporNama,
        'pelapor_no_hp': laporan.pelaporNoHp,
        'jenis_kejadian': laporan.jenisKejadian,
        'lokasi': laporan.lokasi,
        'deskripsi': laporan.deskripsi,
        'foto_urls': uploadedUrls.isNotEmpty ? uploadedUrls : null,
        'status': 'menunggu',
      });
    } catch (e) {
      throw Exception('Gagal mengirim laporan: $e');
    }
  }

  Future<void> updateLaporan(LaporanModel laporan) async {
    try {
      await _supabase.from('laporan').update({
        'status': laporan.status,
      }).eq('id', int.parse(laporan.id));
    } catch (e) {
      throw Exception('Gagal mengubah laporan: $e');
    }
  }

  Future<void> deleteLaporan(String id) async {
    try {
      await _supabase.from('laporan').delete().eq('id', int.parse(id));
    } catch (e) {
      throw Exception('Gagal menghapus laporan: $e');
    }
  }
}
