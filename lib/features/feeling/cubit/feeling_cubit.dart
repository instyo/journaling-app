import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:journaling/features/feeling/cubit/feeling_state.dart';
import 'package:journaling/features/journal/models/emoji_emotion.dart';

class FeelingCubit extends Cubit<FeelingState> {
  FeelingCubit()
    : super(
        FeelingState(
          selected: kEmotionList.last,
          selectedEmotions: [],
        ),
      );

  void selectEmotion(EmojiEmotion emotion) {
    emit(
      FeelingState(
        selected: emotion,
        selectedEmotions: [],
      ),
    );
  }

  void toggleEmotion(String emotion) {
    final newEmotions = List<String>.from(state.selectedEmotions);
    if (newEmotions.contains(emotion)) {
      newEmotions.remove(emotion);
    } else {
      newEmotions.add(emotion);
    }
    emit(
      FeelingState(
        selected: state.selected,
        selectedEmotions: newEmotions,
      ),
    );
  }
}
