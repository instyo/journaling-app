import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:journaling/core/utils/env.dart';
import 'package:journaling/features/auth/cubit/auth_cubit.dart';
import 'package:journaling/features/auth/data/auth_repository.dart';
import 'package:journaling/features/auth/presentation/login_screen.dart';
import 'package:journaling/features/feeling/presentation/feeling_selection_screen.dart';
import 'package:journaling/features/journal/cubit/journal_cubit.dart';
import 'package:journaling/features/journal/data/firebase_journal_repository.dart';
import 'package:journaling/features/journal/data/journal_repository.dart';
import 'package:journaling/features/journal/data/local_journal_repository.dart';
import 'package:journaling/features/settings/cubit/settings_cubit.dart';
import 'package:journaling/features/stats/cubit/stats_cubit.dart';
import 'package:journaling/features/user/cubit/user_cubit.dart';
import 'package:journaling/features/user/data/user_repository.dart';
import '../core/theme/theme_cubit.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<dynamic> localProviders = [
    RepositoryProvider(create: (context) => LocalJournalRepository()),
  ];

  List<dynamic> firebaseProviders = [
    RepositoryProvider(create: (context) => FirebaseJournalRepository()),
    RepositoryProvider(create: (context) => AuthRepository()),
    RepositoryProvider(create: (context) => UserRepository()),
  ];

  List<dynamic> localBlocs = [
    BlocProvider(create: (context) => ThemeCubit()),
    BlocProvider(
      create: (context) => JournalCubit(context.read<LocalJournalRepository>()),
    ),
    BlocProvider(
      create: (context) => StatsCubit(context.read<LocalJournalRepository>()),
    ),
    BlocProvider(create: (context) => SettingsCubit()),
  ];

  List<dynamic> firebaseBlocs = [
    BlocProvider(create: (context) => ThemeCubit()),
    BlocProvider(
      create: (context) => AuthCubit(context.read<AuthRepository>()),
    ),
    BlocProvider(
      create: (context) => JournalCubit(context.read<FirebaseJournalRepository>()),
    ),
    BlocProvider(
      create: (context) => StatsCubit(context.read<FirebaseJournalRepository>()),
    ),
    BlocProvider(create: (context) => SettingsCubit()),
    BlocProvider(
      create: (context) => UserCubit(context.read<UserRepository>()),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [...(Env.kLocalDb ? localProviders : firebaseProviders)],
      child: MultiBlocProvider(
        providers: [...(Env.kLocalDb ? localBlocs : firebaseBlocs)],
        child: Builder(
          builder: (context) {
            final themeMode = context.watch<ThemeCubit>().state;
            return MaterialApp(
              title: 'Mood Journal',
              debugShowCheckedModeBanner: false,
              theme: FlexThemeData.light(scheme: FlexScheme.damask),
              darkTheme: FlexThemeData.dark(scheme: FlexScheme.damask),
              themeMode: themeMode,
              home:
                  Env.kLocalDb
                      ? const FeelingSelectionScreen()
                      : BlocBuilder<AuthCubit, AuthState>(
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
