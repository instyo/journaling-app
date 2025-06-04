import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:journaling/core/utils/context_extension.dart';
import 'package:journaling/features/auth/cubit/auth_cubit.dart';
import 'package:journaling/features/auth/data/auth_repository.dart';
import 'package:journaling/features/auth/presentation/login_screen.dart';
import 'package:journaling/features/auth/presentation/signup_screen.dart';
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
                  return SignInPage();
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

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ListView(
            children: [
              const SizedBox(height: 40),
              Text('Sign in to', style: context.textTheme.displaySmall),
              Text(
                'Mood Journal 😊',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),

              // Email Field
              TextField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Type here....',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Password Field
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Type here....',
                  suffixIcon: Icon(Icons.visibility_off),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Sign In Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {},
                child: Text(
                  'Sign in',
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // OR Divider
              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or continue with'),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 20),

              // Social Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialButton('assets/images/fb.png'),
                  const SizedBox(width: 16),
                  _socialButton('assets/images/google.png'),
                  const SizedBox(width: 16),
                  _socialButton('assets/images/apple.png'),
                ],
              ),
              const SizedBox(height: 30),

              // Sign up Prompt
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SignupScreen()),
                    );
                    },
                    child: Text(
                      'Sign up',
                      style: TextStyle(
                        color: context.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _socialButton(String assetPath) {
    return Container(
      width: 50,
      height: 50,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Image.asset(assetPath),
    );
  }
}
