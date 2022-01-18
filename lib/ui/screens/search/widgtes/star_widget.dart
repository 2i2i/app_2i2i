import 'dart:math' as math;

import 'package:flutter/material.dart';

class StarWidget extends ProgressIndicator {
  final double width;
  final double height;
  final Color startColor;

  StarWidget( {
    Key? key,
    this.startColor = Colors.yellow,
    required this.width,
    required this.height,
    double value = 0.5,
  }) : super(
          key: key,
          value: value,
        );

  @override
  State<StatefulWidget> createState() => _StarWidgetState();
}

class _StarWidgetState extends State<StarWidget> {
  @override
  Widget build(BuildContext context) {
    Size iconSize = Size(widget.width, widget.height);
    final pathBounds = shapePath(iconSize).getBounds();
    return SizedBox(
      width: pathBounds.width + pathBounds.left,
      height: pathBounds.height + pathBounds.top + 5,
      child: ClipPath(
        clipper: _CustomPathClipper(
          path: shapePath(iconSize),
        ),
        child: CustomPaint(
          painter: _CustomPathPainter(
            path: shapePath(iconSize),
            color: Theme.of(context).colorScheme.secondary,
          ),
          child: ClipPath(
            child: Container(color: Theme.of(context).colorScheme.secondary),
            clipper: _WaveClipper(
              value: widget.value,
            ),
          ),
        ),
      ),
    );
  }

  Path shapePath(Size size) {
    final path = Path();
    path.lineTo(size.width * 0.5, size.height * 0.15);
    path.lineTo(size.width * 0.35, size.height * 0.4);
    path.lineTo(0.0, size.height * 0.4);
    path.lineTo(size.width * 0.25, size.height * 0.55);
    path.lineTo(size.width * 0.1, size.height * 0.8);
    path.lineTo(size.width * 0.5, size.height * 0.65);
    path.lineTo(size.width * 0.9, size.height * 0.8);
    path.lineTo(size.width * 0.75, size.height * 0.55);
    path.lineTo(size.width, size.height * 0.4);
    path.lineTo(size.width * 0.65, size.height * 0.4);
    path.lineTo(size.width * 0.5, size.height * 0.15);

    path.close();
    return path;
  }
}

class _CustomPathPainter extends CustomPainter {
  final Color color;
  final Path path;

  _CustomPathPainter({required this.color, required this.path});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CustomPathPainter oldDelegate) =>
      color != oldDelegate.color || path != oldDelegate.path;
}

class _CustomPathClipper extends CustomClipper<Path> {
  final Path path;

  _CustomPathClipper({required this.path});

  @override
  Path getClip(Size size) {
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _WaveClipper extends CustomClipper<Path> {
  final double? value;

  _WaveClipper({required this.value});

  @override
  Path getClip(Size size) {
    Path path = Path()
      ..addPolygon(_generateHorizontalWavePath(size), false)
      ..lineTo(0.0, size.height)
      ..lineTo(0.0, 0.0)
      ..close();
    return path;
  }

  List<Offset> _generateHorizontalWavePath(Size size) {
    final waveList = <Offset>[];
    for (int i = -2; i <= size.height.toInt() + 2; i++) {
      final waveHeight = (size.width / 20);
      final dx = math.sin((360 - i) % 360 * (math.pi / 180)) * waveHeight +
          (size.width * value!);
      waveList.add(Offset(dx, i.toDouble()));
    }
    return waveList;
  }

  @override
  bool shouldReclip(_WaveClipper oldClipper) => 0 != 0;
}
