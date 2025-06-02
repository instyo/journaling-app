import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:journaling/common/widgets/LineChartSample.dart';
import 'package:journaling/common/widgets/custom_dialog.dart';
import 'package:journaling/common/widgets/custom_scaffold.dart';
import 'package:journaling/common/widgets/stripped_calendar.dart';
import 'package:journaling/core/utils/context_extension.dart';
import 'package:journaling/core/utils/state_status_enum.dart';
import 'package:journaling/features/auth/cubit/auth_cubit.dart';
import 'package:journaling/features/journal/cubit/journal_cubit.dart';
import 'package:journaling/features/feeling/presentation/feeling_selection_screen.dart';
import 'package:journaling/features/journal/models/emoji_emotion.dart';
import 'package:journaling/features/journal/models/journal_entry.dart';

class JournalListScreen extends StatelessWidget {
  const JournalListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'My Journals',
      actions: _buildActions(context),
      body: BlocListener<JournalCubit, JournalState>(
        // builder: (context, state) {
        //   if (state is JournalInitial) {
        //     return const Center(child: Text('Loading journals...'));
        //   }

        //   if (state is JournalLoading) {
        //     return const Center(child: CircularProgressIndicator());
        //   }

        //   if (state is JournalError) {
        //     return Center(child: Text('Error: ${state.message}'));
        //   }

        //   if (state is JournalsLoaded) {
        //     return _buildJournalContent(context, state);
        //   }
        //   return const SizedBox.shrink(); // Fallback
        // },
        listener: (BuildContext context, JournalState state) {
          if (state.status == StateStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.errorMessage}'),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        child: _buildJournalContent(context),
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.add),
        onPressed: () {
          FeelingSelectionScreen.open(context);
        },
      ),
      IconButton(
        icon: const Icon(Icons.logout),
        onPressed: () => context.read<AuthCubit>().signOut(),
      ),
    ];
  }

  String _getEmoji(int value) {
    return rawEmojiEmotions[value - 1]['emoji'] ?? '❤️';
  }

  Widget _buildJournalContent(BuildContext context) {
    final cubit = context.read<JournalCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CalendarStrip(
          key: ValueKey('kontolero'),
          onDateSelected: (date) {
            print(">> Date : $date");
            cubit.changeDate(date);
          },
        ),
        Expanded(
          child: StreamBuilder<List<JournalEntry>>(
            stream: cubit.journals$,
            initialData: [],
            builder: (context, snapshot) {
              final journals = snapshot.data!;
              final sortedData = [...journals]
                ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

              final empty = SizedBox.expand(
                child: Center(
                  child: Text('No journals yet. Write your first one!'),
                ),
              );

              return AnimatedSwitcher(
                duration: Duration(milliseconds: 250),
                child:
                    journals.isEmpty
                        ? empty
                        : SingleChildScrollView(
                          physics: ClampingScrollPhysics(),

                          child: Column(
                            children: [
                              _buildSummarySection(
                                context,
                                _calculateMostCommonMood(journals),
                                journals.length,
                              ),
                              const SizedBox(height: 32),

                              CustomLineGraph(
                                data:
                                    sortedData.map((e) => e.moodLevel).toList(),
                                lineColor: Colors.green,
                                pointColor: Colors.orange,
                                formatTooltipLabel: (time, value) {
                                  return DateFormat.Hm().format(time);
                                },
                                formatPointLabel: (d, i) {
                                  return _getEmoji(i);
                                },
                                formatYLabel: (val) {
                                  switch (val) {
                                    case 1:
                                      return 'Bad';
                                    case 2:
                                      return 'Meh';
                                    case 3:
                                      return 'Okay';
                                    case 4:
                                      return 'Good';
                                    case 5:
                                      return 'Great';
                                    default:
                                      return '';
                                  }
                                },
                              ),

                              const SizedBox(height: 8),
                              _buildJournalList(context, journals),
                            ],
                          ),
                        ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _calculateMostCommonMood(List<JournalEntry> journals) {
    final moodCount = <String, int>{};
    for (var journal in journals) {
      moodCount[journal.mood] = (moodCount[journal.mood] ?? 0) + 1;
    }
    return moodCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  Widget _buildSummarySection(
    BuildContext context,
    String mostCommonMood,
    int totalJournals,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          "Today's summary :",
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildMoodCard(context, "Common Mood", mostCommonMood),
            const SizedBox(width: 16), // Space between the boxes
            _buildMoodCard(context, "Total Journals", "$totalJournals"),
          ],
        ),
      ],
    );
  }

  Widget _buildMoodCard(BuildContext context, String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJournalList(BuildContext context, List<JournalEntry> journals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's journey :",
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        for (final journal in journals) _buildJournalItem(context, journal),
      ],
    );
  }

  Widget _buildJournalItem(BuildContext context, JournalEntry journal) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) {
            return CustomDialogBox(
              title: journal.title,
              descriptions: journal.content,
              text: 'Close',
              emoji: journal.mood,
              onDelete: () {
                Navigator.pop(context);
                context.read<JournalCubit>().deleteJournal(journal.id!);
              },
            );
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat(
                      'MMM dd, yyyy hh:mm a',
                    ).format(journal.createdAt),
                    style: context.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    journal.title,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 60,
              height: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                journal.mood,
                style: context.textTheme.headlineMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
