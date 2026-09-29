import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';
import 'app_card.dart';

class Shimmer extends StatefulWidget {
  const Shimmer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1200),
  });

  final Widget child;
  final Duration duration;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color baseColor = isDark
        ? const Color(0xFF1F2531)
        : const Color(0xFFE8EBF2);
    final Color highlightColor = isDark
        ? const Color(0xFF2C3445)
        : const Color(0xFFF6F7FB);

    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (Rect bounds) {
            final double value = _controller.value;
            return LinearGradient(
              begin: const Alignment(-1.5, -0.3),
              end: const Alignment(1.5, 0.3),
              colors: <Color>[
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: <double>[
                (value - 0.3).clamp(0.0, 1.0),
                value.clamp(0.0, 1.0),
                (value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 8,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color baseColor = isDark
        ? const Color(0xFF1F2531)
        : const Color(0xFFE8EBF2);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class SkeletonCircle extends StatelessWidget {
  const SkeletonCircle({
    super.key,
    this.radius = 20,
  });

  final double radius;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color baseColor = isDark
        ? const Color(0xFF1F2531)
        : const Color(0xFFE8EBF2);

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: baseColor,
        shape: BoxShape.circle,
      ),
    );
  }
}

class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: <Widget>[
          SkeletonCircle(radius: 22),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SkeletonBox(width: 140, height: 16),
                SizedBox(height: 6),
                SkeletonBox(
                  width: 90,
                  height: 12,
                  borderRadius: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SkeletonList extends StatelessWidget {
  const SkeletonList({
    super.key,
    this.itemCount = 7,
    this.padding = const EdgeInsets.all(AppSpacing.md),
  });

  final int itemCount;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: padding,
        itemCount: itemCount,
        separatorBuilder: (BuildContext context, int index) => const SizedBox(height: AppSpacing.xs),
        itemBuilder: (BuildContext context, int index) => const SkeletonListTile(),
      ),
    );
  }
}
