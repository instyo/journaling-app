import 'dart:async'; // Import for StreamSubscription
import 'dart:math';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:journaling/core/utils/mood_enum.dart';
import 'package:journaling/core/utils/state_status_enum.dart';
import 'package:journaling/features/journal/data/journal_repository.dart';
import 'package:journaling/features/journal/models/journal_entry.dart';

part 'stats_state.dart';

class StatsCubit extends Cubit<StatsState> {
  final IJournalRepository _journalRepository;

  StatsCubit(this._journalRepository) : super(StatsState());

  Stream<int> get totalJournal$ =>
      stream.map((state) => state.journals.length).distinct();

  Stream<MoodEnum> get commonMood$ {
    final moodCount = <MoodEnum, int>{};
    final today = DateTime.now();

    return stream.map((state) {
      for (var journal in state.journals) {
        final date = DateTime(
          journal.createdAt.year,
          journal.createdAt.month,
          journal.createdAt.day,
        );

        if (date.isAfter(today.subtract(Duration(days: 7))) &&
            date.isBefore(today.add(Duration(days: 1)))) {
          moodCount[journal.mood] = (moodCount[journal.mood] ?? 0) + 1;
        }
      }

      // Find the most common mood
      final commonMood =
          moodCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      return commonMood;
    }).distinct();
  }

  Stream<Map<String, int>> get emotionsCount$ {
    return stream.map((state) {
      final emotionCount = <String, int>{};

      for (var journal in state.journals) {
        for (var emotion in journal.feelings) {
          // Iterate through the list of emotions
          emotionCount[emotion] = (emotionCount[emotion] ?? 0) + 1;
        }
      }

      // Sort by count, greater count first
      final sortedEmotionCount = Map.fromEntries(
        emotionCount.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)),
      );

      return sortedEmotionCount;
    }).distinct();
  }

  Stream<List<(DateTime, MoodEnum)>> get averageMoodsIn7Days$ {
    final moodCount = <DateTime, List<MoodEnum>>{};
    final today = DateTime.now();

    return stream.map((stateX) {
      for (var journal in stateX.journals) {
        final date = DateTime(
          journal.createdAt.year,
          journal.createdAt.month,
          journal.createdAt.day,
        );

        if (date.isAfter(today.subtract(Duration(days: 7))) &&
            date.isBefore(today.add(Duration(days: 1)))) {
          if (!moodCount.containsKey(date)) {
            moodCount[date] = [];
          }

          moodCount[date]!.add(journal.mood); // Store MoodEnum directly
        }
      }

      return moodCount.entries.map((entry) {
        final date = entry.key;
        final totalMoods = entry.value.length;

        // Calculate the average mood as an integer
        final averageMood =
            totalMoods > 0
                ? (entry.value
                            .map((mood) => mood.value)
                            .reduce((a, b) => a + b) /
                        totalMoods)
                    .round()
                : 0; // Default to 0 if no moods

        return (
          date,
          MoodEnum.values[averageMood - 1],
        ); // Convert back to MoodEnum
      }).toList();
    });
  }

  Future<void> getJournals() async {
    final today = DateTime.now();

    emit(state.copyWith(status: StateStatus.loading));

    _journalRepository
        .getJournalsInBetweenDates(today.subtract(Duration(days: 7)), today)
        .listen(
          (journals) {
            print(">> Journals Stats: ${journals.length}");
            emit(
              state.copyWith(journals: journals, status: StateStatus.success),
            );
          },
          onError: (e) {
            emit(
              state.copyWith(
                errorMessage: e.toString(),
                status: StateStatus.error,
              ),
            );
          },
        );
  }

  List<JournalEntry> generateDummyData(String userId) {
    final List<JournalEntry> dummyEntries = [];
    final today = DateTime.now();
    final feelings = MoodEnum.values.map((mood) => mood.feelings).toList();

    for (int i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      for (int j = 0; j < 3; j++) {
        dummyEntries.add(
          JournalEntry(
            userId: userId,
            title: 'Journal ${DateTime.now().toIso8601String()}',
            content:
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
            // mood: randomData.emoji,
            // label: randomData.label,
            feelings: feelings[Random().nextInt(5) + 1].sublist(0, 6),
            createdAt: date.subtract(Duration(hours: Random().nextInt(9) + 1)),
            mood: MoodEnum.values[Random().nextInt(5) + 1],
          ),
        );
      }
    }

    return dummyEntries;
  }

  Future<void> createDummy(String userId) async {
    try {
      final data = generateDummyData(userId);

      print(">> Data length : ${data.first.toMap()}");

      await Future.forEach(data, (item) async {
        await Future.delayed(Duration(milliseconds: 500));
        await _journalRepository.addJournal(item);
      });
    } catch (e, s) {
      print(">> ERR : $e, $s");
    }
  }
}
