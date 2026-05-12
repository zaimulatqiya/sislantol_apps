import 'package:equatable/equatable.dart';
import '../../models/penugasan_model.dart';

abstract class PenugasanState extends Equatable {
  const PenugasanState();

  @override
  List<Object?> get props => [];
}

class PenugasanInitial extends PenugasanState {}

class PenugasanLoading extends PenugasanState {}

class PenugasanLoaded extends PenugasanState {
  final List<PenugasanModel> aktif;
  final List<PenugasanModel> selesai;

  const PenugasanLoaded({required this.aktif, required this.selesai});

  @override
  List<Object?> get props => [aktif, selesai];
}

class PenugasanUpdateSuccess extends PenugasanState {
  final String message;
  const PenugasanUpdateSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class PenugasanFailure extends PenugasanState {
  final String message;

  const PenugasanFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
