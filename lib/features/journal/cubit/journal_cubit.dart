import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:journaling/core/utils/state_status_enum.dart';
import '../data/journal_repository.dart';
import '../models/journal_entry.dart';

part 'journal_state.dart';

class JournalCubit extends Cubit<JournalState> {
  final JournalRepository _journalRepository;

  JournalCubit(this._journalRepository) : super(JournalState()) {
    getJournalsByDate(DateTime.now());
  }

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

  Future<void> createJournal(JournalEntry newEntry) async {
    emit(state.copyWith(status: StateStatus.loading));

    try {
      final title = await _journalRepository.getTitle(newEntry.content);

      await _journalRepository.addJournal(newEntry.copyWith(title: title));
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
