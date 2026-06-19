import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/supabase_penugasan_datasource.dart';
import 'penugasan_event.dart';
import 'penugasan_state.dart';
import '../../utils/error_handler.dart';

class PenugasanBloc extends Bloc<PenugasanEvent, PenugasanState> {
  final SupabasePenugasanDataSource penugasanDataSource;

  PenugasanBloc({required this.penugasanDataSource}) : super(PenugasanInitial()) {
    on<LoadPenugasan>(_onLoad);
    on<UpdateStatusPenugasan>(_onUpdateStatus);
    on<SelesaikanTugas>(_onSelesaikan);
    on<DeletePenugasan>(_onDeletePenugasan);
    on<DeleteSemuaPenugasanPetugas>(_onDeleteSemuaPenugasanPetugas);
  }

  Future<void> _onLoad(LoadPenugasan event, Emitter<PenugasanState> emit) async {
    if (!event.isRefresh) emit(PenugasanLoading());
    try {
      final tugasPetugas = await penugasanDataSource.getPenugasanByPetugas(event.petugasId);

      final aktif = tugasPetugas.where((p) => p.status != 'selesai').toList();
      final selesai = tugasPetugas.where((p) => p.status == 'selesai').toList();

      aktif.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      selesai.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      emit(PenugasanLoaded(aktif: aktif, selesai: selesai));
    } catch (e) {
      emit(PenugasanFailure(message: ErrorHandler.cleanMessage(e)));
    }
  }

  Future<void> _onUpdateStatus(UpdateStatusPenugasan event, Emitter<PenugasanState> emit) async {
    emit(PenugasanLoading());
    try {
      await penugasanDataSource.updateStatusPenugasan(event.penugasanId, event.statusBaru);
      emit(const PenugasanUpdateSuccess('Status berhasil diperbarui'));
      add(LoadPenugasan(petugasId: event.petugasId));
    } catch (e) {
      emit(PenugasanFailure(message: ErrorHandler.cleanMessage(e)));
    }
  }

  Future<void> _onSelesaikan(SelesaikanTugas event, Emitter<PenugasanState> emit) async {
    emit(PenugasanLoading());
    try {
      // Kita perlu mencari penugasan terkait dari state saat ini atau nge-fetch karena kita butuh laporanId
      // Lebih mudah fetch saja atau menganggap laporanId dikirim di event (karena belum, kita ambil dari list)
      final tugasList = await penugasanDataSource.getPenugasanByPetugas(event.petugasId);
      final existing = tugasList.firstWhere((p) => p.id == event.penugasanId);

      if (event.fotoPath == null) {
        throw Exception("Foto bukti wajib dilampirkan");
      }

      await penugasanDataSource.selesaikanTugas(
        penugasanId: existing.id,
        laporanId: existing.laporanId,
        fotoPath: event.fotoPath!,
        catatanPenutup: event.catatanPenutup ?? '',
      );

      emit(const PenugasanUpdateSuccess('Tugas berhasil diselesaikan'));
      add(LoadPenugasan(petugasId: event.petugasId));
    } catch (e) {
      emit(PenugasanFailure(message: ErrorHandler.cleanMessage(e)));
    }
  }

  Future<void> _onDeletePenugasan(DeletePenugasan event, Emitter<PenugasanState> emit) async {
    emit(PenugasanLoading());
    try {
      await penugasanDataSource.deletePenugasan(event.penugasanId);
      add(LoadPenugasan(petugasId: event.petugasId));
    } catch (e) {
      emit(PenugasanFailure(message: ErrorHandler.cleanMessage(e)));
    }
  }

  Future<void> _onDeleteSemuaPenugasanPetugas(DeleteSemuaPenugasanPetugas event, Emitter<PenugasanState> emit) async {
    emit(PenugasanLoading());
    try {
      await penugasanDataSource.deleteAllPenugasanByPetugas(event.petugasId);
      add(LoadPenugasan(petugasId: event.petugasId));
    } catch (e) {
      emit(PenugasanFailure(message: ErrorHandler.cleanMessage(e)));
    }
  }
}
