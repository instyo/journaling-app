class EmojiEmotion {
  final String emoji;
  final String label;
  final List<String> emotion;

  const EmojiEmotion({
    required this.emoji,
    required this.label,
    required this.emotion,
  });

  factory EmojiEmotion.fromJson(Map<String, dynamic> json) {
    return EmojiEmotion(
      emoji: json['emoji'] as String,
      label: json['label'] as String,
      emotion: List<String>.from(json['emotion'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {'emoji': emoji, 'label': label, 'emotion': emotion};
  }
}

// Example usage to convert your list of maps to a list of EmojiEmotion objects:
final List<Map<String, dynamic>> rawEmojiEmotions = [
  {
    'emoji': '😔',
    'label': 'Bad',
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
