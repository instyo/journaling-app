import '../models/journal_entry.dart';

abstract class IJournalRepository {
  String? get currentUserId;
  Future<String> uploadMedia(String filePath, String mediaType);
  Future<void> addJournal(JournalEntry entry);
  Future<void> updateJournal(JournalEntry entry);
  Future<void> deleteJournal(String journalId);
  Stream<List<JournalEntry>> getJournals();
  Stream<List<JournalEntry>> getJournalsByDate(DateTime date);
  Stream<List<JournalEntry>> getJournalsInBetweenDates(
    DateTime startDate,
    DateTime endDate,
  );
}
