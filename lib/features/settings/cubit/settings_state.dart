part of 'settings_cubit.dart';

class SettingsState {
  final bool isDarkTheme;
  final bool hourly;
  final Duration? hourlyDuration;
  final bool daily;
  final DateTime? dailyTime;
  final bool useAI;

  SettingsState({
    this.isDarkTheme = false,
    this.hourly = false,
    this.hourlyDuration,
    this.daily = false,
    this.dailyTime,
    this.useAI = false,
  });

  SettingsState copyWith({
    bool? isDarkTheme,
    bool? hourly,
    Duration? hourlyDuration,
    bool? daily,
    DateTime? dailyTime,
    bool? useAI,
  }) {
    return SettingsState(
      isDarkTheme: isDarkTheme ?? this.isDarkTheme,
      hourly: hourly ?? this.hourly,
      hourlyDuration: hourlyDuration ?? this.hourlyDuration,
      daily: daily ?? this.daily,
      dailyTime: dailyTime ?? this.dailyTime,
      useAI: useAI ?? this.useAI,
    );
  }
}
