import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:journaling/features/journal/data/journal_repository.dart';
import '../models/journal_entry.dart';

class FirebaseJournalRepository implements IJournalRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;

  FirebaseJournalRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance,
       _auth = auth ?? FirebaseAuth.instance;

  @override
  String? get currentUserId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _journalsCollection =>
      _firestore.collection('journals');

  @override
  Future<String> uploadMedia(String filePath, String mediaType) async {
    if (currentUserId == null) throw Exception('User not logged in');
    final file = File(filePath);
    final String fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    final Reference ref = _storage.ref().child(
      'users/$currentUserId/journal_media/$mediaType/$fileName',
    );
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  @override
  Future<void> addJournal(JournalEntry entry) async {
    if (currentUserId == null) throw Exception('User not logged in');
    await _journalsCollection.add(entry.toMap());
  }

  @override
  Future<void> updateJournal(JournalEntry entry) async {
    if (currentUserId == null) throw Exception('User not logged in');
    if (entry.id == null) throw Exception('Journal ID is required for update');
    await _journalsCollection.doc(entry.id).update(entry.toMap());
  }

  @override
  Future<void> deleteJournal(String journalId) async {
    if (currentUserId == null) throw Exception('User not logged in');
    // TODO: Also delete associated media from storage
    // You'd need to fetch the entry to get mediaUrls first, then delete them
    await _journalsCollection.doc(journalId).delete();
  }

  @override
  Stream<List<JournalEntry>> getJournals() {
    if (currentUserId == null) return Stream.value([]);
    return _journalsCollection
        .where('userId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => JournalEntry.fromMap(doc.data(), doc.id))
                  .toList(),
        );
  }

  @override
  Stream<List<JournalEntry>> getJournalsByDate(DateTime date) {
    if (currentUserId == null) return Stream.value([]);
    return _journalsCollection
        .where('userId', isEqualTo: currentUserId)
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: DateTime(date.year, date.month, date.day),
        )
        .where(
          'createdAt',
          isLessThan: DateTime(date.year, date.month, date.day + 1),
        )
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => JournalEntry.fromMap(doc.data(), doc.id))
                  .toList(),
        );
  }

  @override
  Stream<List<JournalEntry>> getJournalsInBetweenDates(
    DateTime startDate,
    DateTime endDate,
  ) {
    if (currentUserId == null) return Stream.value([]);
    return _journalsCollection
        .where('userId', isEqualTo: currentUserId)
        .where('createdAt', isGreaterThanOrEqualTo: startDate)
        .where('createdAt', isLessThan: endDate)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => JournalEntry.fromMap(doc.data(), doc.id))
                  .toList(),
        );
  }
}
