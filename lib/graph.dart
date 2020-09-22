import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'bloc.dart';

class GraphPainter extends CustomPainter {
  HeartRateBloc bloc;

  GraphPainter(this.bloc);

  static const TimeSpan = 15000;
  static const MaxHue = -0.04;
  static const MinHue = -0.08;

  @override
  void paint(Canvas canvas, Size size) {
    var now = DateTime.now().millisecondsSinceEpoch;
    var paint = Paint()
      ..isAntiAlias = true
      ..color = Colors.blue
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    final list = bloc.dataList;
    var path = Path();
    double lastHeartRate = null;
    for (var i = 1; i < list.length; i++) {
      final startTimeOffset =
          (list[i - 1].timestamp - now + TimeSpan) / TimeSpan;
      final endTimeOffset = (list[i].timestamp - now + TimeSpan) / TimeSpan;

      if (startTimeOffset <= TimeSpan && 0 <= endTimeOffset) {
        final startHeartRate =
            (list[i - 1].heartRate - MinHue) / (MaxHue - MinHue);
        final endHeartRate = (list[i].heartRate - MinHue) / (MaxHue - MinHue);
        debugPrint(startHeartRate.toString());
        path.moveTo(
            size.width * startTimeOffset, (size.height * startHeartRate));
        path.quadraticBezierTo(
            size.width * startTimeOffset,
            (size.height * startHeartRate),
            size.width * endTimeOffset,
            (size.height * endHeartRate));
        lastHeartRate = list[i].heartRate;
      }
    }
    path.close();
    canvas.drawPath(path, paint);

    TextSpan textSpan = new TextSpan(
        style: new TextStyle(color: Colors.blue),
        text: "HeartRate: " + (lastHeartRate != null ? lastHeartRate.toStringAsFixed(10) : "None"));
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );

// テキストの描画
    var offset = Offset(10, 10);
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class Graph extends StatefulWidget {
  HeartRateBloc block;

  Graph(this.block);

  @override
  State<StatefulWidget> createState() {
    return _GraphState();
  }
}

class _GraphState extends State<Graph> with SingleTickerProviderStateMixin {
  Animation<double> _animation;
  AnimationController _animationController;

  @override
  void initState() {
    _animationController =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    _animation = Tween(begin: 10.0, end: 100.0).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reset();
      } else if (status == AnimationStatus.dismissed) {
        _animationController.forward();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GraphPainter(this.widget.block),
    );
  }
}
