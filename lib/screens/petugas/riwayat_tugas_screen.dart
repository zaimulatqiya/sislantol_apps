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
import '../../widgets/common/skeleton_loading.dart';
import '../../widgets/common/custom_button.dart';

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

  void _confirmDeleteAll(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.danger.withOpacity(0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_sweep_rounded,
                    color: AppColors.danger,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Hapus Semua Riwayat?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Apakah Anda yakin ingin menghapus semua riwayat penugasan Anda? Tindakan ini tidak dapat dibatalkan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textBody,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Batal", style: TextStyle(color: AppColors.textHint, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        label: 'Hapus Semua',
                        color: AppColors.danger,
                        onPressed: () => Navigator.of(context).pop(true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirm == true) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthSuccess) {
        context.read<PenugasanBloc>().add(DeleteSemuaPenugasanPetugas(petugasId: authState.user.id));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Semua riwayat tugas berhasil dihapus"),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PenugasanBloc, PenugasanState>(
      builder: (context, state) {
        final bool hasData = state is PenugasanLoaded && state.selesai.isNotEmpty;
        
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Riwayat Penugasan', style: TextStyle(fontWeight: FontWeight.w600)),
            actions: [
              if (hasData)
                IconButton(
                  icon: const Icon(Icons.delete_sweep_rounded),
                  onPressed: () => _confirmDeleteAll(context),
                  tooltip: 'Hapus Semua',
                ),
            ],
          ),
          body: () {
          if (state is PenugasanLoading) {
            return const SkeletonList(count: 3, isPetugas: true, disablePadding: true, isRiwayat: true);
          } else if (state is PenugasanLoaded) {
            if (state.selesai.isEmpty) {
              return RefreshIndicator(
                onRefresh: () async {
                  final authState = context.read<AuthBloc>().state;
                  if (authState is AuthSuccess) {
                    context.read<PenugasanBloc>().add(LoadPenugasan(petugasId: authState.user.id, isRefresh: true));
                  }
                  await Future.delayed(const Duration(seconds: 1));
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 150),
                    EmptyState(
                      icon: Icons.history_edu,
                      message: 'Belum ada riwayat tugas selesai.',
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthSuccess) {
                  context.read<PenugasanBloc>().add(LoadPenugasan(petugasId: authState.user.id, isRefresh: true));
                }
                await Future.delayed(const Duration(seconds: 1));
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
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
                        return Dialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.danger.withOpacity(0.15),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.danger.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: AppColors.danger,
                                    size: 48,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  'Hapus Tugas Ini?',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Apakah Anda yakin ingin menghapus riwayat tugas ini secara permanen?',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textBody,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                        child: const Text("Batal", style: TextStyle(color: AppColors.textHint, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: CustomButton(
                                        label: 'Hapus',
                                        color: AppColors.danger,
                                        onPressed: () => Navigator.of(context).pop(true),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
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
            ),
            );
          } else if (state is PenugasanFailure) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: AppColors.danger),
              ),
            );
          }
          return const SizedBox();
        }(),
      );
      },
    );
  }
}
