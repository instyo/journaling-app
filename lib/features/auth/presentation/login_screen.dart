import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:journaling/features/auth/cubit/auth_cubit.dart';
import 'package:journaling/features/auth/presentation/email_login_screen.dart';
import 'package:journaling/features/auth/presentation/signup_screen.dart';
import 'package:journaling/features/feeling/presentation/feeling_selection_screen.dart';
import 'package:journaling/features/user/cubit/user_cubit.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to Mood Journal'),
        centerTitle: true,
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            // Once authenticated, ensure user profile is initialized
            context.read<UserCubit>().initializeUserProfile(
              state.user.uid,
              state.user.email ?? '', // Fallback for email
              state.user.displayName ?? 'New User', // Fallback for name
            );
            // Navigate to main app screen. Using pushReplacement to prevent going back to login.
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const FeelingSelectionScreen()),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Login Failed: ${state.message}')),
            );
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Sign in to start journaling your moods.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  if (state is AuthLoading) {
                    return const CircularProgressIndicator();
                  }
                  return ElevatedButton.icon(
                    onPressed:
                        () => context.read<AuthCubit>().signInWithGoogle(),
                    icon: Image.asset(
                      'assets/images/google_logo.png', // You'll need to add a Google logo image
                      height: 24.0,
                      width: 24.0,
                    ),
                    label: const Text('Sign in with Google'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      textStyle: const TextStyle(fontSize: 18),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: const BorderSide(color: Colors.grey),
                      ),
                    ),
                  );
                },
              ),
              // Add other social login buttons here (e.g., Facebook, Apple)
              // Add a login with email/password option
              const SizedBox(height: 24),
              const Text(
                '- OR -',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Email and Password fields could go here, or on a separate 'Login with Email' screen.
              // For simplicity, let's add a button to navigate to email/password login/signup.
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const EmailLoginScreen()),
                  );
                },
                child: const Text(
                  'Login with Email',
                ), // More robust if you add a specific screen
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SignupScreen()),
                  );
                },
                child: const Text('Don\'t have an account? Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
