import 'package:flutter/material.dart';

class EmojiEmotion {
  final String emoji;
  final String label;
  final List<String> emotion;
  final Color? color; // Added color property

  const EmojiEmotion({
    required this.emoji,
    required this.label,
    required this.emotion,
    this.color, // Include color in the constructor
  });

  factory EmojiEmotion.fromJson(Map<String, dynamic> json) {
    return EmojiEmotion(
      emoji: json['emoji'] as String,
      label: json['label'] as String,
      emotion: List<String>.from(json['emotion'] as List),
      color: _hexToColor(json['color'] as String), // Parse hex color
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emoji': emoji,
      'label': label,
      'emotion': emotion,
      'color': color?.toHexTriplet(),
    };
  }

  // Helper method to convert hex color to Color
  static Color _hexToColor(String hexColor) {
    return Color(int.parse(hexColor.replaceFirst('#', '0xff')));
  }
}

// Example usage to convert your list of maps to a list of EmojiEmotion objects:
final List<Map<String, dynamic>> rawEmojiEmotions = [
  {
    'emoji': '😔',
    'label': 'Bad',
    'color': '#EA2F14',
    'emotion': [
      'Sad',
      'Anxious',
      'Frustrated',
      'Disappointed',
      'Stressed',
      'Overwhelmed',
      'Lonely',
      'Guilty',
      'Ashamed',
    ],
  },
  {
    'emoji': '😑',
    'label': 'Meh',
    'color': '#FB9E3A',
    'emotion': [
      'Indifferent',
      'Bored',
      'Unenthusiastic',
      'Apathetic',
      'Underwhelmed',
      'Tired',
      'Annoyed',
      'Unmotivated',
      'Distracted',
    ],
  },
  {
    'emoji': '😐',
    'label': 'Okay',
    'color': '#FCEF91',
    'emotion': [
      'Calm',
      'Content',
      'Neutral',
      'Balanced',
      'Relaxed',
      'Fine',
      'Acceptable',
      'Peaceful',
      'Settled',
    ],
  },
  {
    'emoji': '🙂',
    'label': 'Good',
    'color': '#F0F2BD',
    'emotion': [
      'Confident',
      'Grateful',
      'Proud',
      'Excited',
      'Inspired',
      'Brave',
      'Energized',
      'Happy',
      'Optimistic',
      'Playful',
      'Accomplished',
      'Hopeful',
    ],
  },
  {
    'emoji': '😊',
    'label': 'Great',
    'color': '#B2CD9C',
    'emotion': [
      'Joyful',
      'Thrilled',
      'Elated',
      'Enthusiastic',
      'Accomplished',
      'Peaceful',
      'Loving',
      'Ecstatic',
      'Giddy',
      'Blissful',
      'Overjoyed',
    ],
  },
];

final List<EmojiEmotion> kEmotionList =
    rawEmojiEmotions.map((json) => EmojiEmotion.fromJson(json)).toList();

extension ColorX on Color {
  String toHexTriplet() =>
      '#${(value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
}
