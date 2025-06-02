// import 'dart:ui';

// import 'package:collection/collection.dart';
// import 'package:flutter/material.dart';
// import 'dart:core';
// import 'package:flutter/widgets.dart';
// import 'package:journaling/common/widgets/line_chart.dart';

// class ChartController<T> extends ChangeNotifier {
//   List<T> _hovered = [];
//   T? _selected;

//   List<T> get hovered => _hovered;
//   set hovered(List<T> hovered) {
//     _hovered = hovered;
//     notifyListeners();
//   }

//   T? get selected => _selected;
//   set selected(T? selected) {
//     _selected = selected;
//     notifyListeners();
//   }

//   ChartController();
// }

// class ChartPoint {
//   final DateTime x;
//   final double y;

//   const ChartPoint({required this.x, required this.y});
// }

// class ChartSegment {
//   final int id;
//   final int value;
//   final Color color;
//   final String? label;

//   const ChartSegment(
//     this.id, {
//     required this.value,
//     required this.color,
//     this.label,
//   });
// }

// extension ColorExtension on Color {
//   Color lighten([int percent = 10]) {
//     double factor = percent / 100;

//     return Color.fromARGB(
//       alpha,
//       red + ((255 - red) * factor).round(),
//       green + ((255 - green) * factor).round(),
//       blue + ((255 - blue) * factor).round(),
//     );
//   }
// }

// class Dimensions {
//   static const double tappable = 48.0;
//   static const double regular = 16.0;
//   static const double line = 1.0;
//   static const double text = 14.0;
// }

// class Palette {
//   static const List<Color> colors = [
//     Color(0xff989898),
//     Color(0xffe04038),
//     Color(0xffe06638),
//     Color(0xfff0b020),
//     Color(0xffe8e850),
//     Color(0xff68c860),
//     Color(0xff48ac40),
//     Color(0xff40ac9e),
//     Color(0xff4888e8),
//     Color(0xff2838e0),
//     Color(0xff8050e8),
//     Color(0xffc060c8),
//   ];

//   static Color getUnusedColor(List<Color> usedColors) {
//     return colors.firstWhereOrNull((color) => !usedColors.contains(color)) ??
//         colors[0];
//   }
// }

// class MyChart extends StatefulWidget {
//   const MyChart({super.key});

//   @override
//   State<MyChart> createState() => _MyChartState();
// }

// class _MyChartState extends State<MyChart> {
//   static final List<ChartSegment> _chartSegments = [
//     ChartSegment(1, value: 1500, color: Palette.colors[1]),
//     ChartSegment(2, value: 700, color: Palette.colors[3]),
//     ChartSegment(3, value: 450, color: Palette.colors[5]),
//     ChartSegment(4, value: 225, color: Palette.colors[8]),
//     ChartSegment(5, value: 100, color: Palette.colors[10]),
//   ];

//   static final DateTime _date = DateTime(2023, 07, 20);

//   static final List<ChartPoint> _chartPoints = [
//     ChartPoint(x: _date, y: 500),
//     ChartPoint(x: _date.add(const Duration(days: 1)), y: 1500),
//     ChartPoint(x: _date.add(const Duration(days: 2)), y: 250),
//     ChartPoint(x: _date.add(const Duration(days: 3)), y: 750),
//     ChartPoint(x: _date.add(const Duration(days: 4)), y: 50),
//   ];

//   int _chartTypeIndex = 0;
//   ChartPoint? _hoveredChartPoint;
//   ChartPoint? _selectedChartPoint;
//   ChartSegment? _hoveredChartSegment;
//   ChartSegment? _selectedChartSegment;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Crot"),),
//       body: _createLineChart(),
//     );
//   }

//   Widget _createLineChart() {
//     return LineChart(
//       xAxisLabel: 'Date',
//       yAxisLabel: 'Sum',
//       points: _chartPoints,
//       onPointHover: _onChartPointHover,
//       onPointSelect: _onChartPointSelect,
//     );
//   }

//   void _onChartPointHover(List<ChartPoint> chartPoints) {
//     setState(() {
//       _hoveredChartPoint = chartPoints.firstOrNull;
//     });
//   }

//   void _onChartPointSelect(ChartPoint? chartPoint) {
//     setState(() {
//       _selectedChartPoint = chartPoint;
//     });
//   }
// }
