import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/penugasan_model.dart';
import '../../data/datasources/mock_penugasan_datasource.dart';
import 'penugasan_event.dart';
import 'penugasan_state.dart';

class PenugasanBloc extends Bloc<PenugasanEvent, PenugasanState> {
  final MockPenugasanDataSource penugasanDataSource;

  PenugasanBloc({required this.penugasanDataSource}) : super(PenugasanInitial()) {
    on<LoadPenugasan>(_onLoad);
    on<UpdateStatusPenugasan>(_onUpdateStatus);
    on<SelesaikanTugas>(_onSelesaikan);
    on<DeletePenugasan>(_onDeletePenugasan);
  }

  Future<void> _onLoad(LoadPenugasan event, Emitter<PenugasanState> emit) async {
    emit(PenugasanLoading());
    try {
      final tugasPetugas = await penugasanDataSource.getPenugasanByPetugas(event.petugasId);

      final aktif = tugasPetugas.where((p) => p.status != 'selesai').toList();
      final selesai = tugasPetugas.where((p) => p.status == 'selesai').toList();

      aktif.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      selesai.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      emit(PenugasanLoaded(aktif: aktif, selesai: selesai));
    } catch (e) {
      emit(const PenugasanFailure(message: 'Gagal memuat data penugasan.'));
    }
  }

  Future<void> _onUpdateStatus(UpdateStatusPenugasan event, Emitter<PenugasanState> emit) async {
    emit(PenugasanLoading());
    try {
      final allPenugasan = await penugasanDataSource.getAllPenugasan();
      final existing = allPenugasan.firstWhere((p) => p.id == event.penugasanId);
      
      final updated = existing.copyWith(status: event.statusBaru);
      await penugasanDataSource.updatePenugasan(updated);
      
      emit(const PenugasanUpdateSuccess('Status berhasil diperbarui'));
      add(LoadPenugasan(petugasId: event.petugasId));
    } catch (e) {
      emit(PenugasanFailure(message: 'Penugasan tidak ditemukan atau gagal diupdate: $e'));
    }
  }

  Future<void> _onSelesaikan(SelesaikanTugas event, Emitter<PenugasanState> emit) async {
    emit(PenugasanLoading());
    try {
      final allPenugasan = await penugasanDataSource.getAllPenugasan();
      final existing = allPenugasan.firstWhere((p) => p.id == event.penugasanId);

      final updated = existing.copyWith(
        status: 'selesai',
        fotoBuktiUrl: event.fotoPath,
        catatanPenutup: event.catatanPenutup,
      );

      await penugasanDataSource.updatePenugasan(updated);

      emit(const PenugasanUpdateSuccess('Tugas berhasil diselesaikan'));
      add(LoadPenugasan(petugasId: event.petugasId));
    } catch (e) {
      emit(PenugasanFailure(message: 'Penugasan tidak ditemukan atau gagal diselesaikan: $e'));
    }
  }

  Future<void> _onDeletePenugasan(DeletePenugasan event, Emitter<PenugasanState> emit) async {
    emit(PenugasanLoading());
    try {
      await penugasanDataSource.removePenugasan(event.penugasanId);
      add(LoadPenugasan(petugasId: event.petugasId));
    } catch (e) {
      emit(PenugasanFailure(message: 'Gagal menghapus tugas: $e'));
    }
  }
}
