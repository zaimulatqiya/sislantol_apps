import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';

class SkeletonContainer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonContainer({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class LaporanCardSkeleton extends StatelessWidget {
  final bool isRiwayat;
  const LaporanCardSkeleton({super.key, this.isRiwayat = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              SkeletonContainer(width: 100, height: 14),
              SkeletonContainer(width: 70, height: 24, borderRadius: 12),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const SkeletonContainer(width: 48, height: 48, borderRadius: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SkeletonContainer(width: double.infinity, height: 16),
                    SizedBox(height: 6),
                    SkeletonContainer(width: 150, height: 14),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const SkeletonContainer(width: 20, height: 20, borderRadius: 10),
            ],
          ),
        ],
      ),
    );
  }
}

class TugasCardSkeleton extends StatelessWidget {
  final bool isRiwayat;
  const TugasCardSkeleton({super.key, this.isRiwayat = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              SkeletonContainer(width: 80, height: 14),
              SkeletonContainer(width: 70, height: 24, borderRadius: 12),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SkeletonContainer(width: 48, height: 48, borderRadius: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SkeletonContainer(width: double.infinity, height: 16),
                    SizedBox(height: 6),
                    SkeletonContainer(width: double.infinity, height: 14),
                    SizedBox(height: 10),
                    SkeletonContainer(width: 120, height: 12),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const SkeletonContainer(width: 20, height: 20, borderRadius: 10),
            ],
          ),
          if (isRiwayat) ...[
            const Padding(
              padding: EdgeInsets.only(top: 16, bottom: 12),
              child: Divider(height: 1, color: AppColors.border),
            ),
            const SkeletonContainer(width: 140, height: 12),
            const SizedBox(height: 8),
            const SkeletonContainer(width: double.infinity, height: 120, borderRadius: 12),
            const SizedBox(height: 12),
            const SkeletonContainer(width: 100, height: 12),
            const SizedBox(height: 4),
            const SkeletonContainer(width: double.infinity, height: 14),
          ],
        ],
      ),
    );
  }
}

class SkeletonList extends StatelessWidget {
  final int count;
  final bool isPetugas;
  final bool disablePadding;
  final bool isRiwayat;
  
  const SkeletonList({
    super.key, 
    this.count = 3,
    this.isPetugas = false,
    this.disablePadding = false,
    this.isRiwayat = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: disablePadding ? EdgeInsets.zero : const EdgeInsets.only(top: 8),
      itemCount: count,
      itemBuilder: (context, index) {
        if (isPetugas) {
          return TugasCardSkeleton(isRiwayat: isRiwayat);
        }
        return LaporanCardSkeleton(isRiwayat: isRiwayat);
      },
    );
  }
}

class ProfilSkeleton extends StatelessWidget {
  const ProfilSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Center(
            child: SkeletonContainer(width: 100, height: 100, borderRadius: 50),
          ),
          const SizedBox(height: 16),
          const SkeletonContainer(width: 200, height: 28, borderRadius: 14),
          const SizedBox(height: 8),
          const SkeletonContainer(width: 80, height: 24, borderRadius: 12),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
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
              children: const [
                SkeletonContainer(width: double.infinity, height: 20),
                SizedBox(height: 24),
                SkeletonContainer(width: double.infinity, height: 20),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const SkeletonContainer(width: double.infinity, height: 50, borderRadius: 14),
        ],
      ),
    );
  }
}
