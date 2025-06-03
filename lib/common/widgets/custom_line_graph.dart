import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:journaling/core/utils/mood_enum.dart';

typedef GraphData = (DateTime, MoodEnum);

class CustomLineGraph extends StatefulWidget {
  final List<GraphData> data;
  final Color lineColor;
  final Color pointColor;
  final String Function(MoodEnum value)? formatYLabel;
  final String Function(GraphData)? formatPointLabel;
  final String Function(GraphData)? formatTooltipLabel;
  final String Function(DateTime time)? formatXLabel;

  const CustomLineGraph({
    super.key,
    required this.data,
    this.lineColor = Colors.blue,
    this.pointColor = Colors.red,
    this.formatYLabel,
    this.formatPointLabel,
    this.formatTooltipLabel,
    this.formatXLabel,
  });

  @override
  State<CustomLineGraph> createState() => _CustomLineGraphState();
}

class _CustomLineGraphState extends State<CustomLineGraph> {
  Offset? tappedPosition;
  int? tappedIndex;
  List<Offset> points = [];

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapUp: (details) {
          if (points.isEmpty) return;

          final tapPos = details.localPosition;

          // Find closest point within a threshold (e.g. 20 pixels)
          const threshold = 20.0;
          double minDistance = double.infinity;
          int? closestIndex;

          for (int i = 0; i < points.length; i++) {
            final dist = (points[i] - tapPos).distance;
            if (dist < minDistance && dist < threshold) {
              minDistance = dist;
              closestIndex = i;
            }
          }

          setState(() {
            tappedPosition = closestIndex != null ? points[closestIndex] : null;
            tappedIndex = closestIndex;
          });
        },
        child: Stack(
          children: [
            CustomPaint(
              painter: _LineGraphPainter(
                widget.data,
                widget.lineColor,
                widget.pointColor,
                widget.formatYLabel,
                widget.formatXLabel,
                widget.formatPointLabel,
                (pts) => points = pts,
              ),
              size: Size.infinite,
            ),
            if (tappedPosition != null &&
                tappedIndex != null &&
                tappedIndex! < widget.data.length)
              Positioned(
                left: tappedPosition!.dx + 10,
                top: tappedPosition!.dy - 30,
                child: _TooltipBubble(
                  text:
                      widget.formatTooltipLabel?.call((
                        widget.data[tappedIndex!].$1,
                        widget.data[tappedIndex!].$2,
                      )) ??
                      '${widget.data[tappedIndex!].$2}',
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TooltipBubble extends StatelessWidget {
  final String text;
  const _TooltipBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(6),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          text,
          style: const TextStyle(fontSize: 12, color: Colors.black),
        ),
      ),
    );
  }
}

class _LineGraphPainter extends CustomPainter {
  final List<GraphData> data;
  final Color lineColor;
  final Color pointColor;
  final String Function(MoodEnum value)? formatYLabel;
  final String Function(DateTime time)? formatXLabel;
  final String Function(GraphData value)? formatPointLabel;
  final void Function(List<Offset>)? onPointsCalculated;

  _LineGraphPainter(
    this.data,
    this.lineColor,
    this.pointColor,
    this.formatYLabel,
    this.formatXLabel,
    this.formatPointLabel,
    this.onPointsCalculated,
  );

  final List<MoodEnum> ratingScale = [
    MoodEnum.sad,
    MoodEnum.meh,
    MoodEnum.okay,
    MoodEnum.nice,
    MoodEnum.great,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || size.isEmpty) return;

    const leftPadding = 16.0;
    const rightPadding = 60.0;
    const topPadding = 24.0;
    const bottomPadding = 10.0;

    final sortedData = [...data]..sort((a, b) => a.$1.compareTo(b.$1));
    final times = sortedData.map((e) => e.$1).toList();
    // final values = sortedData.map((e) => e.$2).toList();

