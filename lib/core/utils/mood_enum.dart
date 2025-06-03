enum MoodEnum {
  unknown("", "Unknown", "#ffffff", -1),
  sad("😥", "Sad", "#EA2F14", 1),
  meh("☹️", "Meh", "#FB9E3A", 2),
  okay("😐", "Okay", "#FCEF91", 3),
  nice("😊", "Nice", "#F0F2BD", 4),
  great("🤩", "Great", "#B2CD9C", 5);

  final String emoji;
  final String label;
  final String color;
  final int value;

  const MoodEnum(this.emoji, this.label, this.color, this.value);
}

extension MoodEnumX on MoodEnum {
  List<String> get feelings {
    final result = rawFeelings.firstWhere((e) => e['value'] == value);
    return result['feelings'];
  }

  String get moodLabel => '$emoji ($label)';

  List<MoodEnum> get lists => MoodEnum.values.sublist(1, 6);
}

// Example usage to convert your list of maps to a list of EmojiEmotion objects:
final List<Map<String, dynamic>> rawFeelings = [
  {
    'feelings': [
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
    'value': 1,
  },
  {
    'feelings': [
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
    'value': 2,
  },
  {
    'feelings': [
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
    'value': 3,
  },
  {
    'feelings': [
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
    'value': 4,
  },
  {
    'feelings': [
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
    'value': 5,
  },
];
