import 'package:equatable/equatable.dart';

abstract class LaporanEvent extends Equatable {
  const LaporanEvent();

  @override
  List<Object?> get props => [];
}

class LoadLaporan extends LaporanEvent {
  final String userId;

  const LoadLaporan({required this.userId});

  @override
  List<Object?> get props => [userId];
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
