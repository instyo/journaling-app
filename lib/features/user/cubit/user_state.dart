part of 'user_cubit.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserProfileLoading extends UserState {}

class UserProfileLoaded extends UserState {
  final AppUser user;
  const UserProfileLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class UserProfileNotFound extends UserState {
  // This state is useful if a user logs in via Auth, but their Firestore profile
  // document hasn't been created yet.
}

class UserProfileError extends UserState {
  final String message;
  const UserProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileUpdateSuccess extends UserState {
  final AppUser user; // Return the updated user info
  const ProfileUpdateSuccess(this.user);
  @override
  List<Object?> get props => [user];
}
