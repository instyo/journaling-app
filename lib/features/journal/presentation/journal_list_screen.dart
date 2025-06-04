import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:journaling/common/widgets/custom_line_graph.dart';
import 'package:journaling/common/widgets/custom_dialog.dart';
import 'package:journaling/common/widgets/custom_scaffold.dart';
import 'package:journaling/common/widgets/mood_card.dart';
import 'package:journaling/common/widgets/stripped_calendar.dart';
import 'package:journaling/core/utils/context_extension.dart';
import 'package:journaling/core/utils/mood_enum.dart';
import 'package:journaling/core/utils/state_status_enum.dart';
import 'package:journaling/features/journal/cubit/journal_cubit.dart';
import 'package:journaling/features/feeling/presentation/feeling_selection_screen.dart';
import 'package:journaling/features/journal/models/journal_entry.dart';

class JournalListScreen extends StatelessWidget {
  const JournalListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'My Journals',
      body: BlocListener<JournalCubit, JournalState>(
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
      fab: FloatingActionButton(
        elevation: 0,
        onPressed: () {
          FeelingSelectionScreen.open(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildJournalContent(BuildContext context) {
    final cubit = context.read<JournalCubit>();

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CalendarStrip(
          key: ValueKey('kontolero'),
          onDateSelected: (date) {
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Add a subtle animated bounce effect to the icon
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 10),
                        duration: Duration(seconds: 1),
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, -value),
                            child: child,
                          );
                        },
                        child: Icon(
                          Icons.edit,
                          size: 70,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Use a vibrant headline style
                      Text(
                        'No journals yet.',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onBackground,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Make the call-to-action stand out
                      Text(
                        'Start your first journal!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onBackground.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Add a vibrant button encouraging user action
                      ElevatedButton.icon(
                        onPressed: () {
                          FeelingSelectionScreen.open(context);
                        },
                        icon: Icon(Icons.add),
                        label: Text('Create Journal'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          textStyle: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              );

              return AnimatedSwitcher(
                duration: Duration(milliseconds: 250),
                child:
                    journals.isEmpty
                        ? empty
                        : SizedBox.expand(
                          child: SingleChildScrollView(
                            physics: ClampingScrollPhysics(),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                _buildSummarySection(
                                  context,
                                  _calculateMostCommonMood(journals),
                                  journals.length,
                                ),
                                const SizedBox(height: 32),

                                if (sortedData.length > 1)
                                  CustomLineGraph(
                                    data:
                                        sortedData
                                            .map((e) => (e.createdAt, e.mood))
                                            .toList(),
                                    lineColor: context.primaryColor,
                                    pointColor: Color(0xff9e5656),
                                    formatTooltipLabel: (data) {
                                      return DateFormat.Hm().format(data.$1);
                                    },
                                    formatPointLabel: (data) {
                                      return "";
                                    },
                                    formatYLabel: (data) {
                                      return data.label;
                                    },
                                  ),

                                const SizedBox(height: 8),
                                _buildJournalList(context, journals),
                              ],
                            ),
                          ),
                        ),
              );
            },
          ),
        ),
      ],
    );
  }

  MoodEnum _calculateMostCommonMood(List<JournalEntry> journals) {
    if (journals.isEmpty) {
      return MoodEnum.unknown; // Default mood if no journals are present
    }

    final moodCount = <String, int>{};

    for (var journal in journals) {
      final mood = journal.mood.label;
      moodCount[mood] = (moodCount[mood] ?? 0) + 1;
    }

    // Find the mood with the highest count
    final mostCommonMoodKey =
        moodCount.entries.reduce((a, b) => a.value >= b.value ? a : b).key;

    // Return the corresponding MoodEnum
    return MoodEnum.values.firstWhere(
      (mood) => mood.label == mostCommonMoodKey,
    );
  }

  Widget _buildSummarySection(
    BuildContext context,
    MoodEnum mood,
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
            MoodCard(title: "Common Mood", value: mood.moodLabel),
            const SizedBox(width: 16), // Space between the boxes
            MoodCard(title: "Total Journals", value: "$totalJournals"),
          ],
        ),
      ],
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
              emoji: journal.mood.emoji,
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
                    journal.title,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('hh:mm a').format(journal.createdAt),
                    style: context.textTheme.bodySmall,
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
                journal.mood.emoji,
                style: context.textTheme.headlineMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
