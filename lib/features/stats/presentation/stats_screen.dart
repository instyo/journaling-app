import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:journaling/features/stats/cubit/stats_cubit.dart';
import '../../../common/constants.dart'; // For Mood enum

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();
    // Load stats when the screen initializes
    context.read<StatsCubit>().loadMoodStats();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand();
    // return Scaffold(
    //   appBar: AppBar(title: const Text('Mood Statistics')),
    //   body: BlocBuilder<StatsCubit, StatsState>(
    //     builder: (context, state) {
    //       if (state is StatsLoading) {
    //         return const Center(child: CircularProgressIndicator());
    //       } else if (state is StatsError) {
    //         return Center(child: Text('Error: ${state.message}'));
    //       } else if (state is StatsLoaded) {
    //         if (state.moodCounts.isEmpty ||
    //             state.moodCounts.values.every((element) => element == 0)) {
    //           return const Center(
    //             child: Text('No journal entries found yet to show stats.'),
    //           );
    //         }

    //         final Map<Mood, int> counts = state.moodCounts;
    //         final double totalEntries = counts.values.fold(
    //           0,
    //           (sum, count) => sum + count,
    //         );

    //         // Prepare data for BarChart
    //         final List<BarChartGroupData> barGroups = [];
    //         int index = 0;
    //         for (var mood in Mood.values) {
    //           final count = counts[mood] ?? 0;
    //           barGroups.add(
    //             BarChartGroupData(
    //               x: index,
    //               barRods: [
    //                 BarChartRodData(
    //                   toY: count.toDouble(),
    //                   color: _getMoodColor(
    //                     mood,
    //                   ), // Helper to get a color for each mood
    //                   width: 16,
    //                   borderRadius: BorderRadius.circular(4),
    //                 ),
    //               ],
    //             ),
    //           );
    //           index++;
    //         }

    //         return SingleChildScrollView(
    //           padding: const EdgeInsets.all(16.0),
    //           child: Column(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: [
    //               Text(
    //                 'Mood Distribution (Total: ${totalEntries.toInt()} entries)',
    //                 style: Theme.of(context).textTheme.headlineSmall,
    //               ),
    //               const SizedBox(height: 24),
    //               SizedBox(
    //                 height: 250,
    //                 child: BarChart(
    //                   BarChartData(
    //                     barGroups: barGroups,
    //                     titlesData: FlTitlesData(
    //                       show: true,
    //                       rightTitles: const AxisTitles(
    //                         sideTitles: SideTitles(showTitles: false),
    //                       ),
    //                       topTitles: const AxisTitles(
    //                         sideTitles: SideTitles(showTitles: false),
    //                       ),
    //                       bottomTitles: AxisTitles(
    //                         sideTitles: SideTitles(
    //                           showTitles: true,
    //                           getTitlesWidget: (value, meta) {
    //                             // Display mood emoji on x-axis
    //                             return Padding(
    //                               padding: const EdgeInsets.only(top: 8.0),
    //                               child: Text(Mood.values[value.toInt()].emoji),
    //                             );
    //                           },
    //                           reservedSize: 30,
    //                         ),
    //                       ),
    //                       leftTitles: AxisTitles(
    //                         sideTitles: SideTitles(
    //                           showTitles: true,
    //                           getTitlesWidget: (value, meta) {
    //                             if (value % 1 == 0) {
    //                               // Only show integers
    //                               return Text(value.toInt().toString());
    //                             }
    //                             return const Text('');
    //                           },
    //                           reservedSize: 40,
    //                         ),
    //                       ),
    //                     ),
    //                     gridData: const FlGridData(show: false),
    //                     borderData: FlBorderData(
    //                       show: true,
    //                       border: Border.all(
    //                         color: const Color(0xff37434d),
    //                         width: 1,
    //                       ),
    //                     ),
    //                     barTouchData: BarTouchData(
    //                       touchTooltipData: BarTouchTooltipData(
    //                         // tooltipBgColor: Colors.blueGrey,
    //                         getTooltipItem: (group, groupIndex, rod, rodIndex) {
    //                           final mood = Mood.values[group.x.toInt()];
    //                           return BarTooltipItem(
    //                             // '${mood.emoji} ${mood.name.capitalize()}\n',
    //                             '',
    //                             const TextStyle(
    //                               color: Colors.white,
    //                               fontWeight: FontWeight.bold,
    //                             ),
    //                             children: [
    //                               TextSpan(
    //                                 text: '${rod.toY.toInt()} entries',
    //                                 style: const TextStyle(
    //                                   color: Colors.white,
    //                                   fontSize: 14,
    //                                   fontWeight: FontWeight.w500,
    //                                 ),
    //                               ),
    //                             ],
    //                           );
    //                         },
    //                       ),
    //                     ),
    //                   ),
    //                 ),
    //               ),
    //               const SizedBox(height: 32),
    //               // Optional: Mood labels with percentages
    //               Text(
    //                 'Mood Breakdown:',
    //                 style: Theme.of(context).textTheme.titleMedium,
    //               ),
    //               const SizedBox(height: 8),
    //               ...Mood.values.map((mood) {
    //                 final count = counts[mood] ?? 0;
    //                 final percentage =
    //                     totalEntries > 0 ? (count / totalEntries * 100) : 0;
    //                 return Padding(
    //                   padding: const EdgeInsets.symmetric(vertical: 4.0),
    //                   child: Row(
    //                     children: [
    //                       Icon(
    //                         Icons.circle,
    //                         size: 16,
    //                         color: _getMoodColor(mood),
    //                       ),
    //                       const SizedBox(width: 8),
    //                       Text(
    //                         // '${mood.emoji} ${mood.name.capitalize()}: $count entries (${percentage.toStringAsFixed(1)}%)',
    //                         '',
    //                         style: Theme.of(context).textTheme.bodyLarge,
    //                       ),
    //                     ],
    //                   ),
    //                 );
    //               }).toList(),
    //             ],
    //           ),
    //         );
    //       }
    //       return const SizedBox.shrink();
    //     },
    //   ),
    // );
  }

  // Helper function to get a color for each mood
  Color _getMoodColor(Mood mood) {
    return Colors.pink;
    // switch (mood) {
    //   case Mood.optimistic:
    //     return Colors.green;
    //   case Mood.melancholic:
    //     return Colors.blueGrey;
    //   case Mood.irritable:
    //     return Colors.red;
    //   case Mood.serene:
    //     return Colors.blue;
    //   case Mood.anxious:
    //     return Colors.orange;
    //   default:
    //     return Colors.grey;
    // }
  }
}
