import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:journaling/common/widgets/custom_line_graph.dart';
import 'package:journaling/common/widgets/custom_scaffold.dart';
import 'package:journaling/common/widgets/mood_card.dart';
import 'package:journaling/core/utils/context_extension.dart';
import 'package:journaling/core/utils/mood_enum.dart';
import 'package:journaling/features/stats/cubit/stats_cubit.dart';
import 'package:pie_chart/pie_chart.dart';

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
    context.read<StatsCubit>().getJournals();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<StatsCubit>();

    return CustomScaffold(
      title: "Statistics",
      actions: [
        IconButton(
          onPressed: () {
            cubit.createDummy(context.userId);
          },
          icon: Icon(Icons.dangerous),
        ),
      ],
      body: SizedBox.expand(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Last 7 days: ",
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  StreamBuilder<MoodEnum>(
                    initialData: MoodEnum.unknown,
                    stream: cubit.commonMood$,
                    builder: (context, snapshot) {
                      return MoodCard(
                        title: "Common Mood",
                        value: "${snapshot.data?.moodLabel}",
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  StreamBuilder<int>(
                    stream: cubit.totalJournal$,
                    initialData: 0,
                    builder: (context, snapshot) {
                      return MoodCard(
                        title: "Total Journals",
                        value: "${snapshot.data}",
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),

              const SizedBox(height: 8),
              Text(
                "Average Mood Levels: ",
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 32),
                child: StreamBuilder<List<GraphData>>(
                  stream: cubit.averageMoodsIn7Days$,
                  initialData: [],
                  builder: (context, snapshot) {
                    if (snapshot.data!.isEmpty) {
                      const Text("No moods recorded.");
                    }

                    return CustomLineGraph(
                      data: snapshot.data!,
                      lineColor: context.primaryColor,
                      pointColor: Theme.of(context).colorScheme.tertiaryContainer,
                      formatTooltipLabel: (data) {
                        return DateFormat('dd/MM/yyyy').format(data.$1);
                      },
                      formatPointLabel: (data) {
                        return data.$2.emoji;
                      },
                      formatYLabel: (data) {
                        return data.label;
                      },
                      formatXLabel: (time) {
                        return DateFormat('dd LLL').format(time);
                      },
                    );
                  },
                ),
              ),

              // SizedBox(height: 500, child: CalorieGraphScreen()),
              const SizedBox(height: 8),

              StreamBuilder<Map<String, int>>(
                initialData: {},
                stream: cubit.emotionsCount$,
                builder: (context, snapshot) {
                  final data = {
                    for (var entry in snapshot.data!.entries.take(5))
                      entry.key: entry.value.toDouble(),
                  };

                  return Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            "Common Feelings: ",
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Spacer(),
                          TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("All Emotions"),
                                    content: SingleChildScrollView(
                                      child: Wrap(
                                        children:
                                            snapshot.data!.entries.map((entry) {
                                              return Padding(
                                                padding: const EdgeInsets.all(
                                                  4.0,
                                                ),
                                                child: Chip(
                                                  label: Text(
                                                    '${entry.key}: ${entry.value}',
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("Close"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Text("See all"),
                          ),
                        ],
                      ),

                      if (!snapshot.hasData || snapshot.data!.isEmpty)
                        const Text("No emotions recorded.")
                      else
                        PieChart(
                          dataMap: data,
                          colorList: [
                            Color(0xff5C7285),
                            Color(0xff818C78),
                            Color(0xffA7B49E),
                            Color(0xffE2E0C8),
                            Color(0xffC96868),
                            Color(0xff295F98),
                            Color(0xffFF8A8A),
                            Color(0xffEF9C66),
                          ],
                          formatChartValues: (val) {
                            return '${val.toInt()}';
                          },
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
