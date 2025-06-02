import 'dart:async'; // Import for StreamSubscription
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/stats_repository.dart';
import '../../../common/constants.dart'; // For Mood enum

part 'stats_state.dart';

class StatsCubit extends Cubit<StatsState> {
  final StatsRepository _statsRepository;
  StreamSubscription<Map<Mood, int>>?
  _moodStatsSubscription; // To manage the stream subscription

  StatsCubit(this._statsRepository) : super(StatsInitial());

  // This method can be called from the UI when the screen loads or filters change.
  Future<void> loadMoodStats({DateTime? startDate, DateTime? endDate}) async {
    // Cancel any existing subscription before starting a new one
    await _moodStatsSubscription?.cancel();
    emit(StatsLoading()); // Indicate that loading has started

    try {
      // Start a new subscription to the repository's stream
      _moodStatsSubscription = _statsRepository
          .getMoodCountsByTime(start: startDate, end: endDate)
          .listen(
            (moodCounts) {
              // When new data comes from the stream, emit a loaded state
              emit(StatsLoaded(moodCounts: moodCounts));
            },
            onError: (error, stackTrace) {
              // If there's an error in the stream, emit an error state
              emit(StatsError(error.toString()));
            },
            // Ensure the stream is canceled if the Cubit closes
            onDone: () => _moodStatsSubscription = null,
          );
    } catch (e) {
      // Catch any immediate errors from setting up the stream
      emit(StatsError('Failed to initialize stats stream: $e'));
    }
  }

  @override
  Future<void> close() {
    // Cancel the subscription when the Cubit is closed to prevent memory leaks
    _moodStatsSubscription?.cancel();
    return super.close();
  }
}
