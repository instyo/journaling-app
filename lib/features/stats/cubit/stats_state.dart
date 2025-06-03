part of 'stats_cubit.dart';

class StatsState extends Equatable {
  final List<JournalEntry> journals;
  final String errorMessage;
  final StateStatus status;

  const StatsState({
    this.journals = const [],
    this.errorMessage = '',
    this.status = StateStatus.idle, // Initialized status
  });

  StatsState copyWith({
    List<JournalEntry>? journals,
    String? errorMessage,
    StateStatus? status, // Added status to copyWith
  }) {
    return StatsState(
      journals: journals ?? this.journals,
      errorMessage: errorMessage ?? this.errorMessage,
      status: status ?? this.status, // Updated status in copyWith
    );
  }

  @override
  List<Object?> get props => [journals, errorMessage, status]; // Added status to props
}
// abstract class StatsState extends Equatable {
//   const StatsState();

//   @override
//   List<Object?> get props => [];
// }

// class JournalInitial extends StatsState {}

// class JournalLoading extends StatsState {}

// class JournalDateFilter extends StatsState {
//   final DateTime date;

//   const JournalDateFilter(this.date);

//   @override
//   List<Object?> get props => [date];
// }

// class JournalsLoaded extends StatsState {
//   final List<JournalEntry> journals;
//   const JournalsLoaded(this.journals);

//   @override
//   List<Object?> get props => [journals];
// }

// class JournalError extends StatsState {
//   final String message;
//   const JournalError(this.message);

//   @override
//   List<Object?> get props => [message];
// }

// // You might also want states for individual journal operations
// // class JournalCreatedSuccess extends StatsState {}
// // class JournalUpdatedSuccess extends StatsState {}
// // class JournalDeletedSuccess extends StatsState {}
