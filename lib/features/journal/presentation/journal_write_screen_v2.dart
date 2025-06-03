// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:journaling/common/widgets/custom_chip.dart';
import 'package:journaling/common/widgets/custom_scaffold.dart';
import 'package:journaling/common/widgets/markdown_input_v2.dart';
import 'package:journaling/core/utils/context_extension.dart';
import 'package:journaling/core/utils/mood_enum.dart';
import 'package:journaling/core/utils/state_status_enum.dart';
import 'package:journaling/features/dashboard/presentation/dashboard_screen.dart';
import 'package:journaling/features/journal/cubit/journal_cubit.dart';
import 'package:journaling/features/journal/models/journal_entry.dart';

class JournalWriteScreenV2 extends StatelessWidget {
  final MoodEnum item;
  final List<String> feelings;
  final JournalEntry? entry;

  const JournalWriteScreenV2({
    super.key,
    required this.item,
    required this.feelings,
    this.entry,
  });

  bool get isEdit => entry != null;

  static void open(
    BuildContext context, {
    required MoodEnum item,
    required List<String> feelings,
    JournalEntry? entry,
  }) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder:
            (context) => JournalWriteScreenV2(
              item: item, // Assuming a default emoji is available
              feelings: feelings, // Provide a default or empty list of emotions
              entry: entry,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController();
    final titleController = TextEditingController();
    final cubit = context.read<JournalCubit>();

    return CustomScaffold(
      title: "Write Your Journal",
      body: BlocBuilder<JournalCubit, JournalState>(
        bloc: cubit..loadPreferences(),
        builder: (context, state) {
          final bool isLoading = state.status == StateStatus.loading;

          return Stack(
            children: [
              AbsorbPointer(
                absorbing: isLoading,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isLoading) LinearProgressIndicator(),
                    StreamBuilder<bool>(
                      initialData: false,
                      stream: cubit.showTitleField$,
                      builder: (context, snapshot) {
                        if (snapshot.data != true) {
                          return const SizedBox();
                        }

                        return Container(
                          margin: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey.shade300,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextFormField(
                            decoration: InputDecoration(
                              hintText: 'Title',
                              hintStyle: TextStyle(color: Colors.grey.shade500),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                            ),
                            onChanged: (text) {
                              // Handle title input change if needed
                              titleController.text = text;
                            },
                          ),
                        );
                      },
                    ),
                    MarkdownInputV2(
                      initialValue: entry?.content,
                      onChanged: (text) {
                        textController.text = text;
                      },
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      alignment: WrapAlignment.start,
                      runAlignment: WrapAlignment.start,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      runSpacing: 8,
                      children: [
                        for (final feeling
                            in (isEdit ? entry!.feelings : feelings))
                          CustomChip(text: feeling, isSelected: true),
                      ],
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      CustomChip(
                        text:
                            isEdit
                                ? '${entry?.mood.emoji} ${entry?.mood.label}'
                                : '${item.emoji} ${item.label}',
                        isSelected: true,
                      ),
                      Spacer(),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          shape: StadiumBorder(),
                          foregroundColor: Theme.of(context).primaryColor,
                          backgroundColor: const Color(0xFFF0F5ED),
                        ),
                        onPressed: () async {
                          final title = titleController.text;

                          if (isEdit) {
                            final journal = entry?.copyWith(
                              title: title,
                              content: textController.text,
                            );

                            await cubit.updateJournal(journal!);
                          } else {
                            final journal = JournalEntry(
                              userId: context.userId,
                              title: title,
                              content: textController.text,
                              createdAt: DateTime.now(),
                              feelings: feelings,
                              mood: item,
                            );

                            await cubit.createJournal(journal);
                          }

                          // Refresh and navigate
                          final journalCubit = context.read<JournalCubit>();
                          journalCubit.changeDate(DateTime.now());
                          DashboardScreen.open(context);
                        },
                        label: Text("Submit"),
                        icon: Icon(Icons.send),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
