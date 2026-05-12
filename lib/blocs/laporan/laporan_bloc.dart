import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/laporan_model.dart';
import '../../data/mock_data.dart';
import 'laporan_event.dart';
import 'laporan_state.dart';

class LaporanBloc extends Bloc<LaporanEvent, LaporanState> {
  static const String _laporanKey = 'laporan_list';
  bool _isInitialized = false;

  LaporanBloc() : super(LaporanInitial()) {
    on<LoadLaporan>(_onLoadLaporan);
    on<LoadSemuaLaporan>(_onLoadSemuaLaporan);
    on<SubmitLaporan>(_onSubmitLaporan);
    on<DeleteLaporan>(_onDeleteLaporan);
  }

  Future<void> _initDataIfNeeded() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? laporanJson = prefs.getString(_laporanKey);
      if (laporanJson != null) {
        final List<dynamic> decoded = jsonDecode(laporanJson);
        MockData.laporanList.clear();
        MockData.laporanList.addAll(decoded.map((e) => LaporanModel.fromJson(e)).toList());
      }
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error init data laporan: $e');
      // Ignore initialization errors
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> encoded = MockData.laporanList.map((e) => e.toJson()).toList();
      await prefs.setString(_laporanKey, jsonEncode(encoded));
    } catch (e) {
      debugPrint('Error save data laporan: $e');
      // Ignore saving errors
    }
  }

  Future<void> _onLoadLaporan(LoadLaporan event, Emitter<LaporanState> emit) async {
    emit(LaporanLoading());
    await _initDataIfNeeded();
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate loading
    
    try {
      final laporanUser = MockData.laporanList.where((l) => l.userId == event.userId).toList();
      // Sort desc by latest
      laporanUser.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      emit(LaporanLoaded(laporan: laporanUser));
    } catch (e) {
      emit(LaporanFailure(message: 'Gagal memuat laporan.'));
    }
  }

  Future<void> _onLoadSemuaLaporan(LoadSemuaLaporan event, Emitter<LaporanState> emit) async {
    emit(LaporanLoading());
    await _initDataIfNeeded();
    await Future.delayed(const Duration(milliseconds: 800));
    try {
      final semuaLaporan = List<LaporanModel>.from(MockData.laporanList);
      semuaLaporan.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      emit(LaporanLoaded(laporan: semuaLaporan));
    } catch (e) {
      emit(LaporanFailure(message: 'Gagal memuat semua laporan.'));
    }
  }

  Future<void> _onSubmitLaporan(SubmitLaporan event, Emitter<LaporanState> emit) async {
    emit(LaporanLoading());
    await _initDataIfNeeded();
    await Future.delayed(const Duration(seconds: 1)); // Simulate api call
    
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

      MockData.laporanList.add(newLaporan);
      await _saveData(); // Save to SharedPreferences
      emit(LaporanSubmitSuccess());
      // Re-load the specific user laporan
      add(LoadLaporan(userId: event.userId));
    } catch (e) {
      emit(LaporanFailure(message: 'Gagal mengirim laporan: $e'));
    }
  }

  Future<void> _onDeleteLaporan(DeleteLaporan event, Emitter<LaporanState> emit) async {
    emit(LaporanLoading());
    await _initDataIfNeeded();
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate api call
    
    try {
      MockData.laporanList.removeWhere((l) => l.id == event.id);
      await _saveData(); // Save to SharedPreferences
      
      // Re-load the specific user laporan
      add(LoadLaporan(userId: event.userId));
    } catch (e) {
      emit(LaporanFailure(message: 'Gagal menghapus laporan: $e'));
    }
  }
}
