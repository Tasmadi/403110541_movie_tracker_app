import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showTitle;
  final bool showTagline;

  const AppLogo({
    super.key,
    this.size = 120,
    this.showTitle = true,
    this.showTagline = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLogo(),
        if (showTitle) ...[
          SizedBox(
            height: size * 0.18,
          ),
          _buildTitle(),
        ],
        if (showTagline) ...[
          SizedBox(
            height: size * 0.07,
          ),
          Text(
            'Track • Watch • Enjoy',
            textDirection: TextDirection.ltr,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: size * 0.12,
              fontWeight: FontWeight.w400,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLogo() {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 0.82,
            height: size * 0.70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                size * 0.20,
              ),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryLight,
                  AppColors.primary,
                  Color(0xFF5136D8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(
                    0.35,
                  ),
                  blurRadius: size * 0.20,
                  spreadRadius: size * 0.02,
                ),
              ],
            ),
            padding: EdgeInsets.all(
              size * 0.065,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(
                  0xFF111119,
                ),
                borderRadius: BorderRadius.circular(
                  size * 0.15,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.play_arrow_rounded,
                  size: size * 0.42,
                  color: AppColors.secondary,
                ),
              ),
            ),
          ),

          // آنتن سمت چپ
          Positioned(
            top: size * 0.045,
            left: size * 0.32,
            child: Transform.rotate(
              angle: -0.65,
              child: Container(
                width: size * 0.045,
                height: size * 0.25,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(
                    20,
                  ),
                ),
              ),
            ),
          ),

          // آنتن سمت راست
          Positioned(
            top: size * 0.045,
            right: size * 0.32,
            child: Transform.rotate(
              angle: 0.65,
              child: Container(
                width: size * 0.045,
                height: size * 0.25,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(
                    20,
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: 0,
            left: size * 0.25,
            child: _buildAntennaDot(),
          ),

          Positioned(
            top: 0,
            right: size * 0.25,
            child: _buildAntennaDot(),
          ),

          // نشان ساعت
          Positioned(
            right: 0,
            bottom: size * 0.06,
            child: Container(
              width: size * 0.34,
              height: size * 0.34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(
                  0xFF181820,
                ),
                border: Border.all(
                  color: AppColors.secondary,
                  width: size * 0.035,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(
                      0.20,
                    ),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Icon(
                Icons.schedule_rounded,
                color: AppColors.secondary,
                size: size * 0.20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAntennaDot() {
    return Container(
      width: size * 0.10,
      height: size * 0.10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryLight,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(
              0.35,
            ),
            blurRadius: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'TV',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: size * 0.26,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          SizedBox(
            width: size * 0.045,
          ),
          Text(
            'Time',
            style: TextStyle(
              color: AppColors.primaryLight,
              fontSize: size * 0.26,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
