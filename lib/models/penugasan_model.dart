import 'dart:convert';

class PenugasanModel {
  final String id;
  final String laporanId;
  final String petugasId;
  final String jenisKejadian;
  final String lokasi;
  final String deskripsi;
  final String catatanAdmin;
  final String status; // 'ditugaskan'|'diterima'|'menuju'|'tiba'|'proses'|'selesai'
  final DateTime createdAt;
  final String? fotoBuktiUrl;
  final String? catatanPenutup;
  final List<String>? fotoKejadianUrls;

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

  List<String> get listFotoBuktiUrls {
    if (fotoBuktiUrl == null || fotoBuktiUrl!.isEmpty) return [];
    if (fotoBuktiUrl!.startsWith('[')) {
      try {
        return List<String>.from(jsonDecode(fotoBuktiUrl!));
      } catch (_) {}
    }
    return fotoBuktiUrl!.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
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

  PenugasanModel({
    required this.id,
    required this.laporanId,
    required this.petugasId,
    required this.jenisKejadian,
    required this.lokasi,
    required this.deskripsi,
    required this.catatanAdmin,
    required this.status,
    required this.createdAt,
    this.fotoBuktiUrl,
    this.catatanPenutup,
    this.fotoKejadianUrls,
  });

  factory PenugasanModel.fromJson(Map<String, dynamic> json) {
    return PenugasanModel(
      id: json['id'],
      laporanId: json['laporanId'],
      petugasId: json['petugasId'],
      jenisKejadian: json['jenisKejadian'],
      lokasi: json['lokasi'],
      deskripsi: json['deskripsi'],
      catatanAdmin: json['catatanAdmin'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      fotoBuktiUrl: json['fotoBuktiUrl'],
      catatanPenutup: json['catatanPenutup'],
      fotoKejadianUrls: json['fotoKejadianUrls'] != null ? List<String>.from(json['fotoKejadianUrls']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'laporanId': laporanId,
      'petugasId': petugasId,
      'jenisKejadian': jenisKejadian,
      'lokasi': lokasi,
      'deskripsi': deskripsi,
      'catatanAdmin': catatanAdmin,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'fotoBuktiUrl': fotoBuktiUrl,
      'catatanPenutup': catatanPenutup,
      'fotoKejadianUrls': fotoKejadianUrls,
    };
  }

  PenugasanModel copyWith({
    String? id,
    String? laporanId,
    String? petugasId,
    String? jenisKejadian,
    String? lokasi,
    String? deskripsi,
    String? catatanAdmin,
    String? status,
    DateTime? createdAt,
    String? fotoBuktiUrl,
    String? catatanPenutup,
    List<String>? fotoKejadianUrls,
  }) {
    return PenugasanModel(
      id: id ?? this.id,
      laporanId: laporanId ?? this.laporanId,
      petugasId: petugasId ?? this.petugasId,
      jenisKejadian: jenisKejadian ?? this.jenisKejadian,
      lokasi: lokasi ?? this.lokasi,
      deskripsi: deskripsi ?? this.deskripsi,
      catatanAdmin: catatanAdmin ?? this.catatanAdmin,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      fotoBuktiUrl: fotoBuktiUrl ?? this.fotoBuktiUrl,
      catatanPenutup: catatanPenutup ?? this.catatanPenutup,
      fotoKejadianUrls: fotoKejadianUrls ?? this.fotoKejadianUrls,
    );
  }
}
