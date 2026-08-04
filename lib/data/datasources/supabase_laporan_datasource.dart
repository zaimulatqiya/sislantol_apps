import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/laporan_model.dart';

class SupabaseLaporanDataSource {
  final _supabase = Supabase.instance.client;
  LaporanModel _mapToModel(Map<String, dynamic> json) {
      String? calcTotalWaktu;
      String? petugasNamaVal;
      if (json['penugasan'] != null && (json['penugasan'] as List).isNotEmpty) {
        final lastPenugasan = (json['penugasan'] as List).last;
        
        if (lastPenugasan['profiles'] != null) {
          petugasNamaVal = lastPenugasan['profiles']['nama'];
        }

        if (lastPenugasan['menuju_lokasi_at'] != null && lastPenugasan['selesai_at'] != null) {
          final start = DateTime.parse(lastPenugasan['menuju_lokasi_at']);
          final end = DateTime.parse(lastPenugasan['selesai_at']);
          final diff = end.difference(start);
          if (diff.inMinutes < 60) {
            calcTotalWaktu = '${diff.inMinutes} menit';
          } else {
            final hours = diff.inHours;
            final mins = diff.inMinutes.remainder(60);
            calcTotalWaktu = mins > 0 ? '$hours jam $mins menit' : '$hours jam';
          }
        }
      }

      return LaporanModel(
        id: json['id'].toString(),
        userId: json['user_id'] ?? '',
        pelaporNama: json['pelapor_nama'] ?? '',
        pelaporNoHp: json['pelapor_no_hp'] ?? '',
        jenisKejadian: json['jenis_kejadian'] ?? 'lainnya',
        nomorPolisi: json['nomor_polisi'] ?? '-',
        lokasi: json['lokasi'] ?? '',
        deskripsi: json['deskripsi'] ?? '',
        fotoUrls: json['foto_urls'] != null ? List<String>.from(json['foto_urls']) : null,
        status: json['status'] ?? 'menunggu',
        createdAt: DateTime.parse(json['created_at']),
        petugasNama: petugasNamaVal,
        catatanPetugas: json['alasan_tolak'],
        selesaiAt: null,
        totalWaktuPenanganan: calcTotalWaktu,
      );
  }

  Future<List<LaporanModel>> getLaporanByUser(String userId) async {
    try {
      final response = await _supabase
          .from('laporan')
          .select('*, penugasan(menuju_lokasi_at, selesai_at, profiles(nama))')
          .eq('user_id', userId)
          .eq('is_deleted_by_user', false)
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
          .select('*, penugasan(menuju_lokasi_at, selesai_at, profiles(nama))')
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
        'nomor_polisi': laporan.nomorPolisi,
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
      final parsedId = int.tryParse(laporan.id);
      if (parsedId == null) throw Exception("ID Laporan tidak valid");
      await _supabase.from('laporan').update({
        'status': laporan.status,
      }).eq('id', parsedId);
    } catch (e) {
      throw Exception('Gagal mengubah laporan: $e');
    }
  }

  Future<void> deleteLaporan(String id) async {
    try {
      final parsedId = int.tryParse(id);
      if (parsedId == null) throw Exception("ID Laporan tidak valid");
      await _supabase.rpc('soft_delete_laporan', params: {'laporan_id': parsedId});
    } catch (e) {
      throw Exception('Gagal menghapus laporan: $e');
    }
  }

  Future<void> deleteAllLaporanByUser(String userId) async {
    try {
      await _supabase.from('laporan').update({'is_deleted_by_user': true}).eq('user_id', userId);
    } catch (e) {
      throw Exception('Gagal menghapus semua laporan: $e');
    }
  }
}
