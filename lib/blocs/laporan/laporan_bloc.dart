import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/laporan_model.dart';
import '../../data/datasources/supabase_laporan_datasource.dart';
import 'laporan_event.dart';
import 'laporan_state.dart';
import '../../utils/error_handler.dart';

class LaporanBloc extends Bloc<LaporanEvent, LaporanState> {
  final SupabaseLaporanDataSource laporanDataSource;

  /// Channel Supabase Realtime aktif (jika ada)
  RealtimeChannel? _realtimeChannel;

  LaporanBloc({required this.laporanDataSource}) : super(LaporanInitial()) {
    on<LoadLaporan>(_onLoadLaporan);
    on<LoadSemuaLaporan>(_onLoadSemuaLaporan);
    on<SubscribeLaporanRealtime>(_onSubscribeRealtime);
    on<UnsubscribeLaporanRealtime>(_onUnsubscribeRealtime);
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
      emit(LaporanFailure(message: ErrorHandler.cleanMessage(e)));
    }
  }

  Future<void> _onLoadSemuaLaporan(LoadSemuaLaporan event, Emitter<LaporanState> emit) async {
    emit(LaporanLoading());
    try {
      final semuaLaporan = await laporanDataSource.getAllLaporan();
      semuaLaporan.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      emit(LaporanLoaded(laporan: semuaLaporan));
    } catch (e) {
      emit(LaporanFailure(message: ErrorHandler.cleanMessage(e)));
    }
  }

  /// Mulai subscribe Supabase Realtime untuk pengguna tertentu.
  /// Jika channel sudah aktif, tidak melakukan apa-apa (mencegah duplikasi).
  Future<void> _onSubscribeRealtime(
    SubscribeLaporanRealtime event,
    Emitter<LaporanState> emit,
  ) async {
    // Guard: Jika sudah ada channel aktif, jangan buat yang baru
    if (_realtimeChannel != null) return;

    final supabase = Supabase.instance.client;
    final channelName = 'laporan-user-${event.userId}';

    _realtimeChannel = supabase
        .channel(channelName)
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'laporan',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: event.userId,
          ),
          callback: (payload) {
            // Saat ada perubahan di DB, reload data tanpa loading indicator
            if (!isClosed) {
              add(LoadLaporan(userId: event.userId, isRefresh: true));
            }
          },
        )
        .subscribe();
  }

  Future<void> _onUnsubscribeRealtime(
    UnsubscribeLaporanRealtime event,
    Emitter<LaporanState> emit,
  ) async {
    if (_realtimeChannel != null) {
      await Supabase.instance.client.removeChannel(_realtimeChannel!);
      _realtimeChannel = null;
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
        nomorPolisi: event.nomorPolisi,
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
      emit(LaporanFailure(message: ErrorHandler.cleanMessage(e)));
    }
  }

  Future<void> _onDeleteLaporan(DeleteLaporan event, Emitter<LaporanState> emit) async {
    emit(LaporanLoading());
    try {
      await laporanDataSource.deleteLaporan(event.id);
      // Re-load the specific user laporan
      add(LoadLaporan(userId: event.userId));
    } catch (e) {
      emit(LaporanFailure(message: ErrorHandler.cleanMessage(e)));
    }
  }

  Future<void> _onDeleteSemuaLaporanUser(DeleteSemuaLaporanUser event, Emitter<LaporanState> emit) async {
    emit(LaporanLoading());
    try {
      await laporanDataSource.deleteAllLaporanByUser(event.userId);
      add(LoadLaporan(userId: event.userId));
    } catch (e) {
      emit(LaporanFailure(message: ErrorHandler.cleanMessage(e)));
    }
  }

  @override
  Future<void> close() async {
    // Unsubscribe channel Realtime saat BLoC di-dispose
    if (_realtimeChannel != null) {
      await Supabase.instance.client.removeChannel(_realtimeChannel!);
      _realtimeChannel = null;
    }
    return super.close();
  }
}
