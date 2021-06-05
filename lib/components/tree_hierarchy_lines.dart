import 'dart:ui';

import 'package:flutter/material.dart';

class HorizontalLinePainter extends CustomPainter {
  HorizontalLinePainter({
    required this.width,
    required this.height,
    required this.padding,
    required this.nestFactor,
    required this.pos,
    required this.lastPos,
    required this.isParentLast,
    required this.color,
  });
  final double width;
  final double height;
  final double padding;
  final int nestFactor;
  final int pos;
  final int lastPos;
  final List<bool> isParentLast;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = color;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.5;

    var p1 = (padding * nestFactor) + padding / 3.5;

    /// here nodeHeight = iconHeight
    Path path = Path();
    path.moveTo(height / 2 + p1, height);
    path.lineTo(height / 2 + p1 + width, height);
    for (var i = 0; i <= nestFactor; i++) {
      if (i == nestFactor || !isParentLast[i]) {
        var p2 = (padding * i) + padding / 3.5;
        path.moveTo(height / 2 + p2, pos == 0 ? -height / 2.5 : 0);
        path.lineTo(height / 2 + p2,
            lastPos == pos && i == nestFactor ? height : height * 2);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(HorizontalLinePainter oldDelegate) {
    return width != oldDelegate.width ||
        height != oldDelegate.height ||
        nestFactor != oldDelegate.nestFactor ||
        pos != oldDelegate.pos ||
        lastPos != oldDelegate.lastPos ||
        isParentLast != oldDelegate.isParentLast ||
        color != oldDelegate.color ||
        padding != oldDelegate.padding;
  }
}
