import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/constants/app_routes.dart';
import '../core/theme/app_theme.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/laporan/laporan_bloc.dart';
import '../blocs/penugasan/penugasan_bloc.dart';
import '../features/splash/presentation/bloc/splash_cubit.dart';
import '../data/datasources/mock_auth_datasource.dart';
import '../data/datasources/mock_laporan_datasource.dart';
import '../data/datasources/mock_penugasan_datasource.dart';

import '../features/splash/presentation/screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';

import '../screens/pengguna/home_screen.dart' as pengguna;
import '../screens/pengguna/lapor_screen.dart';
import '../screens/pengguna/riwayat_screen.dart';
import '../screens/pengguna/detail_laporan_screen.dart';

import '../screens/petugas/home_screen.dart' as petugas;
import '../screens/petugas/detail_tugas_screen.dart';
import '../screens/petugas/riwayat_tugas_screen.dart';

import '../screens/shared/profil_screen.dart';

class SislantolApp extends StatelessWidget {
  const SislantolApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => AuthBloc(authDataSource: MockAuthDataSource())),
        BlocProvider<LaporanBloc>(create: (_) => LaporanBloc(laporanDataSource: MockLaporanDataSource())),
        BlocProvider<PenugasanBloc>(create: (_) => PenugasanBloc(penugasanDataSource: MockPenugasanDataSource())),
        BlocProvider<SplashCubit>(create: (_) => SplashCubit()),
      ],
      child: MaterialApp(
        title: 'Sislantol',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (context) => const SplashScreen(),
          AppRoutes.login: (context) => const LoginScreen(),
          AppRoutes.register: (context) => const RegisterScreen(),
          
          AppRoutes.penggunaHome: (context) => const pengguna.HomeScreen(),
          AppRoutes.penggunaLapor: (context) => const LaporScreen(),
          AppRoutes.penggunaRiwayat: (context) => const RiwayatScreen(),
          AppRoutes.penggunaDetailLaporan: (context) => const DetailLaporanScreen(),
          
          AppRoutes.petugasHome: (context) => const petugas.HomeScreen(),
          AppRoutes.petugasDetailTugas: (context) => const DetailTugasScreen(),
          AppRoutes.petugasRiwayat: (context) => const RiwayatTugasScreen(),
          
          AppRoutes.profil: (context) => const ProfilScreen(),
        },
      ),
    );
  }
}
