import 'package:bloc/bloc.dart';
import 'package:journaling/core/utils/notification_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
part 'settings_state.dart';

// lib/features/settings/cubit/settings_cubit.dart

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(SettingsState()) {
    _loadSettings();
  }

  void toggleTheme() {
    emit(state.copyWith(isDarkTheme: !state.isDarkTheme));
  }

  void toggleHourly(bool enabled, {required Duration duration}) {
    emit(state.copyWith(hourly: enabled, hourlyDuration: duration));
    _saveSettings();

    if (enabled) {
      NotificationService().scheduleHourlyNotification(interval: duration);
    } else {
      NotificationService().cancelNotification(100);
    }
  }

  void toggleAI(bool enabled) {
    emit(state.copyWith(useAI: enabled));
    _saveSettings();
  }

  void toggleDaily(bool enabled, {DateTime? time}) {
    emit(state.copyWith(daily: enabled, dailyTime: time));
    _saveSettings();

    if (enabled && time != null) {
      NotificationService().scheduleDailyNotification(time);
    } else {
      NotificationService().cancelNotification(101);
    }
  }

  void _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', state.isDarkTheme);
    await prefs.setBool('hourly', state.hourly);
    await prefs.setInt(
      'hourlyDuration',
      state.hourlyDuration?.inMilliseconds ?? 0,
    );
    await prefs.setBool('daily', state.daily);
    await prefs.setString(
      'dailyTime',
      state.dailyTime?.toIso8601String() ?? '',
    );
    await prefs.setBool('useAI', state.useAI);
  }

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
    final hourly = prefs.getBool('hourly') ?? false;
    final hourlyDuration = Duration(
      milliseconds: prefs.getInt('hourlyDuration') ?? 1,
    );
    final daily = prefs.getBool('daily') ?? false;
    final dailyTime = DateTime.parse(
      prefs.getString('dailyTime') ?? DateTime.now().toString(),
    );
    final useAI =
        prefs.getBool('useAI') ?? false; // Load useAI from SharedPreferences

    emit(
      state.copyWith(
        isDarkTheme: isDarkTheme,
        hourly: hourly,
        hourlyDuration: hourlyDuration,
        daily: daily,
        dailyTime: dailyTime,
        useAI: useAI, // Include useAI in the state
      ),
    );
  }
}
