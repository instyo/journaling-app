import 'package:flutter_bloc/flutter_bloc.dart';

class CalendarPickerCubit extends Cubit<DateTime> {
  CalendarPickerCubit() : super(DateTime.now());

  void selectDate(DateTime date) {
    emit(date);
  }
}

