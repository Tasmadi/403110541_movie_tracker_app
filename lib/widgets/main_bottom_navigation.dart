import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class MainBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onSelected;

  const MainBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          12,
          0,
          12,
          10,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(
            24,
          ),
          border: Border.all(
            color: AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                0.30,
              ),
              blurRadius: 28,
              offset: const Offset(
                0,
                10,
              ),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _NavigationItem(
                icon: Icons.home_rounded,
                label: 'خانه',
                index: 0,
                currentIndex: currentIndex,
                onTap: onSelected,
              ),
            ),
            Expanded(
              child: _NavigationItem(
                icon: Icons.search_rounded,
                label: 'جست‌وجو',
                index: 1,
                currentIndex: currentIndex,
                onTap: onSelected,
              ),
            ),
            Expanded(
              child: _NavigationItem(
                icon: Icons.bookmarks_rounded,
                label: 'تماشا',
                index: 2,
                currentIndex: currentIndex,
                onTap: onSelected,
              ),
            ),
            Expanded(
              child: _NavigationItem(
                icon: Icons.playlist_play_rounded,
                label: 'لیست‌ها',
                index: 3,
                currentIndex: currentIndex,
                onTap: onSelected,
              ),
            ),
            Expanded(
              child: _NavigationItem(
                icon: Icons.person_rounded,
                label: 'پروفایل',
                index: 4,
                currentIndex: currentIndex,
                onTap: onSelected,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _NavigationItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    bool selected = index == currentIndex;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onTap(index);
        },
        borderRadius: BorderRadius.circular(
          18,
        ),
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 220,
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 2,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withOpacity(
                    0.14,
                  )
                : Colors.transparent,
            borderRadius: BorderRadius.circular(
              18,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 23,
                color: selected ? AppColors.primaryLight : AppColors.textMuted,
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  color: selected ? AppColors.textPrimary : AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
