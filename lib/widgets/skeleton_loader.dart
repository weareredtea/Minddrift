// lib/widgets/skeleton_loader.dart

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme.dart';

class SkeletonLoader extends StatelessWidget {
  final double? width;
  final double? height;
  final BoxShape shape;

  const SkeletonLoader({
    super.key,
    this.width,
    this.height,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.surface.withOpacity(0.5),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: shape,
          borderRadius: shape == BoxShape.rectangle 
              ? BorderRadius.circular(12) 
              : null,
        ),
      ),
    );
  }
}
