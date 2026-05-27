import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/laporan_model.dart';

class MockLaporanDataSource {
  static const String _laporanKey = 'laporan_list';
  bool _isInitialized = false;

  final List<LaporanModel> _laporanList = [
    LaporanModel(
      id: 'l1',
      userId: 'u1',
      pelaporNama: 'Budi Santoso',
      pelaporNoHp: '081234567890',
      jenisKejadian: 'mogok',
      lokasi: 'KM 12 Tol Surabaya - Gempol',
      deskripsi: 'Mesin mati tiba-tiba, butuh derek.',
      status: 'menunggu',
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    LaporanModel(
      id: 'l2',
      userId: 'u1',
      pelaporNama: 'Budi Santoso',
      pelaporNoHp: '081234567890',
      jenisKejadian: 'kecelakaan',
      lokasi: 'KM 15 Arah Selatan',
      deskripsi: 'Tabrakan beruntun melibatkan 2 mobil',
      status: 'ditugaskan',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      petugasNama: 'Agus Petugas',
    ),
    LaporanModel(
      id: 'l3',
      userId: 'u1',
      pelaporNama: 'Budi Santoso',
      pelaporNoHp: '081234567890',
      jenisKejadian: 'hambatan',
      lokasi: 'GTO Sidoarjo',
      deskripsi: 'Pecah ban di bahu jalan',
      status: 'selesai',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      petugasNama: 'Agus Petugas',
      catatanPetugas: 'Ban sudah diganti, pengguna melanjutkan perjalanan',
      selesaiAt: DateTime.now().subtract(const Duration(days: 1, minutes: -45)),
    ),
  ];

  Future<void> _initDataIfNeeded() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? laporanJson = prefs.getString(_laporanKey);
      if (laporanJson != null) {
        final List<dynamic> decoded = jsonDecode(laporanJson);
        _laporanList.clear();
        _laporanList.addAll(decoded.map((e) => LaporanModel.fromJson(e)).toList());
      }
      _isInitialized = true;
    } catch (e) {
      // Ignore initialization errors
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> encoded = _laporanList.map((e) => e.toJson()).toList();
      await prefs.setString(_laporanKey, jsonEncode(encoded));
    } catch (e) {
      // Ignore saving errors
    }
  }

  Future<List<LaporanModel>> getLaporanByUser(String userId) async {
    await _initDataIfNeeded();
    await Future.delayed(const Duration(milliseconds: 500));
    return _laporanList.where((l) => l.userId == userId).toList();
  }

  Future<List<LaporanModel>> getAllLaporan() async {
    await _initDataIfNeeded();
    await Future.delayed(const Duration(milliseconds: 500));
    return List<LaporanModel>.from(_laporanList);
  }

  Future<void> addLaporan(LaporanModel laporan) async {
    await _initDataIfNeeded();
    await Future.delayed(const Duration(milliseconds: 500));
    _laporanList.add(laporan);
    await _saveData();
  }

  Future<void> updateLaporan(LaporanModel laporan) async {
    await _initDataIfNeeded();
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _laporanList.indexWhere((l) => l.id == laporan.id);
    if (index != -1) {
      _laporanList[index] = laporan;
      await _saveData();
    }
  }

  Future<void> deleteLaporan(String id) async {
    await _initDataIfNeeded();
    await Future.delayed(const Duration(milliseconds: 500));
    _laporanList.removeWhere((l) => l.id == id);
    await _saveData();
  }
}
