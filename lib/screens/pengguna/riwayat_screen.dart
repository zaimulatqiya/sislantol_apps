import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/laporan/laporan_bloc.dart';
import '../../blocs/laporan/laporan_event.dart';
import '../../blocs/laporan/laporan_state.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/pengguna/laporan_card.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  @override
  void initState() {
    super.initState();
    // Load if needed
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      context.read<LaporanBloc>().add(LoadLaporan(userId: authState.user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Riwayat Laporan', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: BlocBuilder<LaporanBloc, LaporanState>(
        builder: (context, state) {
          if (state is LaporanLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is LaporanLoaded) {
            if (state.laporan.isEmpty) {
              return const EmptyState(
                icon: Icons.history_rounded,
                message: 'Belum ada riwayat laporan.',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: state.laporan.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(state.laporan[index].id),
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
                          content: const Text("Apakah Anda yakin ingin menghapus riwayat laporan ini?"),
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
                      context.read<LaporanBloc>().add(
                            DeleteLaporan(
                              id: state.laporan[index].id,
                              userId: authState.user.id,
                            ),
                          );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Laporan berhasil dihapus"),
                          backgroundColor: AppColors.success,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: LaporanCard(
                    laporan: state.laporan[index],
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.penggunaDetailLaporan,
                        arguments: state.laporan[index],
                      );
                    },
                  ),
                );
              },
            );
          } else if (state is LaporanFailure) {
            return Center(child: Text(state.message));
          }
          return const SizedBox();
        },
      ),
    );
  }
}
