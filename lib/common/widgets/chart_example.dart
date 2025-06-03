// class CalorieGraphScreen extends StatelessWidget {
//   const CalorieGraphScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // backgroundColor: Color(0xFF2C3E50),
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.all(20.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Mingguan',
//                         style: TextStyle(
//                           color: Colors.green,
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       SizedBox(height: 4),
//                       Text(
//                         'Grafik konsumsi kalori',
//                         style: TextStyle(color: Colors.green, fontSize: 14),
//                       ),
//                     ],
//                   ),
//                   Icon(Icons.play_arrow, color: Colors.green, size: 24),
//                 ],
//               ),
//               SizedBox(height: 40),
//               Expanded(child: CalorieBarChart()),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class CalorieBarChart extends StatelessWidget {
//   final List<double> data = [
//     0.3,
//     0.4,
//     0.25,
//     0.5,
//     0.65,
//     0.85,
//     0.45,
//   ]; // Normalized values (0-1)
//   final List<String> days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

//   @override
//   Widget build(BuildContext context) {
//     return CustomPaint(
//       painter: BarChartPainter(data: data, days: days),
//       child: Container(),
//     );
//   }
// }

// class BarChartPainter extends CustomPainter {
//   final List<double> data;
//   final List<String> days;

//   BarChartPainter({required this.data, required this.days});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()..style = PaintingStyle.fill;

//     final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);

//     final barWidth = 20.0;
//     final barSpacing =
//         (size.width - (data.length * barWidth)) / (data.length + 1);
//     final maxBarHeight = size.height - 60; // Leave space for labels

//     for (int i = 0; i < data.length; i++) {
//       final x = barSpacing + (i * (barWidth + barSpacing));

//       // Draw background bar (gray)
//       paint.color = Color(0xFF4A5568);
//       final backgroundRect = RRect.fromRectAndRadius(
//         Rect.fromLTWH(x, 20, barWidth, maxBarHeight - 20),
//         Radius.circular(10),
//       );
//       canvas.drawRRect(backgroundRect, paint);

//       // Draw foreground bar (white)
//       paint.color = Colors.white;
//       final barHeight = data[i] * (maxBarHeight - 40); // Scale the bar height
//       final foregroundRect = RRect.fromRectAndRadius(
//         Rect.fromLTWH(x, maxBarHeight - barHeight, barWidth, barHeight),
//         Radius.circular(10),
//       );
//       canvas.drawRRect(foregroundRect, paint);

//       // Draw day labels
//       textPainter.text = TextSpan(
//         text: days[i],
//         style: TextStyle(
//           color: Colors.white70,
//           fontSize: 14,
//           fontWeight: FontWeight.w500,
//         ),
//       );
//       textPainter.layout();

//       final labelX = x + (barWidth - textPainter.width) / 2;
//       final labelY = size.height - 30;
//       textPainter.paint(canvas, Offset(labelX, labelY));
//     }
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => false;
// }
