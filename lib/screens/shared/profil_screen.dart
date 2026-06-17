import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/skeleton_loading.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil Akun', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthSuccess) {
            final user = state.user;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.1),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          )
                        ]
                      ),
                      child: Center(
                        child: Text(
                          user.nama.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.nama,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user.role.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.email_outlined, color: AppColors.primary),
                          title: const Text('Email', style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
                          subtitle: Text(user.email, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                        ),
                        const Divider(height: 1, color: AppColors.border, indent: 16, endIndent: 16),
                        ListTile(
                          leading: const Icon(Icons.phone_outlined, color: AppColors.primary),
                          title: const Text('Nomor HP', style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
                          subtitle: Text(user.noHp, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  CustomButton(
                    label: 'Keluar',
                    color: AppColors.danger,
                    onPressed: () {
                      context.read<AuthBloc>().add(LogoutRequested());
                      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
                    },
                  ),
                ],
              ),
            );
          }
          return const ProfilSkeleton();
        },
      ),
    );
  }
}
