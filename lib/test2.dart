import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

final Gradient gradient = new LinearGradient(
  colors: <Color>[
    Colors.greenAccent.withOpacity(1.0),
    Colors.yellowAccent.withOpacity(1.0),
    Colors.redAccent.withOpacity(1.0),
  ],
  stops: [
    0.0,
    0.5,
    1.0,
  ],
);

class Circular_arc extends StatefulWidget {
  const Circular_arc({
    Key? key,
  }) : super(key: key);

  @override
  _Circular_arcState createState() => _Circular_arcState();
}

class _Circular_arcState extends State<Circular_arc> with SingleTickerProviderStateMixin {


  late Animation<double> animation;
  late AnimationController animController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    animController = AnimationController(duration:Duration(seconds: 3),vsync: this);

    final curvedAnimation  = CurvedAnimation(parent: animController,curve: Curves.easeInOutCubic);

    animation = Tween<double>(begin: 0.0,end: 3.14).animate(curvedAnimation)..addListener(() {
      setState(() {

      });
    });
    animController.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          CustomPaint(
            size: Size(300,300),
            painter: ProgressArc(null, Colors.black54, true),
          ),
          CustomPaint(
            size: Size(300,300),
            painter: ProgressArc(animation.value, Colors.redAccent, false),
          ),
          Positioned(
              top:120,
              left:130,
              child:Text("${(animation.value/3.14 * 100).round()}%",style:TextStyle(color:Colors.red,fontSize:30))
          )
        ],

      ),
    );
  }
}

class ProgressArc extends CustomPainter{

  bool isBackground;
  double? arc;
  Color progressColor;

  ProgressArc(this.arc,this.progressColor,this.isBackground);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTRB(0,0, 300, 300);
    final startAngle = -pi;
    final sweepAngle = arc != null ? arc : pi;
    final userCenter  = false;
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;

    if(!isBackground){
      paint.shader = gradient.createShader(rect);
    }
    final p1 = Offset(0, 10);
    final p2 = Offset(250, 10);

    canvas.drawLine(p1,p2,paint);
    canvas.drawArc(rect, startAngle, sweepAngle??0, userCenter, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}