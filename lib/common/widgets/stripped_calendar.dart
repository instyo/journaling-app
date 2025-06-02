import 'package:flutter/material.dart';
import 'package:journaling/core/utils/context_extension.dart';

class CalendarStrip extends StatefulWidget {
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
  State<StatefulWidget> createState() => _CalendarStripState();
}

class _CalendarStripState extends State<CalendarStrip>
    with AutomaticKeepAliveClientMixin {
  int selectedIndex = 0;
  List<DateTime> dates = [];
  final controller = ScrollController();
  final days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  @override
  void initState() {
    super.initState();
    final int range = 365; // total number of days for the last year
    final DateTime today = DateTime.now();
    final DateTime startDate = today.subtract(
      Duration(days: range - 1),
    ); // Start date is one year ago

    dates =
        List.generate(range, (index) {
              return startDate.add(Duration(days: index));
            })
            .where((date) => date.isBefore(today.add(Duration(days: 1))))
            .toList(); // Ensure dates do not exceed today

    final int initialIndex = dates.indexOf(today);

    setState(() {
      selectedIndex = initialIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.animateTo(
          controller.position.maxScrollExtent,
          duration: Duration(milliseconds: 200),
          curve: Curves.bounceIn,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SizedBox(
      height: 60,
      child: ListView.builder(
        // shrinkWrap: true,
        key: PageStorageKey(
          0,
        ), //0 is Store index you should use a new one for each page you can also use string
        controller: controller,
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        physics: ClampingScrollPhysics(),

        itemBuilder: (context, index) {
          final date = dates[index];
          final dayName = days[date.weekday - 1];
          final isSelected = index == selectedIndex;

          return GestureDetector(
            key: ValueKey(DateTime.now().toIso8601String()),
            onTap: () {
              setState(() {
                selectedIndex = index;
              });

              if (widget.onDateSelected != null) {
                widget.onDateSelected!(date);
              }
            },
            child: Container(
              width: 50,
              margin: EdgeInsets.symmetric(horizontal: 4),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? context.cardColor : context.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(dayName, style: context.textTheme.bodySmall),
                  SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
