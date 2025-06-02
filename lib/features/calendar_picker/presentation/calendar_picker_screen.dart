import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:journaling/features/calendar_picker/bloc/calendar_picker_bloc.dart';

class CalendarStrip extends StatelessWidget {
  final int range; // Number of days to display
  final Function(DateTime)? onDateSelected;
  final int? initialDate;

  const CalendarStrip({
    super.key,
    this.range = 28,
    this.onDateSelected,
    this.initialDate,
  });

  @override
  Widget build(BuildContext context) {
    final List<DateTime> dates =
        List.generate(range, (index) {
              final DateTime today = DateTime.now();
              final DateTime startDate = today.subtract(
                Duration(days: range - 1),
              );
              return startDate.add(Duration(days: index));
            })
            .where(
              (date) => date.isBefore(DateTime.now().add(Duration(days: 1))),
            )
            .toList();

    return BlocBuilder<CalendarPickerCubit, DateTime>(
      builder: (context, selectedDate) {
        return SizedBox(
          height: 80,
          child: ListView.builder(
            controller: ScrollController(),
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            physics: ClampingScrollPhysics(),
            itemBuilder: (context, index) {
              final date = dates[index];
              final dayName =
                  [
                    'MON',
                    'TUE',
                    'WED',
                    'THU',
                    'FRI',
                    'SAT',
                    'SUN',
                  ][date.weekday - 1];
              
              final isSelected = date == selectedDate;

              print(">> IS SELECTED : ${isSelected}");

              return GestureDetector(
                onTap: () {
                  context.read<CalendarPickerCubit>().selectDate(date);
                  
                  if (onDateSelected != null) {
                    onDateSelected!(date);
                  }
                },
                child: Container(
                  width: 60,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? Theme.of(context).primaryColor.withOpacity(0.25)
                            : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
