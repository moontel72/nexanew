import 'package:flutter/material.dart';

/// Loading indicator widget with different styles and configurations
class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;
  final LoadingIndicatorStyle style;
  final String? text;
  final bool showBackground;
  final Color? backgroundColor;

  const LoadingIndicator({
    super.key,
    this.size = 40,
    this.color,
    this.strokeWidth = 3.0,
    this.style = LoadingIndicatorStyle.circular,
    this.text,
    this.showBackground = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indicatorColor = color ?? theme.primaryColor;

    Widget indicator;
    switch (style) {
      case LoadingIndicatorStyle.circular:
        indicator = SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
            strokeWidth: strokeWidth,
          ),
        );
        break;
      case LoadingIndicatorStyle.linear:
        indicator = LinearProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
          backgroundColor: backgroundColor ?? indicatorColor.withValues(alpha: 0.2),
          minHeight: strokeWidth,
        );
        break;
      case LoadingIndicatorStyle.dots:
        indicator = _DotsLoadingIndicator(
          size: size,
          color: indicatorColor,
          dotCount: 3,
        );
        break;
      case LoadingIndicatorStyle.pulse:
        indicator = _PulseLoadingIndicator(
          size: size,
          color: indicatorColor,
        );
        break;
    }

    if (showBackground) {
      indicator = Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor ?? theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: indicator,
      );
    }

    if (text != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          indicator,
          const SizedBox(height: 16),
          Text(
            text!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return Center(child: indicator);
  }
}

/// Different styles of loading indicators
enum LoadingIndicatorStyle {
  circular,
  linear,
  dots,
  pulse,
}

/// Dots loading indicator animation
class _DotsLoadingIndicator extends StatefulWidget {
  final double size;
  final Color color;
  final int dotCount;

  const _DotsLoadingIndicator({
    required this.size,
    required this.color,
    this.dotCount = 3,
  });

  @override
  State<_DotsLoadingIndicator> createState() => _DotsLoadingIndicatorState();
}

class _DotsLoadingIndicatorState extends State<_DotsLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.dotCount, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final animationValue = _controller.value;
                final dotAnimation = (animationValue * 2 - index * 0.5) % 1.0;
                final scale = 0.5 + dotAnimation * 0.5;
                final opacity = 0.3 + dotAnimation * 0.7;

                return Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: opacity,
                    child: Container(
                      width: widget.size / (widget.dotCount * 2),
                      height: widget.size / (widget.dotCount * 2),
                      decoration: BoxDecoration(
                        color: widget.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}

/// Pulse loading indicator animation
class _PulseLoadingIndicator extends StatefulWidget {
  final double size;
  final Color color;

  const _PulseLoadingIndicator({
    required this.size,
    required this.color,
  });

  @override
  State<_PulseLoadingIndicator> createState() => _PulseLoadingIndicatorState();
}

class _PulseLoadingIndicatorState extends State<_PulseLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final animationValue = _controller.value;
          final scale = 0.7 + 0.3 * (1 + (animationValue * 2 - 1).abs()) / 2;
          final opacity = 0.5 + 0.5 * (1 - (animationValue * 2 - 1).abs());

          return Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: Container(
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Full screen loading overlay
class LoadingOverlay extends StatelessWidget {
  final String? message;
  final bool dismissible;
  final Color? backgroundColor;
  final LoadingIndicatorStyle style;

  const LoadingOverlay({
    super.key,
    this.message,
    this.dismissible = false,
    this.backgroundColor,
    this.style = LoadingIndicatorStyle.circular,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: dismissible,
      child: Container(
        color: backgroundColor ?? Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LoadingIndicator(
                size: 50,
                style: style,
                showBackground: true,
                backgroundColor: theme.cardColor,
              ),
              if (message != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    message!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Shimmer loading effect for list items
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool enabled;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.enabled = true,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                Colors.grey[300]!,
                Colors.grey[100]!,
                Colors.grey[300]!,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(-1.0 + _controller.value * 2, 0.0),
              end: Alignment(1.0 + _controller.value * 2, 0.0),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}
