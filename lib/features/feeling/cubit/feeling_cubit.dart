import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:journaling/core/utils/mood_enum.dart';
import 'package:journaling/features/feeling/cubit/feeling_state.dart';

class FeelingCubit extends Cubit<FeelingState> {
  FeelingCubit()
    : super(FeelingState(selected: MoodEnum.values.last, selectedFeelings: []));

  void selectMood(MoodEnum mood) {
    emit(FeelingState(selected: mood, selectedFeelings: []));
  }

  void toggleFeeling(String feeling) {
    final newFeelings = List<String>.from(state.selectedFeelings);

    if (newFeelings.contains(feeling)) {
      newFeelings.remove(feeling);
    } else {
      newFeelings.add(feeling);
    }
    emit(FeelingState(selected: state.selected, selectedFeelings: newFeelings));
  }
}
