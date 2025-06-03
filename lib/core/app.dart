import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:journaling/features/auth/cubit/auth_cubit.dart';
import 'package:journaling/features/auth/data/auth_repository.dart';
import 'package:journaling/features/auth/presentation/login_screen.dart';
import 'package:journaling/features/feeling/presentation/feeling_selection_screen.dart';
import 'package:journaling/features/journal/cubit/journal_cubit.dart';
import 'package:journaling/features/journal/data/journal_repository.dart';
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
        RepositoryProvider(create: (context) => JournalRepository()),
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
                (context) => JournalCubit(context.read<JournalRepository>()),
          ),
          BlocProvider(
            create: (context) => UserCubit(context.read<UserRepository>()),
          ),
          BlocProvider(
            create: (context) => StatsCubit(context.read<JournalRepository>()),
          ),
        ],
        child: Builder(
          builder: (context) {
            final themeMode = context.watch<ThemeCubit>().state;
            return MaterialApp(
              title: 'Mood Journal',
              debugShowCheckedModeBanner: false,
              theme: FlexThemeData.light(scheme: FlexScheme.greenM3),
              darkTheme: FlexThemeData.dark(scheme: FlexScheme.greenM3),
              // theme: AppThemes.lightTheme.copyWith(
              //   textTheme: GoogleFonts.poppinsTextTheme(textTheme).copyWith(
              //     bodyLarge: textTheme.bodyLarge?.copyWith(color: Colors.black),
              //     bodyMedium: textTheme.bodyMedium?.copyWith(
              //       color: Colors.black,
              //     ),
              //     bodySmall: textTheme.bodySmall?.copyWith(color: Colors.black),
              //     headlineLarge: textTheme.headlineLarge?.copyWith(
              //       color: Colors.black,
              //     ),
              //     headlineMedium: textTheme.headlineMedium?.copyWith(
              //       color: Colors.black,
              //     ),
              //     headlineSmall: textTheme.headlineSmall?.copyWith(
              //       color: Colors.black,
              //     ),
              //     titleLarge: textTheme.titleLarge?.copyWith(
              //       color: Colors.black,
              //     ),
              //     titleMedium: textTheme.titleMedium?.copyWith(
              //       color: Colors.black,
              //     ),
              //     titleSmall: textTheme.titleSmall?.copyWith(
              //       color: Colors.black,
              //     ),
              //     labelLarge: textTheme.labelLarge?.copyWith(
              //       color: Colors.black,
              //     ),
              //     labelMedium: textTheme.labelMedium?.copyWith(
              //       color: Colors.black,
              //     ),
              //     labelSmall: textTheme.labelSmall?.copyWith(
              //       color: Colors.black,
              //     ),
              //   ),
              // ),
              // darkTheme: AppThemes.darkTheme.copyWith(
              //   textTheme: GoogleFonts.poppinsTextTheme(textTheme).copyWith(
              //     bodyLarge: textTheme.bodyLarge?.copyWith(color: Colors.white),
              //     bodyMedium: textTheme.bodyMedium?.copyWith(
              //       color: Colors.white,
              //     ),
              //     bodySmall: textTheme.bodySmall?.copyWith(color: Colors.white),
              //     headlineLarge: textTheme.headlineLarge?.copyWith(
              //       color: Colors.white,
              //     ),
              //     headlineMedium: textTheme.headlineMedium?.copyWith(
              //       color: Colors.white,
              //     ),
              //     headlineSmall: textTheme.headlineSmall?.copyWith(
              //       color: Colors.white,
              //     ),
              //     titleLarge: textTheme.titleLarge?.copyWith(
              //       color: Colors.white,
              //     ),
              //     titleMedium: textTheme.titleMedium?.copyWith(
              //       color: Colors.white,
              //     ),
              //     titleSmall: textTheme.titleSmall?.copyWith(
              //       color: Colors.white,
              //     ),
              //     labelLarge: textTheme.labelLarge?.copyWith(
              //       color: Colors.white,
              //     ),
              //     labelMedium: textTheme.labelMedium?.copyWith(
              //       color: Colors.white,
              //     ),
              //     labelSmall: textTheme.labelSmall?.copyWith(
              //       color: Colors.white,
              //     ),
              //   ),
              // ),
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
