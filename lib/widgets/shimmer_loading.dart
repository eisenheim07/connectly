import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';

class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceContainerLow,
      highlightColor: AppColors.surfaceContainerHigh,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            _buildShimmerCard(height: 200),
            const SizedBox(height: 24),
            _buildShimmerCard(height: 200),
            const SizedBox(height: 32),
            _buildShimmerText(width: 150),
            const SizedBox(height: 16),
            _buildShimmerCard(height: 120),
            const SizedBox(height: 12),
            _buildShimmerCard(height: 120),
            const SizedBox(height: 12),
            _buildShimmerCard(height: 120),
            const SizedBox(height: 32),
            _buildShimmerCard(height: 240),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerCard({required double height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildShimmerText({required double width}) {
    return Container(
      height: 24,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
