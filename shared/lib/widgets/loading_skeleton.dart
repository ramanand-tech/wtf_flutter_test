import 'package:flutter/material.dart';

import '../utils/spacing.dart';
import '../utils/theme.dart';

class _ShimmerBlock extends StatefulWidget {
  const _ShimmerBlock({required this.width, required this.height, this.radius = 8});

  final double? width;
  final double height;
  final double radius;

  @override
  State<_ShimmerBlock> createState() => _ShimmerBlockState();
}

class _ShimmerBlockState extends State<_ShimmerBlock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            color: Color.lerp(
              AppColors.neutral100,
              AppColors.neutral200,
              _controller.value,
            ),
          ),
        );
      },
    );
  }
}

class ListTileSkeleton extends StatelessWidget {
  const ListTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          const _ShimmerBlock(width: 48, height: 48, radius: 24),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _ShimmerBlock(width: 140, height: 14),
                SizedBox(height: AppSpacing.xs),
                _ShimmerBlock(width: 220, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatListSkeleton extends StatelessWidget {
  const ChatListSkeleton({super.key, this.count = 4});

  final int count;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: count,
      itemBuilder: (context, index) => const ListTileSkeleton(),
    );
  }
}

class CardListSkeleton extends StatelessWidget {
  const CardListSkeleton({super.key, this.count = 3});

  final int count;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.sm),
      itemCount: count,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) => Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _ShimmerBlock(width: 120, height: 16),
              SizedBox(height: AppSpacing.sm),
              _ShimmerBlock(width: double.infinity, height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
