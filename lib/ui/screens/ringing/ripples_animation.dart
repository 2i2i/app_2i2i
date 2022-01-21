import 'dart:math' as math show sin, pi, sqrt;

import 'package:flutter/material.dart';

class Ripples extends StatefulWidget {
  const Ripples({
    Key? key,
    this.size = 80.0,
    this.color = Colors.pink,
    this.onPressed,
    required this.child,
  }) : super(key: key);

  final double size;
  final Color color;
  final Widget? child;
  final VoidCallback? onPressed;

  @override
  _RipplesState createState() => _RipplesState();
}

class _CirclePainter extends CustomPainter {
  _CirclePainter(
      this._animation, {
        required this.color,
      }) : super(repaint: _animation);

  final Color color;
  final Animation<double> _animation;

  void circle(Canvas canvas, Rect rect, double value) {
    final double opacity = (1.0 - (value / 2.0)).clamp(0.0, 3);
    final Color _color = color.withOpacity(opacity*0.3);

    final double size = rect.height / 1.5;
    final double area = size * size;
    final double radius = math.sqrt(area * value / 2);

    final Paint paint = Paint()..color = _color;
    canvas.drawCircle(rect.center, radius, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTRB(0.0, 0.0, size.width, size.height);

    for (int wave = 3; wave >= 0; wave--) {
      circle(canvas, rect, wave + _animation.value);
    }
  }

  @override
  bool shouldRepaint(_CirclePainter oldDelegate) => true;
}

class _RipplesState extends State<Ripples> with TickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  Widget _button() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.size),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: <Color>[
                widget.color,
                Color.lerp(widget.color, Colors.black, 0.04)!
              ],
            ),
          ),
          child: ScaleTransition(
            scale: Tween(begin: 0.9, end: 0.9).animate(
              CurvedAnimation(
                parent: _controller!,
                curve: const _PulsateCurve(),
              ),
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CirclePainter(
        _controller!,
        color: widget.color,
      ),
      child: SizedBox(
        width: widget.size * 2.125,
        height: widget.size * 2.125,
        child: _button(),
      ),
    );
  }
}

class _PulsateCurve extends Curve {
  const _PulsateCurve();

  @override
  double transform(double t) {
    if (t == 0 || t == 1) {
      return 0.2;
    }
    return math.sin(t * math.pi);
  }
}
