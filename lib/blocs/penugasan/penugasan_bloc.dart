import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/penugasan_model.dart';
import '../../data/mock_data.dart';
import 'penugasan_event.dart';
import 'penugasan_state.dart';

class PenugasanBloc extends Bloc<PenugasanEvent, PenugasanState> {
  PenugasanBloc() : super(PenugasanInitial()) {
    on<LoadPenugasan>(_onLoad);
    on<UpdateStatusPenugasan>(_onUpdateStatus);
    on<SelesaikanTugas>(_onSelesaikan);
    on<DeletePenugasan>(_onDeletePenugasan);
  }

  Future<void> _onLoad(LoadPenugasan event, Emitter<PenugasanState> emit) async {
    emit(PenugasanLoading());
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      final tugasPetugas = MockData.penugasanList
          .where((p) => p.petugasId == event.petugasId)
          .toList();

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
    await Future.delayed(const Duration(milliseconds: 600));

    try {
      final index = MockData.penugasanList.indexWhere((p) => p.id == event.penugasanId);
      if (index != -1) {
        final existing = MockData.penugasanList[index];
        MockData.penugasanList[index] = existing.copyWith(status: event.statusBaru);
        
        emit(const PenugasanUpdateSuccess('Status berhasil diperbarui'));
        add(LoadPenugasan(petugasId: event.petugasId));
      } else {
        throw Exception('Penugasan tidak ditemukan');
      }
    } catch (e) {
      emit(PenugasanFailure(message: e.toString()));
    }
  }

  Future<void> _onSelesaikan(SelesaikanTugas event, Emitter<PenugasanState> emit) async {
    emit(PenugasanLoading());
    await Future.delayed(const Duration(seconds: 1));

    try {
      final index = MockData.penugasanList.indexWhere((p) => p.id == event.penugasanId);
      if (index != -1) {
        final existing = MockData.penugasanList[index];
        MockData.penugasanList[index] = existing.copyWith(
          status: 'selesai',
          fotoBuktiUrl: event.fotoPath,
          catatanPenutup: event.catatanPenutup,
        );

        emit(const PenugasanUpdateSuccess('Tugas berhasil diselesaikan'));
        add(LoadPenugasan(petugasId: event.petugasId));
      } else {
        throw Exception('Penugasan tidak ditemukan');
      }
    } catch (e) {
      emit(PenugasanFailure(message: e.toString()));
    }
  }

  Future<void> _onDeletePenugasan(DeletePenugasan event, Emitter<PenugasanState> emit) async {
    emit(PenugasanLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      MockData.penugasanList.removeWhere((p) => p.id == event.penugasanId);
      add(LoadPenugasan(petugasId: event.petugasId));
    } catch (e) {
      emit(PenugasanFailure(message: 'Gagal menghapus tugas: $e'));
    }
  }
}
