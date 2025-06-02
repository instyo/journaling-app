part of 'stats_cubit.dart';

abstract class StatsState extends Equatable {
  const StatsState();

  @override
  List<Object?> get props => [];
}

class StatsInitial extends StatsState {}

class StatsLoading extends StatsState {}

class StatsLoaded extends StatsState {
  final Map<Mood, int> moodCounts;
  // You might add date ranges here too if the UI allows selection
  // final DateTime? startDate;
  // final DateTime? endDate;

  const StatsLoaded({required this.moodCounts});

  @override
  List<Object?> get props => [moodCounts]; // Add startDate, endDate if applicable
}

class StatsError extends StatsState {
  final String message;
  const StatsError(this.message);

  @override
  List<Object?> get props => [message];
}