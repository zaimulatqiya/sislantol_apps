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
  final String? pelaporNama;
  final String? nomorPolisi;
  final String? fotoBuktiUrl;
  final String? catatanPenutup;
  final List<String>? fotoKejadianUrls;
  final DateTime? menujuLokasiAt;
  final DateTime? tibaLokasiAt;
  final DateTime? prosesAt;
  final DateTime? selesaiAt;

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

  String _formatDuration(Duration duration) {
    if (duration.inMinutes < 60) {
      return '${duration.inMinutes} menit';
    } else {
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);
      return minutes > 0 ? '$hours jam $minutes menit' : '$hours jam';
    }
  }

  String get waktuTempuh {
    if (tibaLokasiAt == null || menujuLokasiAt == null) return '-';
    return _formatDuration(tibaLokasiAt!.difference(menujuLokasiAt!));
  }

  String get waktuPenanganan {
    if (selesaiAt == null || prosesAt == null) return '-';
    return _formatDuration(selesaiAt!.difference(prosesAt!));
  }

  String get totalWaktuPenanganan {
    if (selesaiAt == null || menujuLokasiAt == null) return '-';
    return _formatDuration(selesaiAt!.difference(menujuLokasiAt!));
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
    this.pelaporNama,
    this.nomorPolisi,
    this.fotoBuktiUrl,
    this.catatanPenutup,
    this.fotoKejadianUrls,
    this.menujuLokasiAt,
    this.tibaLokasiAt,
    this.prosesAt,
    this.selesaiAt,
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
      pelaporNama: json['pelaporNama'],
      nomorPolisi: json['nomorPolisi'],
      fotoBuktiUrl: json['fotoBuktiUrl'],
      catatanPenutup: json['catatanPenutup'],
      fotoKejadianUrls: json['fotoKejadianUrls'] != null ? List<String>.from(json['fotoKejadianUrls']) : null,
      menujuLokasiAt: json['menujuLokasiAt'] != null ? DateTime.parse(json['menujuLokasiAt']) : null,
      tibaLokasiAt: json['tibaLokasiAt'] != null ? DateTime.parse(json['tibaLokasiAt']) : null,
      prosesAt: json['prosesAt'] != null ? DateTime.parse(json['prosesAt']) : null,
      selesaiAt: json['selesaiAt'] != null ? DateTime.parse(json['selesaiAt']) : null,
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
      'pelaporNama': pelaporNama,
      'nomorPolisi': nomorPolisi,
      'fotoBuktiUrl': fotoBuktiUrl,
      'catatanPenutup': catatanPenutup,
      'fotoKejadianUrls': fotoKejadianUrls,
      'menujuLokasiAt': menujuLokasiAt?.toIso8601String(),
      'tibaLokasiAt': tibaLokasiAt?.toIso8601String(),
      'prosesAt': prosesAt?.toIso8601String(),
      'selesaiAt': selesaiAt?.toIso8601String(),
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
    String? pelaporNama,
    String? nomorPolisi,
    String? fotoBuktiUrl,
    String? catatanPenutup,
    List<String>? fotoKejadianUrls,
    DateTime? menujuLokasiAt,
    DateTime? tibaLokasiAt,
    DateTime? prosesAt,
    DateTime? selesaiAt,
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
      pelaporNama: pelaporNama ?? this.pelaporNama,
      nomorPolisi: nomorPolisi ?? this.nomorPolisi,
      fotoBuktiUrl: fotoBuktiUrl ?? this.fotoBuktiUrl,
      catatanPenutup: catatanPenutup ?? this.catatanPenutup,
      fotoKejadianUrls: fotoKejadianUrls ?? this.fotoKejadianUrls,
      menujuLokasiAt: menujuLokasiAt ?? this.menujuLokasiAt,
      tibaLokasiAt: tibaLokasiAt ?? this.tibaLokasiAt,
      prosesAt: prosesAt ?? this.prosesAt,
      selesaiAt: selesaiAt ?? this.selesaiAt,
    );
  }
}
