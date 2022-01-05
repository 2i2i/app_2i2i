

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ProgressBar extends StatelessWidget {
  final double? height;
  final double? lineWidth;
  const ProgressBar({Key? key, this.height, this.lineWidth}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: 45,
      child: MyAnimatedLoading(
        offsetSpeed: Offset(1, 0),
        width: height??MediaQuery.of(context).size.width/4,
        height: lineWidth??20,
        colors: [
          Color(0xFFEF6654),
          /*Color(0xFFd6db86),
          Color(0xFF507942),
          Color(0xFF2c5689),
          Color(0xFF8ba5bc),
          Color(0xFF70706c),
          Color(0xFF642254),
          Color(0xFF3a3838),*/
        ],
      ),
    );
  }
}


class MyAnimatedLoading extends StatefulWidget {
  final Offset offsetSpeed;
  final List<Color> colors;
  final double width;
  final double height;

  const MyAnimatedLoading(
      {Key? key,
        required this.offsetSpeed,
        required this.colors,
        required this.width,
        required this.height})
      : super(key: key);

  @override
  State<MyAnimatedLoading> createState() => _MyAnimatedLoadingState();
}

class _MyAnimatedLoadingState extends State<MyAnimatedLoading> {
  late List<Node> nodes;
  late double width;

  @override
  void initState() {
    super.initState();
    width = widget.width / (widget.colors.length);

    nodes = List.generate(widget.colors.length, (index) {
      return Node(
        rect: Rect.fromCenter(
            center: Offset(index * width + width / 2, widget.height / 2),
            width: width,
            height: widget.height,
        ),
        color: widget.colors.elementAt(index),
      );
    });

    List<Node> tempNodes = <Node>[];
    for (int i = -widget.colors.length; i <= -1; i++) {
      tempNodes.add(Node(
        rect: Rect.fromCenter(
            center: Offset(i * width + width / 2, widget.height / 2),
            width: width,
            height: widget.height),
        color: widget.colors.first,
      ));
    }

    for (int i = 0; i < tempNodes.length; i++) {
      tempNodes[i].color = widget.colors[i];
    }

    nodes.addAll(tempNodes);

    Timer.periodic(const Duration(milliseconds: 20), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _calculateNewPositions();
    return ClipRRect(
      clipBehavior: Clip.hardEdge,
      borderRadius: const BorderRadius.all(Radius.circular(25)),
      child: CustomPaint(
        size: Size(widget.width, widget.height),
        painter: MyCustomPaint(nodes: nodes),
      ),
    );
  }

  void _calculateNewPositions() {
    for (final node in nodes) {
      final offset = node.rect.center;

      if (offset.dx - width / 2 >= widget.width) {
        node.rect = Rect.fromCenter(
            center: Offset(
                (-width / 2) * (widget.colors.length * 2) + width / 2,
                widget.height / 2) +
                widget.offsetSpeed,
            width: width,
            height: widget.height);
      } else {
        node.rect = Rect.fromCenter(
            center: offset + widget.offsetSpeed,
            width: width,
            height: widget.height);
      }
    }
  }
}

class Node {
  Rect rect;
  Color color;

  Node({required this.rect, required this.color});

  @override
  String toString() {
    return 'Node{rect: $rect, color: $color}\n';
  }
}

class MyCustomPaint extends CustomPainter {
  List<Node> nodes;

  MyCustomPaint({required this.nodes});
  final Gradient gradient = LinearGradient(
    colors: <Color>[
      Color(0xFF3a3838),
      Color(0xFFEF6654),
      Color(0xFFd6db86),
      Color(0xFF507942),
      Color(0xFF2c5689),
      Color(0xFF8ba5bc),
      Color(0xFF70706c),
      Color(0xFF642254),
      Color(0xFF3a3838),
    ],
    stops: [
      0.1,
      0.2,
      0.4,
      0.5,
      0.6,
      0.7,
      0.8,
      0.9,
      // 0.9,
      1.0,
    ],
  );
  @override
  void paint(Canvas canvas, Size size) {

    for (int i = 0; i < nodes.length; i++) {
      final Paint paint =  Paint();
      paint..shader = gradient.createShader(nodes[i].rect);
      paint..color = nodes[i].color;
      canvas.drawRect(nodes[i].rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}


