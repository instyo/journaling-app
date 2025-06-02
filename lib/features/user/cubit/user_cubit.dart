import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/user_repository.dart';
import '../models/app_user.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final UserRepository _userRepository;

  UserCubit(this._userRepository) : super(UserInitial()) {
    _userRepository.getUserProfile().listen(
      (user) {
        if (user != null) {
          emit(UserProfileLoaded(user));
        } else {
          emit(
            UserProfileNotFound(),
          ); // User profile not created yet or logged out
        }
      },
      onError: (e) {
        emit(UserProfileError(e.toString()));
      },
    );
  }

  Future<void> updateProfile({
    String? name,
    String? username,
    String? description,
    File? profilePic,
  }) async {
    if (state is! UserProfileLoaded)
      return; // Can only update if a profile exists
    final currentUserState = state as UserProfileLoaded;
    AppUser updatedUser = currentUserState.user.copyWith(
      name: name,
      username: username,
      description: description,
    );

    emit(UserProfileLoading());
    try {
      if (profilePic != null) {
        final imageUrl = await _userRepository.uploadProfilePicture(
          profilePic.path,
        );
        updatedUser = updatedUser.copyWith(profilePictureUrl: imageUrl);
      }
      await _userRepository.saveUserProfile(updatedUser);
      // State will automatically update via stream listener
    } catch (e) {
      emit(UserProfileError('Failed to update profile: $e'));
      emit(currentUserState); // Revert to previous state on error
    }
  }

  // This would be called immediately after social sign-in if no user profile exists
  Future<void> initializeUserProfile(
    String uid,
    String email,
    String displayName,
  ) async {
    // Only initialize if no profile currently exists
    if (state is! UserProfileNotFound && state is! UserInitial) return;
    emit(UserProfileLoading());
    try {
      final newUser = AppUser(uid: uid, email: email, name: displayName);
      await _userRepository.saveUserProfile(newUser);
    } catch (e) {
      emit(UserProfileError('Failed to initialize user profile: $e'));
      // Keep emitting previous state or fallback to UserProfileNotFound
    }
  }
}
