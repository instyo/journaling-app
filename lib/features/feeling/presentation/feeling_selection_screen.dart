// lib/feeleing.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:journaling/core/utils/context_extension.dart';
import 'package:journaling/core/utils/mood_enum.dart';
import 'package:journaling/features/dashboard/presentation/dashboard_screen.dart';
import 'package:journaling/features/feeling/cubit/feeling_cubit.dart';
import 'package:journaling/features/feeling/cubit/feeling_state.dart';
import 'package:journaling/features/journal/cubit/journal_cubit.dart';
import 'package:journaling/features/journal/presentation/journal_write_screen_v2.dart';

class FeelingSelectionScreen extends StatelessWidget {
  const FeelingSelectionScreen({super.key});

  static void open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const FeelingSelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FeelingCubit(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              icon: Icon(Icons.close, color: context.primaryColor),
              onPressed: () {
                final jCubit = context.read<JournalCubit>();

                jCubit.changeDate(DateTime.now());
                DashboardScreen.open(context);
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: BlocBuilder<FeelingCubit, FeelingState>(
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24.0),
                    Text(
                      'How are you feeling today?',
                      style: context.textTheme.headlineSmall?.copyWith(
                        color: context.subtextColor,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Which emoji describes how you are feeling now?',
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: context.subtextColor,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:
                          MoodEnum.values.sublist(1, 6).map((item) {
                            final bool isSelected = item == state.selected;
                            return GestureDetector(
                              onTap: () {
                                context.read<FeelingCubit>().selectMood(item);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? context.primaryColor
                                            : Colors.grey[200]!,
                                    width: isSelected ? 2.0 : 1.0,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      item.emoji,
                                      style: const TextStyle(fontSize: 36),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.label,
                                      style: context.textTheme.bodyLarge
                                          ?.copyWith(
                                            color:
                                                isSelected
                                                    ? const Color(0xFF4C873D)
                                                    : Colors.grey[700],
                                            fontWeight:
                                                isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 32.0),
                    Text(
                      'Which emotions describe\nyour feelings?',
                      style: context.textTheme.headlineSmall?.copyWith(
                        color: context.subtextColor,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children:
                          state.selected.feelings.map((feeling) {
                            final bool isSelected = state.selectedFeelings
                                .contains(feeling);

                            return GestureDetector(
                              onTap: () {
                                context.read<FeelingCubit>().toggleFeeling(
                                  feeling,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 10.0,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? Colors.transparent
                                          : const Color(0xFFF0F5ED),
                                  borderRadius: BorderRadius.circular(20.0),
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? const Color(0xFF4C873D)
                                            : const Color(0xFFF0F5ED),
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  feeling,
                                  style: context.textTheme.bodyLarge?.copyWith(
                                    color:
                                        isSelected
                                            ? const Color(0xFF4C873D)
                                            : Colors.grey[700],
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                    const Expanded(child: SizedBox()),
                    SizedBox(
                      width: double.infinity,
                      height: 56.0,
                      child: ElevatedButton(
                        onPressed: () {
                          // Action when Next button is pressed
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => JournalWriteScreenV2(
                                    item: state.selected,
                                    feelings: state.selectedFeelings,
                                  ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: Text(
                          'Next',
                          style: context.textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
