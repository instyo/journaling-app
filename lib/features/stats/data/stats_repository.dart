import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../journal/models/journal_entry.dart';
import '../../../common/constants.dart';

class StatsRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  StatsRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  Stream<Map<Mood, int>> getMoodCountsByTime({DateTime? start, DateTime? end}) {
    if (currentUserId == null) return Stream.value({});

    Query query = _firestore
        .collection('journals')
        .where('userId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true); // Or use ascending for chart

    if (start != null) {
      query = query.where('createdAt', isGreaterThanOrEqualTo: start);
    }
    if (end != null) {
      query = query.where('createdAt', isLessThanOrEqualTo: end);
    }

    return query.snapshots().map((snapshot) {
      final Map<Mood, int> moodCounts = {for (var mood in Mood.values) mood: 0};
      for (var doc in snapshot.docs) {
        final entry = JournalEntry.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
        // moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
      }
      return moodCounts;
    });
  }
}
