// lib/feeling_cubit.dart
import 'package:journaling/features/journal/models/emoji_emotion.dart';

class FeelingState {
  final EmojiEmotion selected;
  final List<String> selectedEmotions;

  FeelingState({
    required this.selected,
    required this.selectedEmotions,
  });
}