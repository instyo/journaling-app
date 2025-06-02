enum Mood {
  bad(emoji: '😔'),
  meh(emoji: '😔'),
  okay(emoji: '😠'),
  good(emoji: '🧘‍♀️'),
  great(emoji: '😨');

  final String emoji;
  const Mood({required this.emoji});
}
