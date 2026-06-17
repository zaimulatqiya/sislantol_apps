import 'package:equatable/equatable.dart';

abstract class PenugasanEvent extends Equatable {
  const PenugasanEvent();

  @override
  List<Object?> get props => [];
}

class LoadPenugasan extends PenugasanEvent {
  final String petugasId;
  final bool isRefresh;

  const LoadPenugasan({required this.petugasId, this.isRefresh = false});

  @override
  List<Object?> get props => [petugasId, isRefresh];
}

class UpdateStatusPenugasan extends PenugasanEvent {
  final String penugasanId;
  final String statusBaru;
  final String petugasId; // To reload data

  const UpdateStatusPenugasan({
    required this.penugasanId,
    required this.statusBaru,
    required this.petugasId,
  });

  @override
  List<Object?> get props => [penugasanId, statusBaru, petugasId];
}

class SelesaikanTugas extends PenugasanEvent {
  final String penugasanId;
  final String? fotoPath;
  final String? catatanPenutup;
  final String petugasId; // To reload data

  const SelesaikanTugas({
    required this.penugasanId,
    this.fotoPath,
    this.catatanPenutup,
    required this.petugasId,
  });

  @override
  List<Object?> get props => [penugasanId, fotoPath, catatanPenutup, petugasId];
}

class DeletePenugasan extends PenugasanEvent {
  final String penugasanId;
  final String petugasId;

  const DeletePenugasan({
    required this.penugasanId,
    required this.petugasId,
  });

  @override
  List<Object?> get props => [penugasanId, petugasId];
}

class DeleteSemuaPenugasanPetugas extends PenugasanEvent {
  final String petugasId;

  const DeleteSemuaPenugasanPetugas({required this.petugasId});

  @override
  List<Object?> get props => [petugasId];
}
