import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:journaling/core/utils/datetime_extension.dart';
import 'package:journaling/core/utils/sembast_service.dart';
import 'package:journaling/features/journal/data/journal_repository.dart';
import 'package:journaling/features/journal/models/journal_entry.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:uuid/uuid.dart';

class LocalJournalRepository implements IJournalRepository {
  static final LocalJournalRepository _instance =
      LocalJournalRepository._internal();

  factory LocalJournalRepository() {
    return _instance;
  }

  LocalJournalRepository._internal();

  final _db = SembastService().db;
  final _journalStore = SembastService().journalStore;

  @override
  Future<void> addJournal(JournalEntry journal) async {
    if (journal.id == null || journal.id!.isEmpty) {
      journal = journal.copyWith(id: Uuid().v4());
    }

    await _db.transaction((tx) async {
      try {
        await _journalStore.add(tx, journal.toMap());
      } catch (e, s) {
        debugPrint('>> Error: $e, $s');
      }
    });
  }

  @override
  Future<void> updateJournal(JournalEntry journal) async {
    await _db.transaction((tx) async {
      await _journalStore.update(tx, journal.toMap());
    });
  }

  @override
  Future<void> deleteJournal(String journalId) async {
    await _db.transaction((tx) async {
      await _journalStore.delete(
        tx,
        finder: Finder(filter: Filter.equals('id', journalId)),
      );
    });
  }

  @override
  Stream<List<JournalEntry>> getJournals() {
    // return _journalStore.query(_db).onSnapshots(_db).transform(kBaseMessageModelTransformer);
    throw UnimplementedError();
  }

  @override
  Stream<List<JournalEntry>> getJournalsByDate(DateTime date) {
    try {
      final finder = Finder(
        filter: Filter.custom((record) {
          final createdAt = DateTime.tryParse(
            (record.value as dynamic)['createdAt'],
          );

          if (createdAt == null) {
            return false;
          }

          return date.formattedDate == createdAt.formattedDate;
        }),
        sortOrders: [SortOrder('createdAt')],
      );

      return _journalStore
          .query(finder: finder) // Apply the finder to the query
          .onSnapshots(_db)
          .transform(kJournalEntryTransformer);
    } catch (e, s) {
      debugPrint('>> $e, $s');
      return Stream.value([]);
    }
  }

  @override
  Stream<List<JournalEntry>> getJournalsInBetweenDates(
    DateTime startDate,
    DateTime endDate,
  ) {
    try {
      final finder = Finder(
        filter: Filter.custom((record) {
          final createdAt = DateTime.tryParse(
            (record.value as dynamic)['createdAt'],
          );

          if (createdAt == null) {
            return false;
          }

          return createdAt.isAfter(startDate) && createdAt.isBefore(endDate);
        }),
        sortOrders: [SortOrder('createdAt')],
      );

      return _journalStore
          .query(finder: finder)
          .onSnapshots(_db)
          .transform(kJournalEntryTransformer);
    } catch (e, s) {
      debugPrint('>> $e, $s');
      return Stream.value([]);
    }
  }

  @override
  // TODO: implement currentUserId
  String? get currentUserId => throw UnimplementedError();

  @override
  Future<String> uploadMedia(String filePath, String mediaType) {
    // TODO: implement uploadMedia
    throw UnimplementedError();
  }
}

final kJournalEntryTransformer = StreamTransformer<
  List<RecordSnapshot<String, Map<String, Object?>>>,
  List<JournalEntry>
>.fromHandlers(
  handleData: (snapshotList, sink) {
    sink.add(
      snapshotList.map((e) => JournalEntry.fromMap(e.value, e.key)).toList(),
    );
  },
);