    // Handle edge cases for Y values
    final minY = 0.0;
    final maxY = 5;
    // values.isNotEmpty
    //     ? values.reduce((a, b) => a > b ? a : b).toDouble()
    //     : 1.0;
    final yRange = (maxY - minY) == 0 ? 1.0 : (maxY - minY);

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    // Handle edge cases for X values
    final minX =
        times.isNotEmpty ? times.first.millisecondsSinceEpoch.toDouble() : 0;
    final maxX =
        times.isNotEmpty ? times.last.millisecondsSinceEpoch.toDouble() : 1;
    final xRange = (maxX - minX) == 0 ? 1.0 : (maxX - minX);

    List<Offset> points = [];

    for (int i = 0; i < sortedData.length; i++) {
      final xPos =
          ((sortedData[i].$1.millisecondsSinceEpoch - minX) / xRange) *
              chartWidth +
          leftPadding;
      final yPos =
          chartHeight -
          ((sortedData[i].$2.value - minY) / yRange) * chartHeight +
          bottomPadding;

      if (xPos.isFinite && yPos.isFinite) {
        points.add(Offset(xPos, yPos));
      }
    }

    onPointsCalculated?.call(points);

    if (points.isEmpty) return;

    // Draw grid lines
    final gridPaint =
        Paint()
          ..color = Colors.grey.shade300
          ..strokeWidth = 1;

    const gridLines = 5;
    for (int i = 0; i < gridLines; i++) {
      final y = bottomPadding + i * (chartHeight / gridLines);
      if (y.isFinite) {
        canvas.drawLine(
          Offset(leftPadding, y),
          Offset(size.width - rightPadding, y),
          gridPaint,
        );
      }
    }

    // Draw Y axis labels
    final textStyle = const TextStyle(fontSize: 12, color: Colors.black);
    for (final rating in ratingScale) {
      final yValue = rating.value.toDouble();
      final y =
          chartHeight -
          ((yValue - minY) / yRange * chartHeight) +
          bottomPadding;

      final textSpan = TextSpan(text: rating.label, style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.right,
        textDirection: ui.TextDirection.rtl,
      )..layout(minWidth: 0, maxWidth: 50);

      final textOffset = Offset(
        size.width - rightPadding + (rightPadding - textPainter.width) / 2,
        y - textPainter.height / 2,
      );

      if (textOffset.dx.isFinite && textOffset.dy.isFinite) {
        textPainter.paint(canvas, textOffset);
      }
    }

    // Draw X axis labels
    final xLabelCount = 4;
    for (int i = 0; i <= xLabelCount; i++) {
      final t = minX + (i / xLabelCount) * (maxX - minX);
      final date = DateTime.fromMillisecondsSinceEpoch(t.toInt());
      final label = formatXLabel?.call(date) ?? DateFormat.Hm().format(date);

      final dx = ((t - minX) / xRange) * chartWidth + leftPadding;

      final textSpan = TextSpan(text: label, style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: ui.TextDirection.ltr,
      )..layout();

      final textOffset = Offset(
        dx - textPainter.width / 2,
        chartHeight + bottomPadding,
      );

      if (textOffset.dx.isFinite && textOffset.dy.isFinite) {
        textPainter.paint(canvas, textOffset);
      }
    }

    // Draw smoothed line
    if (points.length >= 2) {
      final path = Path()..moveTo(points[0].dx, points[0].dy);

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

      final paint =
          Paint()
            ..color = lineColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2;
      canvas.drawPath(path, paint);
    }

    // Draw points and labels
    final pointTextStyle = const TextStyle(fontSize: 12, color: Colors.black);
    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      final (time, value) = sortedData[i];

      // Draw point
      final pointPaint = Paint()..color = pointColor;
      canvas.drawCircle(point, 4, pointPaint);

      // Draw point label
      final label = formatPointLabel?.call(sortedData[i]) ?? value.toString();
      final textSpan = TextSpan(text: label, style: pointTextStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: ui.TextDirection.ltr,
      )..layout();

      final textOffset = Offset(
        point.dx - textPainter.width / 2,
        point.dy - 20,
      );
      if (textOffset.dx.isFinite && textOffset.dy.isFinite) {
        textPainter.paint(canvas, textOffset);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LineGraphPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.pointColor != pointColor;
  }
}
