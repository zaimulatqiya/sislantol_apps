import '../../models/penugasan_model.dart';

class MockPenugasanDataSource {
  final List<PenugasanModel> _penugasanList = [
    PenugasanModel(
      id: 't1',
      laporanId: 'l2',
      petugasId: 'p1',
      jenisKejadian: 'kecelakaan',
      lokasi: 'KM 15 Arah Selatan',
      deskripsi: 'Tabrakan beruntun melibatkan 2 mobil',
      catatanAdmin: 'Segera meluncur membawa tim medis tambahan',
      status: 'diterima',
      createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 10)),
    ),
    PenugasanModel(
      id: 't2',
      laporanId: 'l3',
      petugasId: 'p1',
      jenisKejadian: 'hambatan',
      lokasi: 'GTO Sidoarjo',
      deskripsi: 'Pecah ban di bahu jalan',
      catatanAdmin: 'Cek kondisi dan bantu ganti ban jika ada serep',
      status: 'selesai',
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
      catatanPenutup: 'Selesai, aman terkendali.',
    ),
  ];

  Future<List<PenugasanModel>> getAllPenugasan() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List<PenugasanModel>.from(_penugasanList);
  }

  Future<List<PenugasanModel>> getPenugasanByPetugas(String petugasId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _penugasanList.where((p) => p.petugasId == petugasId).toList();
  }

  Future<void> updatePenugasan(PenugasanModel penugasan) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _penugasanList.indexWhere((p) => p.id == penugasan.id);
    if (index != -1) {
      _penugasanList[index] = penugasan;
    }
  }

  Future<void> addPenugasan(PenugasanModel penugasan) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _penugasanList.add(penugasan);
  }

  Future<void> removePenugasan(String penugasanId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _penugasanList.removeWhere((p) => p.id == penugasanId);
  }
}
