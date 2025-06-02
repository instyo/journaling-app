part of 'journal_cubit.dart';

class JournalState extends Equatable {
  final DateTime? filterDate;
  final List<JournalEntry> journals;
  final String errorMessage;
  final StateStatus status;

  const JournalState({
    this.filterDate,
    this.journals = const [],
    this.errorMessage = '',
    this.status = StateStatus.idle, // Initialized status
  });

  JournalState copyWith({
    DateTime? filterDate,
    List<JournalEntry>? journals,
    String? errorMessage,
    StateStatus? status, // Added status to copyWith
  }) {
    return JournalState(
      filterDate: filterDate ?? this.filterDate,
      journals: journals ?? this.journals,
      errorMessage: errorMessage ?? this.errorMessage,
      status: status ?? this.status, // Updated status in copyWith
    );
  }

  @override
  List<Object?> get props => [filterDate, journals, errorMessage, status]; // Added status to props
}
// abstract class JournalState extends Equatable {
//   const JournalState();

//   @override
//   List<Object?> get props => [];
// }

// class JournalInitial extends JournalState {}

// class JournalLoading extends JournalState {}

// class JournalDateFilter extends JournalState {
//   final DateTime date;

//   const JournalDateFilter(this.date);

//   @override
//   List<Object?> get props => [date];
// }

// class JournalsLoaded extends JournalState {
//   final List<JournalEntry> journals;
//   const JournalsLoaded(this.journals);

//   @override
//   List<Object?> get props => [journals];
// }

// class JournalError extends JournalState {
//   final String message;
//   const JournalError(this.message);

//   @override
//   List<Object?> get props => [message];
// }

// // You might also want states for individual journal operations
// // class JournalCreatedSuccess extends JournalState {}
// // class JournalUpdatedSuccess extends JournalState {}
// // class JournalDeletedSuccess extends JournalState {}
