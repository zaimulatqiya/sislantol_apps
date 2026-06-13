import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/penugasan/penugasan_bloc.dart';
import '../../blocs/penugasan/penugasan_event.dart';
import '../../blocs/penugasan/penugasan_state.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/petugas/tugas_card.dart';

class RiwayatTugasScreen extends StatefulWidget {
  const RiwayatTugasScreen({super.key});

  @override
  State<RiwayatTugasScreen> createState() => _RiwayatTugasScreenState();
}

class _RiwayatTugasScreenState extends State<RiwayatTugasScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      context.read<PenugasanBloc>().add(LoadPenugasan(petugasId: authState.user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Riwayat Penugasan', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: BlocBuilder<PenugasanBloc, PenugasanState>(
        builder: (context, state) {
          if (state is PenugasanLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PenugasanLoaded) {
            if (state.selesai.isEmpty) {
              return const EmptyState(
                icon: Icons.history_edu,
                message: 'Belum ada riwayat tugas selesai.',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: state.selesai.length,
              itemBuilder: (context, index) {
                final tugas = state.selesai[index];
                return Dismissible(
                  key: Key(tugas.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.danger,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          title: const Text("Konfirmasi Hapus", style: TextStyle(fontSize: 16)),
                          content: const Text("Apakah Anda yakin ingin menghapus riwayat tugas ini?"),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text("Batal", style: TextStyle(color: AppColors.textMuted)),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text("Hapus", style: TextStyle(color: AppColors.danger)),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  onDismissed: (direction) {
                    final authState = context.read<AuthBloc>().state;
                    if (authState is AuthSuccess) {
                      context.read<PenugasanBloc>().add(
                            DeletePenugasan(
                              penugasanId: tugas.id,
                              petugasId: authState.user.id,
                            ),
                          );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Riwayat tugas berhasil dihapus"),
                          backgroundColor: AppColors.success,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: TugasCard(
                    tugas: tugas,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.petugasDetailTugas,
                        arguments: tugas,
                      );
                    },
                  ),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
