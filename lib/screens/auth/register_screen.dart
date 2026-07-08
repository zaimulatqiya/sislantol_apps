import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../utils/network_ui_helper.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _noHpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  String? _localErrorMessage;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _noHpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Daftar Akun', style: TextStyle(fontWeight: FontWeight.w600)),
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            // Automatically log in and dispatch to penggunaHome (pengguna jalan)
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.penggunaHome,
              (route) => false,
            );
          } else if (state is AuthFailure) {
            NetworkUIHelper.showNetworkErrorSnackbar(context, message: state.message);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Buat Akun Baru',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Daftar sebagai Pengguna Jalan',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textBody,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.08),
                        blurRadius: 32,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      if (_localErrorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.danger.withOpacity(0.5)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: AppColors.danger, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _localErrorMessage!,
                                  style: const TextStyle(
                                    color: AppColors.danger,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            CustomTextField(
                              label: 'Nama Lengkap',
                              hint: 'Nama sesuai KTP/SIM',
                              controller: _namaController,
                              validator: (val) => val == null || val.trim().isEmpty ? 'Nama wajib diisi' : null,
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              label: 'Email',
                              hint: 'email@contoh.com',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'Email wajib diisi';
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) return 'Format email tidak valid';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              label: 'Nomor HP',
                              hint: '08xxxxxxxxx',
                              controller: _noHpController,
                              keyboardType: TextInputType.phone,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'Nomor HP wajib diisi';
                                if (!RegExp(r'^[0-9]+$').hasMatch(val)) return 'Hanya boleh berisi angka';
                                if (val.length < 10) return 'Nomor HP terlalu pendek';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              label: 'Password',
                              hint: 'Minimal 6 karakter',
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              validator: (val) => val == null || val.length < 6 ? 'Password minimal 6 karakter' : null,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  size: 16,
                                  color: AppColors.textHint,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              label: 'Konfirmasi Password',
                              hint: 'Tulis ulang password',
                              controller: _confirmPasswordController,
                              obscureText: _obscurePassword,
                              validator: (val) {
                                if (val == null || val.isEmpty) return 'Konfirmasi password wajib diisi';
                                if (val != _passwordController.text) return 'Password tidak cocok';
                                return null;
                              },
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              child: CustomButton(
                                label: 'Daftar Sekarang',
                                isLoading: state is AuthLoading,
                                onPressed: () {
                                  setState(() {
                                    _localErrorMessage = null;
                                  });
                                  if (_formKey.currentState!.validate()) {
                                    if (_passwordController.text != _confirmPasswordController.text) {
                                      setState(() {
                                        _localErrorMessage = 'Password tidak cocok';
                                      });
                                      return;
                                    }
                                    context.read<AuthBloc>().add(
                                          RegisterSubmitted(
                                            nama: _namaController.text,
                                            email: _emailController.text,
                                            noHp: _noHpController.text,
                                            password: _passwordController.text,
                                          ),
                                        );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
