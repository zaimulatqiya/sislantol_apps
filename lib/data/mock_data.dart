import '../models/user_model.dart';
import '../models/laporan_model.dart';
import '../models/penugasan_model.dart';
import '../models/armada_model.dart';

class MockData {
  static final List<UserModel> users = [
    UserModel(
      id: 'u1',
      nama: 'Budi Santoso',
      email: 'budi@gmail.com',
      noHp: '081234567890',
      role: 'pengguna',
    ),
    UserModel(
      id: 'p1',
      nama: 'Agus Petugas',
      email: 'agus@sislantol.com',
      noHp: '08111222333',
      role: 'petugas',
    ),
  ];

  static final List<LaporanModel> laporanList = [
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

  static final List<PenugasanModel> penugasanList = [
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
  
  static final List<ArmadaModel> armadaList = [
    ArmadaModel(id: 'a1', namaArmada: 'Derek Besar 01', platNomor: 'L 1234 XY', status: 'tersedia'),
    ArmadaModel(id: 'a2', namaArmada: 'Patroli 05', platNomor: 'W 9999 ZZ', status: 'bertugas'),
  ];
}
