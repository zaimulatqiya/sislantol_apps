import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/laporan/laporan_bloc.dart';
import '../../blocs/laporan/laporan_event.dart';
import '../../blocs/laporan/laporan_state.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/pengguna/laporan_card.dart';
import '../../widgets/common/skeleton_loading.dart';
import 'riwayat_screen.dart';
import '../shared/profil_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _onBottomNavTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _BerandaPengguna(onSeeAll: () => _onBottomNavTapped(1)),
      const RiwayatScreen(),
      const ProfilScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: pages[_currentIndex],
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
              BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.home_filled)), label: 'Beranda'),
              BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.history)), label: 'Riwayat'),
              BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.person_outline)), label: 'Profil'),
            ],
          ),
        ),
      ),
    );
  }
}

class _BerandaPengguna extends StatefulWidget {
  final VoidCallback onSeeAll;

  const _BerandaPengguna({required this.onSeeAll});

  @override
  State<_BerandaPengguna> createState() => _BerandaPenggunaState();
}

class _BerandaPenggunaState extends State<_BerandaPengguna> {
  @override
  void initState() {
    super.initState();
    // Fetch reports for the logged in user
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      context.read<LaporanBloc>().add(LoadLaporan(userId: authState.user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthSuccess) {
            final user = authState.user;
            return SafeArea(
              top: false,
              child: Stack(
                children: [
                  Column(
                    children: [
                      // Header Section
                      Container(
                        padding: EdgeInsets.only(left: 20, right: 20, top: MediaQuery.of(context).padding.top + 24, bottom: 48),
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
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  user.nama.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hai, ${user.nama}',
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
                                    'Selamat datang di Sislantol',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white.withOpacity(0.85),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Action Card
                      Transform.translate(
                        offset: const Offset(0, -24),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.08),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                )
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.danger.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.sos_rounded, color: AppColors.danger, size: 36),
                                    ),
                                    const SizedBox(width: 16),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Butuh Bantuan?',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          SizedBox(height: 6),
                                          Text(
                                            'Laporkan kejadian atau hambatan di jalan tol segera.',
                                            style: TextStyle(fontSize: 13, color: AppColors.textBody, height: 1.4),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  child: CustomButton(
                                    label: 'LAPORKAN KEJADIAN',
                                    color: AppColors.danger,
                                    onPressed: () {
                                      Navigator.pushNamed(context, AppRoutes.penggunaLapor);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      // Active Reports Section
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Laporan Aktif',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: widget.onSeeAll,
                                    child: const Text(
                                      'Lihat Semua',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
                                    ),
                                  )
                                ],
                              ),
                              Expanded(
                                child: BlocBuilder<LaporanBloc, LaporanState>(
                                  builder: (context, state) {
                                    if (state is LaporanLoading) {
                                      return const SkeletonList(count: 2);
                                    } else if (state is LaporanLoaded) {
                                      final aktif = state.laporan.where((l) => l.status != 'selesai' && l.status != 'ditolak').toList();
                                      
                                      if (aktif.isEmpty) {
                                        return RefreshIndicator(
                                          onRefresh: () async {
                                            context.read<LaporanBloc>().add(LoadLaporan(userId: user.id, isRefresh: true));
                                            await Future.delayed(const Duration(seconds: 1));
                                          },
                                          child: ListView(
                                            physics: const AlwaysScrollableScrollPhysics(),
                                            children: const [
                                              SizedBox(height: 100),
                                              EmptyState(
                                                icon: Icons.assignment_turned_in_outlined,
                                                message: 'Tidak ada laporan aktif saat ini.',
                                              ),
                                            ],
                                          ),
                                        );
                                      }

                                      return RefreshIndicator(
                                        onRefresh: () async {
                                          context.read<LaporanBloc>().add(LoadLaporan(userId: user.id, isRefresh: true));
                                          await Future.delayed(const Duration(seconds: 1));
                                        },
                                        child: ListView.builder(
                                          physics: const AlwaysScrollableScrollPhysics(),
                                          padding: const EdgeInsets.only(top: 8),
                                          itemCount: aktif.length,
                                          itemBuilder: (context, index) {
                                            return LaporanCard(
                                              laporan: aktif[index],
                                              onTap: () {
                                                Navigator.pushNamed(
                                                  context,
                                                  AppRoutes.penggunaDetailLaporan,
                                                  arguments: aktif[index],
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      );
                                    } else if (state is LaporanFailure) {
                                      return Center(child: Text(state.message, style: const TextStyle(color: AppColors.danger)));
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
                ],
              ),
            );
          }
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        },
      );
  }
}
