import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:journaling/core/utils/state_status_enum.dart';
import 'package:journaling/features/journal/data/open_ai_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../data/journal_repository.dart';
import '../models/journal_entry.dart';

part 'journal_state.dart';

class JournalCubit extends Cubit<JournalState> {
  final IJournalRepository _journalRepository;

  JournalCubit(this._journalRepository) : super(JournalState()) {
    getJournalsByDate(DateTime.now());
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    final useAI = await isUseAI();
    showTitleField$.add(!useAI);
  }

  Future<bool> isUseAI() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('useAI') ?? false;
  }

  final showTitleField$ = BehaviorSubject<bool>.seeded(true);

  Stream<List<JournalEntry>> get journals$ =>
      stream.map((e) => e.journals).distinct();

  void changeDate(DateTime date) {
    emit(state.copyWith(filterDate: date));

    getJournalsByDate(date);
  }

  Future<void> getJournalsByDate(DateTime date) async {
    emit(state.copyWith(status: StateStatus.loading));

    _journalRepository
        .getJournalsByDate(date)
        .listen(
          (journals) {
            print(">> journals: ${journals.length}");
            emit(
              state.copyWith(journals: journals, status: StateStatus.success),
            );
          },
          onError: (e, s) {
            print(">> $e, $s");
            emit(
              state.copyWith(
                errorMessage: e.toString(),
                status: StateStatus.error,
              ),
            );
          },
        );
  }

  Future<void> createJournal(JournalEntry newEntry) async {
    emit(state.copyWith(status: StateStatus.loading));

    try {
      final useAI = await isUseAI();

      final title =
          !useAI
              ? newEntry.title
              : await OpenAiService().getTitle(newEntry.content);
      
      print(">> Add jurnal with title: $title");
      
      await _journalRepository.addJournal(
        newEntry.copyWith(id: Uuid().v4(), title: title),
      );
      // State will update automatically due to listening to stream
    } catch (e) {
      emit(
        state.copyWith(status: StateStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> updateJournal(JournalEntry updatedEntry) async {
    if (state.status == StateStatus.error) return;

    try {
      await _journalRepository.updateJournal(updatedEntry);
      // State will update automatically due to listening to stream
    } catch (e) {
      emit(
        state.copyWith(errorMessage: e.toString(), status: StateStatus.error),
      );
    }
  }

  Future<void> deleteJournal(String journalId) async {
    if (state.status == StateStatus.error) return;

    // Potentially transition to a 'JournalDeleting' state
    try {
      await _journalRepository.deleteJournal(journalId);
      // State will update automatically due to listening to stream
    } catch (e) {
      emit(
        state.copyWith(errorMessage: e.toString(), status: StateStatus.error),
      );
    }
  }
}
