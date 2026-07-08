import 'package:equatable/equatable.dart';

abstract class LaporanEvent extends Equatable {
  const LaporanEvent();

  @override
  List<Object?> get props => [];
}

/// Mulai mendengarkan perubahan real-time pada tabel laporan
/// untuk pengguna tertentu. Hanya perlu dipanggil sekali.
class SubscribeLaporanRealtime extends LaporanEvent {
  final String userId;

  const SubscribeLaporanRealtime({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Berhenti mendengarkan perubahan real-time pada tabel laporan
class UnsubscribeLaporanRealtime extends LaporanEvent {}

class LoadLaporan extends LaporanEvent {
  final String userId;
  final bool isRefresh;

  const LoadLaporan({required this.userId, this.isRefresh = false});

  @override
  List<Object?> get props => [userId, isRefresh];
}

class LoadSemuaLaporan extends LaporanEvent {}

class SubmitLaporan extends LaporanEvent {
  final String userId;
  final String pelaporNama;
  final String pelaporNoHp;
  final String jenisKejadian;
  final String lokasi;
  final String deskripsi;
  final List<String>? fotoPaths;

  const SubmitLaporan({
    required this.userId,
    required this.pelaporNama,
    required this.pelaporNoHp,
    required this.jenisKejadian,
    required this.lokasi,
    required this.deskripsi,
    this.fotoPaths,
  });

  @override
  List<Object?> get props => [
        userId,
        pelaporNama,
        pelaporNoHp,
        jenisKejadian,
        lokasi,
        deskripsi,
        fotoPaths,
      ];
}

class DeleteLaporan extends LaporanEvent {
  final String id;
  final String userId;

  const DeleteLaporan({required this.id, required this.userId});

  @override
  List<Object?> get props => [id, userId];
}

class DeleteSemuaLaporanUser extends LaporanEvent {
  final String userId;

  const DeleteSemuaLaporanUser({required this.userId});

  @override
  List<Object?> get props => [userId];
}
