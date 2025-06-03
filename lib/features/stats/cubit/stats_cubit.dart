import 'dart:async'; // Import for StreamSubscription
import 'dart:math';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:journaling/core/utils/state_status_enum.dart';
import 'package:journaling/features/journal/data/journal_repository.dart';
import 'package:journaling/features/journal/models/emoji_emotion.dart';
import 'package:journaling/features/journal/models/journal_entry.dart';

part 'stats_state.dart';

class StatsCubit extends Cubit<StatsState> {
  final JournalRepository _journalRepository;

  StatsCubit(this._journalRepository) : super(StatsState());

  Stream<int> get totalJournal$ =>
      stream.map((state) => state.journals.length).distinct();

  Stream<String> get commonMood$ {
    return stream.map((state) {
      if (state.journals.isEmpty) return '';
      final moodCount = <String, int>{};

      for (var journal in state.journals) {
        final mood = journal.mood; // Assuming JournalEntry has a mood property

        moodCount[mood] = (moodCount[mood] ?? 0) + 1;
      }

      // Check if moodCount is empty before trying to find the max
      if (moodCount.isEmpty) return '';

      // Find the mood with the highest count
      return moodCount.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    }).distinct();
  }

  Stream<Map<String, int>> get emotionsCount$ {
    return stream.map((state) {
      final emotionCount = <String, int>{};

      for (var journal in state.journals) {
        for (var emotion in journal.emotions) {
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

  Stream<List<(DateTime, int)>> get averageMoodsIn7Days$ {
    final moodCount = <DateTime, List<int>>{};
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

          final moodIndex = kEmotionList.indexWhere(
            (emotion) => emotion.emoji == journal.mood,
          );
          if (moodIndex != -1) {
            moodCount[date]!.add(moodIndex + 1); // +1 to match the 1-5 scale
          }
        }
      }

      return moodCount.entries.map((entry) {
        final date = entry.key;
        final totalMoods = entry.value.length;

        // Calculate the average mood as an integer
        final averageMood =
            totalMoods > 0
                ? (entry.value.reduce((a, b) => a + b) / totalMoods).round()
                : 0; // Default to 0 if no moods

        return (date, averageMood);
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

    for (int i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      for (int j = 0; j < 3; j++) {
        final randomData =
            kEmotionList[Random().nextInt(kEmotionList.length - 1)];
        dummyEntries.add(
          JournalEntry(
            userId: userId,
            title: 'Journal ${DateTime.now().toIso8601String()}',
            content:
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
            mood: randomData.emoji,
            label: randomData.label,
            emotions: (randomData.emotion.toList()..shuffle()).sublist(0, 4),
            createdAt: date.subtract(Duration(hours: Random().nextInt(9))),
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
