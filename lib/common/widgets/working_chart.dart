import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

class CustomLineGraph extends StatelessWidget {
  final List<(DateTime, int)> data;
  final Color lineColor;
  final Color pointColor;
  final String Function(double value)? formatYLabel;
  final String Function(DateTime time, int value)? formatPointLabel;

  const CustomLineGraph({
    super.key,
    required this.data,
    this.lineColor = Colors.blue,
    this.pointColor = Colors.red,
    this.formatYLabel,
    this.formatPointLabel,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2,
      child: CustomPaint(
        painter: _LineGraphPainter(
          data,
          lineColor,
          pointColor,
          formatYLabel,
          formatPointLabel,
        ),
      ),
    );
  }
}

class _LineGraphPainter extends CustomPainter {
  final List<(DateTime, int)> data;
  final Color lineColor;
  final Color pointColor;
  final String Function(double value)? formatYLabel;
  final String Function(DateTime time, int value)? formatPointLabel;

  _LineGraphPainter(
    this.data,
    this.lineColor,
    this.pointColor,
    this.formatYLabel,
    this.formatPointLabel,
  );

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    const leftPadding = 16.0;
    const rightPadding = 60.0;
    const topPadding = 24.0;
    const bottomPadding = 10.0;

    final sortedData = [...data]..sort((a, b) => a.$1.compareTo(b.$1));
    final times = sortedData.map((e) => e.$1).toList();
    final values = sortedData.map((e) => e.$2).toList();

    final minY = 0.0;
    final maxY = values.reduce((a, b) => a > b ? a : b).toDouble();

    final padding = 16.0;
    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    final minX = times.first.millisecondsSinceEpoch.toDouble();
    final maxX = times.last.millisecondsSinceEpoch.toDouble();

    List<Offset> points = [];

    for (int i = 0; i < sortedData.length; i++) {
      final dx =
          ((sortedData[i].$1.millisecondsSinceEpoch - minX) / (maxX - minX)) *
              chartWidth +
          leftPadding;

      final dy =
          chartHeight -
          ((sortedData[i].$2 - minY) / (maxY - minY)) * chartHeight +
          padding / 2;
      points.add(Offset(dx, dy));
    }

    // Draw grid lines
    final gridPaint =
        Paint()
          ..color = Colors.grey.shade300
          ..strokeWidth = 1;
    const gridLines = 5;
    for (int i = 0; i < gridLines; i++) {
      final y = padding / 2 + i * (chartHeight / gridLines);
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - rightPadding, y),
        gridPaint,
      );
    }

    // Draw Y axis labels
    for (int i = 0; i <= gridLines; i++) {
      final yValue = maxY - (i * (maxY / gridLines));
      final y = padding / 2 + i * (chartHeight / gridLines);

      final label = formatYLabel?.call(yValue) ?? yValue.toStringAsFixed(0);
      final textSpan = TextSpan(
        text: label,
        style: TextStyle(fontSize: 12, color: Colors.black),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.right,
        textDirection: ui.TextDirection.rtl,
      )..layout(minWidth: 0, maxWidth: 50);
      textPainter.paint(
        canvas,
        Offset(
          size.width - rightPadding + (rightPadding - textPainter.width) / 2,
          y - textPainter.height / 2,
        ),
      );
    }

    // Draw X axis labels
    final xLabelCount = 4;
    for (int i = 0; i <= xLabelCount; i++) {
      final t = minX + (i / xLabelCount) * (maxX - minX);
      final date = DateTime.fromMillisecondsSinceEpoch(t.toInt());
      final label = DateFormat.Hm().format(date);
      final dx = ((t - minX) / (maxX - minX)) * chartWidth + padding;
      final textSpan = TextSpan(
        text: label,
        style: TextStyle(fontSize: 12, color: Colors.black),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: ui.TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(dx - textPainter.width / 2, size.height - 50),
      );
    }

    // Draw smoothed line
    final path = Path();
    if (points.length >= 2) {
      path.moveTo(points[0].dx, points[0].dy);
      for (int i = 0; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
        final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);
        path.cubicTo(
          controlPoint1.dx,
          controlPoint1.dy,
          controlPoint2.dx,
          controlPoint2.dy,
          p1.dx,
          p1.dy,
        );
      }
    }

    final paint =
        Paint()
          ..color = lineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
    canvas.drawPath(path, paint);

    // Draw points and labels
    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      final (time, value) = sortedData[i];

      final pointPaint = Paint()..color = pointColor;
      canvas.drawCircle(point, 4, pointPaint);

      final label = formatPointLabel?.call(time, value) ?? value.toString();
      final textSpan = TextSpan(
        text: label,
        style: TextStyle(fontSize: 12, color: Colors.black),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: ui.TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(point.dx - textPainter.width / 2, point.dy - 20),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LineGraphPainter oldDelegate) => true;
}
