import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/laporan_model.dart';
import '../../data/datasources/supabase_laporan_datasource.dart';
import 'laporan_event.dart';
import 'laporan_state.dart';

class LaporanBloc extends Bloc<LaporanEvent, LaporanState> {
  final SupabaseLaporanDataSource laporanDataSource;

  LaporanBloc({required this.laporanDataSource}) : super(LaporanInitial()) {
    on<LoadLaporan>(_onLoadLaporan);
    on<LoadSemuaLaporan>(_onLoadSemuaLaporan);
    on<SubmitLaporan>(_onSubmitLaporan);
    on<DeleteLaporan>(_onDeleteLaporan);
    on<DeleteSemuaLaporanUser>(_onDeleteSemuaLaporanUser);
  }

  Future<void> _onLoadLaporan(LoadLaporan event, Emitter<LaporanState> emit) async {
    if (!event.isRefresh) emit(LaporanLoading());
    try {
      final laporanUser = await laporanDataSource.getLaporanByUser(event.userId);
      // Sort desc by latest
      laporanUser.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      emit(LaporanLoaded(laporan: laporanUser));
    } catch (e) {
      emit(LaporanFailure(message: 'Error: $e'));
    }
  }

  Future<void> _onLoadSemuaLaporan(LoadSemuaLaporan event, Emitter<LaporanState> emit) async {
    emit(LaporanLoading());
    try {
      final semuaLaporan = await laporanDataSource.getAllLaporan();
      semuaLaporan.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      emit(LaporanLoaded(laporan: semuaLaporan));
    } catch (e) {
      emit(const LaporanFailure(message: 'Gagal memuat semua laporan.'));
    }
  }

  Future<void> _onSubmitLaporan(SubmitLaporan event, Emitter<LaporanState> emit) async {
    emit(LaporanLoading());
    try {
      final newLaporan = LaporanModel(
        id: 'l${DateTime.now().millisecondsSinceEpoch}',
        userId: event.userId,
        pelaporNama: event.pelaporNama,
        pelaporNoHp: event.pelaporNoHp,
        jenisKejadian: event.jenisKejadian,
        lokasi: event.lokasi,
        deskripsi: event.deskripsi,
        fotoUrls: event.fotoPaths, // mock as url array
        status: 'menunggu',
        createdAt: DateTime.now(),
      );

      await laporanDataSource.addLaporan(newLaporan);
      emit(LaporanSubmitSuccess());
      // Re-load the specific user laporan
      add(LoadLaporan(userId: event.userId));
    } catch (e) {
      emit(LaporanFailure(message: 'Gagal mengirim laporan: $e'));
    }
  }

  Future<void> _onDeleteLaporan(DeleteLaporan event, Emitter<LaporanState> emit) async {
    emit(LaporanLoading());
    try {
      await laporanDataSource.deleteLaporan(event.id);
      // Re-load the specific user laporan
      add(LoadLaporan(userId: event.userId));
    } catch (e) {
      emit(LaporanFailure(message: 'Gagal menghapus laporan: $e'));
    }
  }

  Future<void> _onDeleteSemuaLaporanUser(DeleteSemuaLaporanUser event, Emitter<LaporanState> emit) async {
    emit(LaporanLoading());
    try {
      await laporanDataSource.deleteAllLaporanByUser(event.userId);
      add(LoadLaporan(userId: event.userId));
    } catch (e) {
      emit(LaporanFailure(message: 'Gagal menghapus semua riwayat laporan: $e'));
    }
  }
}
