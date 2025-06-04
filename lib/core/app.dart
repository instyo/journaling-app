import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:journaling/features/auth/cubit/auth_cubit.dart';
import 'package:journaling/features/auth/data/auth_repository.dart';
import 'package:journaling/features/auth/presentation/login_screen.dart';
import 'package:journaling/features/feeling/presentation/feeling_selection_screen.dart';
import 'package:journaling/features/journal/cubit/journal_cubit.dart';
import 'package:journaling/features/journal/data/firebase_journal_repository.dart';
import 'package:journaling/features/settings/cubit/settings_cubit.dart';
import 'package:journaling/features/stats/cubit/stats_cubit.dart';
import 'package:journaling/features/stats/data/stats_repository.dart';
import 'package:journaling/features/user/cubit/user_cubit.dart';
import 'package:journaling/features/user/data/user_repository.dart';
import '../core/theme/theme_cubit.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthRepository()),
        RepositoryProvider(create: (context) => FirebaseJournalRepository()),
        RepositoryProvider(create: (context) => UserRepository()),
        RepositoryProvider(create: (context) => StatsRepository()), // ADD THIS
        // Add StatsRepository here
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => ThemeCubit()),
          BlocProvider(
            create: (context) => AuthCubit(context.read<AuthRepository>()),
          ),
          BlocProvider(
            create:
                (context) =>
                    JournalCubit(context.read<FirebaseJournalRepository>()),
          ),
          BlocProvider(
            create: (context) => UserCubit(context.read<UserRepository>()),
          ),
          BlocProvider(
            create:
                (context) =>
                    StatsCubit(context.read<FirebaseJournalRepository>()),
          ),
          BlocProvider(create: (context) => SettingsCubit()),
        ],
        child: Builder(
          builder: (context) {
            final themeMode = context.watch<ThemeCubit>().state;
            return MaterialApp(
              title: 'Mood Journal',
              debugShowCheckedModeBanner: false,
              theme: FlexThemeData.light(scheme: FlexScheme.damask),
              darkTheme: FlexThemeData.dark(scheme: FlexScheme.damask),
              themeMode: themeMode,
              home: BlocBuilder<AuthCubit, AuthState>(
                builder: (context, authState) {
                  if (authState is Authenticated) {
                    // Consider a SplashScreen to fetch user profile, etc.
                    // return const JournalListScreen(); // Your app's main screen
                    return FeelingSelectionScreen();
                  } else {
                    return const LoginScreen(); // Or splash screen leading to login
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
