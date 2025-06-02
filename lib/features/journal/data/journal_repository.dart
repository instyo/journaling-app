import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:journaling/core/utils/env.dart';
import '../models/journal_entry.dart';
import 'package:dio/dio.dart';

class JournalRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;
  final Dio _dio;

  JournalRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    FirebaseAuth? auth,
    Dio? dio,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _dio = dio ?? Dio();

  String? get currentUserId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _journalsCollection =>
      _firestore.collection('journals');

  Future<String> uploadMedia(String filePath, String mediaType) async {
    if (currentUserId == null) throw Exception('User not logged in');
    final file = File(filePath);
    final String fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    final Reference ref = _storage.ref().child(
      'users/${currentUserId}/journal_media/$mediaType/$fileName',
    );
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> addJournal(JournalEntry entry) async {
    if (currentUserId == null) throw Exception('User not logged in');
    await _journalsCollection.add(entry.toMap());
  }

  Future<void> updateJournal(JournalEntry entry) async {
    if (currentUserId == null) throw Exception('User not logged in');
    if (entry.id == null) throw Exception('Journal ID is required for update');
    await _journalsCollection.doc(entry.id).update(entry.toMap());
  }

  Future<void> deleteJournal(String journalId) async {
    if (currentUserId == null) throw Exception('User not logged in');
    // TODO: Also delete associated media from storage
    // You'd need to fetch the entry to get mediaUrls first, then delete them
    await _journalsCollection.doc(journalId).delete();
  }

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

  Future<String> getTitle(String journal) async {
    final response = await _dio.postUri(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      options: Options(
        headers: {
          'Authorization': 'Bearer $kOpenAIKey',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        "messages": [
          {
            "role": "system",
            "content":
                """Return a short journal title as summary for this journal and system message if it's not default. Start chat name with one appropriate emoji. Don't answer to my message, just generate a name.""",
          },
          {"role": "user", "content": journal},
        ],
        "model": "gpt-4.1-nano",
        "stream": false,
        "temperature": 0.7,
        "max_tokens": 500,
        // "response_format": {"type": "json_object"},
      },
    );

    if (response.statusCode == 200) {
      return response.data['choices'][0]['message']['content'].trim();
    } else {
      throw Exception('Failed to fetch title: ${response.statusCode}');
    }
  }
}
