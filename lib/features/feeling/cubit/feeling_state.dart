// lib/feeling_cubit.dart
import 'package:journaling/core/utils/mood_enum.dart';

class FeelingState {
  final MoodEnum selected;
  final List<String> selectedFeelings;

  FeelingState({
    required this.selected,
    required this.selectedFeelings,
  });
}