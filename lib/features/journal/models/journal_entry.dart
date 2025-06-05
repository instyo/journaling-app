import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journaling/core/utils/env.dart';
import 'package:journaling/core/utils/mood_enum.dart';

class JournalEntry {
  final String? id;
  final String userId;
  final String title;
  final String content; // Markdown text
  final MoodEnum mood;
  final List<String> feelings; // URLs from Firebase Storage
  final DateTime createdAt;

  JournalEntry({
    this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.mood,
    this.feelings = const [],
    required this.createdAt,
  });

  factory JournalEntry.fromMap(Map<String, dynamic> map, String id) {
    return JournalEntry(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      mood:
          map['mood'] == null
              ? MoodEnum.great
              : MoodEnum.values.firstWhere((e) => e.value == map['mood']),
      feelings:
          map['feelings'] == null
              ? []
              : List<String>.from(map['feelings'] ?? []),
      createdAt:
          map['createdAt'] == null
              ? DateTime.now()
              : Env.kLocalDb ? DateTime.parse(map['createdAt']) : (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'content': content,
      'mood': mood.value,
      'feelings': feelings,
      'createdAt': Env.kLocalDb ? createdAt.toIso8601String() : Timestamp.fromDate(createdAt),
    };
  }

  // Add copyWith for immutability and easy updates
  JournalEntry copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    MoodEnum? mood,
    List<String>? feelings,
    DateTime? createdAt,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      feelings: feelings ?? this.feelings,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // (DateTime, int) get moodLevel => (
  //   createdAt,
  //   kEmotionList.indexWhere((e) => e.emoji == mood) + 1,
  // );

  // double get moodChartValue =>
  //     (kEmotionList.indexWhere((e) => e.emoji == mood) + 1);
}
