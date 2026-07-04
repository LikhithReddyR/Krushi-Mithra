import 'package:flutter/material.dart';

/// A farming-themed loading indicator that cycles through farm icons.
/// Use [FarmLoader] as a drop-in replacement for CircularProgressIndicator.
/// Use [FarmLoader.small] inside buttons (white, compact).
class FarmLoader extends StatefulWidget {
  final double size;
  final Color? color;

  const FarmLoader({super.key, this.size = 60, this.color});

  /// Small version for use inside buttons (white, 20px)
  const FarmLoader.small({super.key})
      : size = 20,
        color = Colors.white;

  @override
  State<FarmLoader> createState() => _FarmLoaderState();
}

class _FarmLoaderState extends State<FarmLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotation;
  late final Animation<double> _bounce;

  static const _icons = ['🌾', '🚜', '🌱', '🌿', '🍃'];
  int _iconIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() => _iconIndex = (_iconIndex + 1) % _icons.length);
          _controller.forward(from: 0);
        }
      })
      ..forward();

    _rotation = Tween<double>(begin: -0.08, end: 0.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _bounce = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // For small (button) version, just show a tiny rotating leaf
    if (widget.size <= 22) {
      return AnimatedBuilder(
        animation: _controller,
        builder: (_, __) => Transform.rotate(
          angle: _rotation.value,
          child: Text('🌱', style: TextStyle(fontSize: widget.size * 0.9)),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.translate(
              offset: Offset(0, _bounce.value),
              child: Transform.rotate(
                angle: _rotation.value,
                child: Text(
                  _icons[_iconIndex],
                  style: TextStyle(fontSize: widget.size * 0.7),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _DotRow(color: widget.color ?? Theme.of(context).primaryColor),
          ],
        );
      },
    );
  }
}

/// Three pulsing dots underneath the icon
class _DotRow extends StatefulWidget {
  final Color color;
  const _DotRow({required this.color});
  @override
  State<_DotRow> createState() => _DotRowState();
}

class _DotRowState extends State<_DotRow> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i / 3;
            final val = ((_ctrl.value - delay) % 1.0).clamp(0.0, 1.0);
            final opacity = (0.3 + 0.7 * (val < 0.5 ? val * 2 : (1 - val) * 2)).clamp(0.3, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: widget.color.withOpacity(opacity),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}
