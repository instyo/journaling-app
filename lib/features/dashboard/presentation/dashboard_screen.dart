import 'package:flutter/material.dart';
import 'package:journaling/features/journal/presentation/journal_list_screen.dart';
import 'package:journaling/features/stats/presentation/stats_screen.dart';
import 'package:journaling/features/user/presentation/settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static void open(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [JournalListScreen(), StatsScreen(), SettingsScreen()],
              ),
            ),
            TabBar(
              labelPadding: EdgeInsets.only(bottom: 42),
              tabs: [
                Tab(icon: Icon(Icons.home)),
                Tab(icon: Icon(Icons.stacked_bar_chart)),
                Tab(icon: Icon(Icons.settings)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
