import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class CinemaBackground extends StatelessWidget {
  final Widget child;

  const CinemaBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF09090E),
                  Color(0xFF121024),
                  AppColors.background,
                  Color(0xFF0A0912),
                ],
                stops: [
                  0,
                  0.35,
                  0.72,
                  1,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: -130,
          right: -100,
          child: _buildGlow(
            size: 330,
            color: AppColors.primary,
          ),
        ),
        Positioned(
          bottom: -160,
          left: -130,
          child: _buildGlow(
            size: 360,
            color: AppColors.primaryLight,
          ),
        ),
        Positioned(
          top: 105,
          left: -70,
          right: -70,
          child: Transform.rotate(
            angle: -0.18,
            child: const _FilmStrip(),
          ),
        ),
        Positioned(
          bottom: 55,
          left: -70,
          right: -70,
          child: Transform.rotate(
            angle: 0.17,
            child: const _FilmStrip(),
          ),
        ),
        Positioned.fill(
          child: child,
        ),
      ],
    );
  }

  Widget _buildGlow({
    required double size,
    required Color color,
  }) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withOpacity(
                0.16,
              ),
              color.withOpacity(
                0.05,
              ),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

class _FilmStrip extends StatelessWidget {
  const _FilmStrip();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: 0.15,
        child: Container(
          height: 66,
          decoration: const BoxDecoration(
            color: Color(
              0xFF31236C,
            ),
            border: Border.symmetric(
              horizontal: BorderSide(
                color: AppColors.primaryLight,
                width: 1,
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHoles(),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(
                      0.25,
                    ),
                  ),
                ),
              ),
              _buildHoles(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHoles() {
    return SizedBox(
      height: 11,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          16,
          (index) {
            return Container(
              width: 14,
              height: 7,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(
                  2,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
