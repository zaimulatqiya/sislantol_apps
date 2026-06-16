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
import 'riwayat_tugas_screen.dart';
import '../shared/profil_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _DasborPetugas(),
    const RiwayatTugasScreen(),
    const ProfilScreen(),
  ];

  void _onBottomNavTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onBottomNavTapped,
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textHint,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.dashboard_rounded)), label: 'Dasbor'),
              BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.assignment_turned_in)), label: 'Riwayat Tugas'),
              BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.person_outline)), label: 'Profil'),
            ],
          ),
        ),
      ),
    );
  }
}

class _DasborPetugas extends StatefulWidget {
  const _DasborPetugas();

  @override
  State<_DasborPetugas> createState() => _DasborPetugasState();
}

class _DasborPetugasState extends State<_DasborPetugas> {
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
    return BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthSuccess) {
            final user = authState.user;
            return SafeArea(
              child: Column(
                children: [
                  // Header Segment
                  Container(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 48),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, Color(0xFF2A5298)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hai Petugas ${user.nama}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Siap bertugas hari ini?',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.85),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Tersedia',
                                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          const Text(
                            'Tugas Saat Ini',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: BlocBuilder<PenugasanBloc, PenugasanState>(
                              builder: (context, state) {
                                if (state is PenugasanLoading) {
                                  return const Center(child: CircularProgressIndicator());
                                } else if (state is PenugasanLoaded) {
                                  if (state.aktif.isEmpty) {
                                    return const EmptyState(
                                      icon: Icons.check_circle_outline,
                                      message: 'Tidak ada tugas aktif.',
                                    );
                                  }
                                  
                                  return ListView.builder(
                                    itemCount: state.aktif.length,
                                    itemBuilder: (context, index) {
                                      return TugasCard(
                                        tugas: state.aktif[index],
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context,
                                            AppRoutes.petugasDetailTugas,
                                            arguments: state.aktif[index],
                                          );
                                        },
                                      );
                                    },
                                  );
                                }
                                return const SizedBox();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      );
  }
}
