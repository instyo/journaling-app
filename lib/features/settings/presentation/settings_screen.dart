// lib/features/settings/presentation/settings_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:journaling/core/theme/theme_cubit.dart';
import 'package:journaling/features/auth/cubit/auth_cubit.dart';
import 'package:journaling/features/auth/presentation/login_screen.dart';
import 'package:journaling/features/settings/presentation/ai_configuration_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../cubit/settings_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  String formatDurationHM(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    String result = '';
    if (hours > 0) {
      result += '${hours}h ';
    }
    if (minutes > 0) {
      result += '${minutes}m';
    }
    // Optional: handle zero duration
    if (result.isEmpty) {
      result = '0m';
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          final cubit = context.read<SettingsCubit>();
          return Column(
            children: [
              BlocBuilder<ThemeCubit, ThemeMode>(
                builder: (context, state) {
                  return SwitchListTile(
                    title: Text('Dark Theme'),
                    value: state == ThemeMode.dark,
                    onChanged: (value) {
                      context.read<ThemeCubit>().setThemeMode(
                        value ? ThemeMode.dark : ThemeMode.light,
                      );
                    },
                  );
                },
              ),
              ScheduleNotificationTile(
                title: 'Hourly Reminder',
                value:
                    'Notified every ${formatDurationHM(state.hourlyDuration ?? Duration.zero)}',
                enabled: state.hourly,
                onChanged: (val) async {
                  if (state.hourly) {
                    cubit.toggleHourly(false, duration: Duration.zero);
                    return;
                  }

                  final Duration? selectedDuration = await showDialog(
                    context: context,
                    builder: (_) {
                      return DurationPickerDialog(
                        initialTime: state.hourlyDuration ?? Duration.zero,
                      );
                    },
                  );

                  if (selectedDuration != null) {
                    cubit.toggleHourly(true, duration: selectedDuration);
                  }
                },
              ),
              ScheduleNotificationTile(
                title: 'Daily Reminder',
                value:
                    "Every day at ${DateFormat.Hm().format(state.dailyTime ?? DateTime.now())}",
                enabled: state.daily,
                onChanged: (value) async {
                  if (state.daily) {
                    cubit.toggleDaily(false);
                    return;
                  }

                  final DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                  );

                  if (selectedDate != null) {
                    TimeOfDay? selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );

                    if (selectedTime != null) {
                      final scheduledTime = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );

                      cubit.toggleDaily(true, time: scheduledTime);
                    } else {
                      cubit.toggleDaily(false);
                    }
                  }
                },
              ),
              SwitchListTile(
                title: Text('Enable AI'),
                subtitle: Text('Use AI to generate journal title'),
                value: state.useAI,
                onChanged: (value) async {
                  if (value) {
                    final result = await showDialog(
                      context: context,
                      builder: (context) {
                        return AIConfigurationScreen();
                      },
                    );

                    if (result != null) {
                      final (url, token, model) = result;
                      // Save to SharedPreferences
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('api_url', url);
                      await prefs.setString('api_token', token);
                      await prefs.setString('model', model);
                      cubit.toggleAI(true);
                    } else {
                      // If canceled, set the toggle back to false
                      cubit.toggleAI(false);
                    }
                  } else {
                    cubit.toggleAI(false);
                    // Remove saved values from SharedPreferences
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('api_url');
                    await prefs.remove('api_token');
                    await prefs.remove('model');
                  }
                },
              ),
              ListTile(
                title: Text("Sign Out"),
                trailing: Icon(Icons.login),
                iconColor: Colors.red,
                textColor: Colors.red,
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Confirm Sign Out"),
                        content: Text("Are you sure you want to sign out?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text("Sign Out"),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirm == true) {
                    context.read<AuthCubit>().signOut();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class ScheduleNotificationTile extends StatelessWidget {
  final String title;
  final String value;
  final bool enabled;
  final Function(bool)? onChanged;

  const ScheduleNotificationTile({
    super.key,
    required this.title,
    required this.value,
    required this.enabled,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title),
      subtitle: !enabled ? null : Text(value),
      value: enabled,
      onChanged: onChanged,
    );
  }
}
