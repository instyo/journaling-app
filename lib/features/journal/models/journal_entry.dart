import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journaling/features/journal/models/emoji_emotion.dart';

class JournalEntry {
  final String? id;
  final String userId;
  final String title;
  final String content; // Markdown text
  final String mood; // Keep the string mood
  final String label;
  final List<String> emotions; // URLs from Firebase Storage
  final DateTime createdAt;

  JournalEntry({
    this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.mood,
    required this.label,
    this.emotions = const [],
    required this.createdAt,
  });

  factory JournalEntry.fromMap(Map<String, dynamic> map, String id) {
    return JournalEntry(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      mood: map['mood'] ?? '',
      label: map['label'] ?? '',
      emotions:
          map['emotions'] == null
              ? []
              : List<String>.from(map['emotions'] ?? []),
      createdAt:
          map['createdAt'] == null
              ? DateTime.now()
              : (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'content': content,
      'mood': mood,
      'label': label,
      'emotions': emotions,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Add copyWith for immutability and easy updates
  JournalEntry copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    String? mood,
    String? label,
    List<String>? emotions,
    DateTime? createdAt,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      label: label ?? this.label,
      emotions: emotions ?? this.emotions,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  (DateTime, int) get moodLevel => (
    createdAt,
    kEmotionList.indexWhere((e) => e.emoji == mood) + 1,
  );

  double get moodChartValue =>
      (kEmotionList.indexWhere((e) => e.emoji == mood) + 1);
}
