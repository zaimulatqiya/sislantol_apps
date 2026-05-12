import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class BadgeStatus extends StatelessWidget {
  final String status;

  const BadgeStatus({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color bg = AppColors.badgeWaitBg;
    Color text = AppColors.badgeWaitText;

    switch (status.toLowerCase()) {
      case 'menunggu':
      case 'diminta':
        bg = AppColors.badgeWaitBg;
        text = AppColors.badgeWaitText;
        break;
      case 'diverifikasi':
        bg = AppColors.badgeVerifyBg;
        text = AppColors.badgeVerifyText;
        break;
      case 'ditugaskan':
      case 'menuju':
      case 'tiba':
        bg = AppColors.badgeAssignBg;
        text = AppColors.badgeAssignText;
        break;
      case 'diterima':
        bg = AppColors.badgeAssignBg;
        text = AppColors.badgeAssignText;
        break;
      case 'proses':
        bg = AppColors.badgeProcessBg;
        text = AppColors.badgeProcessText;
        break;
      case 'selesai':
        bg = AppColors.badgeDoneBg;
        text = AppColors.badgeDoneText;
        break;
      case 'ditolak':
        bg = AppColors.badgeRejectBg;
        text = AppColors.badgeRejectText;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: text,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
