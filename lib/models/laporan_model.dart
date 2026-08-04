class LaporanModel {
  final String id;
  final String userId;
  final String pelaporNama;
  final String pelaporNoHp;
  final String jenisKejadian; // 'mogok'|'kecelakaan'|'hambatan'
  final String nomorPolisi;
  final String lokasi;
  final String deskripsi;
  final List<String>? fotoUrls;
  final String status; // 'menunggu'|'diverifikasi'|'ditugaskan'|'proses'|'selesai'|'ditolak'
  final DateTime createdAt;
  final String? petugasNama;
  final String? catatanPetugas;
  final DateTime? selesaiAt;
  final String? totalWaktuPenanganan;

  String get displayJenisKejadian {
    if (jenisKejadian.toLowerCase() == 'lainnya' && deskripsi.startsWith('Jenis Kejadian: ')) {
      int newlineIndex = deskripsi.indexOf('\n');
      if (newlineIndex != -1) {
        return deskripsi.substring('Jenis Kejadian: '.length, newlineIndex).trim();
      } else {
        return deskripsi.substring('Jenis Kejadian: '.length).trim();
      }
    }
    return jenisKejadian;
  }

  String get displayDeskripsi {
    if (jenisKejadian.toLowerCase() == 'lainnya' && deskripsi.startsWith('Jenis Kejadian: ')) {
      int newlineIndex = deskripsi.indexOf('\n');
      if (newlineIndex != -1) {
        return deskripsi.substring(newlineIndex + 1).trim();
      } else {
        return '';
      }
    }
    return deskripsi;
  }

  LaporanModel({
    required this.id,
    required this.userId,
    required this.pelaporNama,
    required this.pelaporNoHp,
    required this.jenisKejadian,
    required this.nomorPolisi,
    required this.lokasi,
    required this.deskripsi,
    this.fotoUrls,
    required this.status,
    required this.createdAt,
    this.petugasNama,
    this.catatanPetugas,
    this.selesaiAt,
    this.totalWaktuPenanganan,
  });

  factory LaporanModel.fromJson(Map<String, dynamic> json) {
    List<String>? parsedFotoUrls;
    if (json['fotoUrls'] != null) {
      parsedFotoUrls = List<String>.from(json['fotoUrls']);
    } else if (json['fotoUrl'] != null) {
      parsedFotoUrls = [json['fotoUrl']];
    }

    return LaporanModel(
      id: json['id'],
      userId: json['userId'],
      pelaporNama: json['pelaporNama'],
      pelaporNoHp: json['pelaporNoHp'],
      jenisKejadian: json['jenisKejadian'],
      nomorPolisi: json['nomorPolisi'] ?? '-',
      lokasi: json['lokasi'],
      deskripsi: json['deskripsi'],
      fotoUrls: parsedFotoUrls,
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      petugasNama: json['petugasNama'],
      catatanPetugas: json['catatanPetugas'],
      selesaiAt: json['selesaiAt'] != null ? DateTime.parse(json['selesaiAt']) : null,
      totalWaktuPenanganan: json['totalWaktuPenanganan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'pelaporNama': pelaporNama,
      'pelaporNoHp': pelaporNoHp,
      'jenisKejadian': jenisKejadian,
      'nomorPolisi': nomorPolisi,
      'lokasi': lokasi,
      'deskripsi': deskripsi,
      'fotoUrls': fotoUrls,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'petugasNama': petugasNama,
      'catatanPetugas': catatanPetugas,
      'selesaiAt': selesaiAt?.toIso8601String(),
      'totalWaktuPenanganan': totalWaktuPenanganan,
    };
  }

  LaporanModel copyWith({
    String? id,
    String? userId,
    String? pelaporNama,
    String? pelaporNoHp,
    String? jenisKejadian,
    String? nomorPolisi,
    String? lokasi,
    String? deskripsi,
    List<String>? fotoUrls,
    String? status,
    DateTime? createdAt,
    String? petugasNama,
    String? catatanPetugas,
    DateTime? selesaiAt,
    String? totalWaktuPenanganan,
  }) {
    return LaporanModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      pelaporNama: pelaporNama ?? this.pelaporNama,
      pelaporNoHp: pelaporNoHp ?? this.pelaporNoHp,
      jenisKejadian: jenisKejadian ?? this.jenisKejadian,
      nomorPolisi: nomorPolisi ?? this.nomorPolisi,
      lokasi: lokasi ?? this.lokasi,
      deskripsi: deskripsi ?? this.deskripsi,
      fotoUrls: fotoUrls ?? this.fotoUrls,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      petugasNama: petugasNama ?? this.petugasNama,
      catatanPetugas: catatanPetugas ?? this.catatanPetugas,
      selesaiAt: selesaiAt ?? this.selesaiAt,
      totalWaktuPenanganan: totalWaktuPenanganan ?? this.totalWaktuPenanganan,
    );
  }
}
