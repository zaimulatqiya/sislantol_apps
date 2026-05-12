import 'package:equatable/equatable.dart';
import '../../models/laporan_model.dart';

abstract class LaporanState extends Equatable {
  const LaporanState();

  @override
  List<Object?> get props => [];
}

class LaporanInitial extends LaporanState {}

class LaporanLoading extends LaporanState {}

class LaporanLoaded extends LaporanState {
  final List<LaporanModel> laporan;

  const LaporanLoaded({required this.laporan});

  @override
  List<Object?> get props => [laporan];
}

class LaporanSubmitSuccess extends LaporanState {}

class LaporanFailure extends LaporanState {
  final String message;

  const LaporanFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
