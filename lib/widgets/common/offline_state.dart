import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'custom_button.dart';

class OfflineState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;
  final bool isLoading;

  const OfflineState({
    super.key,
    this.title = 'Koneksi Terputus',
    this.message = 'Sepertinya Anda sedang tidak terhubung ke internet. Silakan periksa koneksi Anda dan coba lagi.',
    required this.onRetry,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 64,
                color: AppColors.danger,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textMuted,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                label: 'Coba Lagi',
                onPressed: isLoading ? null : onRetry,
                isLoading: isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
