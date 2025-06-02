import 'package:bloc/bloc.dart';
// ignore: depend_on_referenced_packages
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../data/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(AuthInitial()) {
    _authRepository.user.listen((user) {
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    });
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    try {
      if (kIsWeb) {
        await _authRepository.signInWithGoogleWeb();
      } else {
        await _authRepository.signInWithGoogle();
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated()); // Revert to unauthenticated on error
    }
  }

  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
    } catch (_) {} // Errors during sign out can often be ignored
  }

  // NEW: Sign Up with Email & Password
  Future<void> signUp(String email, String password) async {
    emit(AuthLoading());
    try {
      await _authRepository.signUpWithEmailAndPassword(email, password);
      // State change to Authenticated handled by stream listener
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  // NEW: Sign In with Email & Password
  Future<void> signInEmail(String email, String password) async {
    emit(AuthLoading());
    try {
      await _authRepository.signInWithEmailAndPassword(email, password);
      // State change to Authenticated handled by stream listener
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }
}
