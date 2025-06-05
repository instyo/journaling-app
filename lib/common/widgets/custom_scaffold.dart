import 'package:flutter/material.dart';

class CustomScaffold extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  final Widget body;
  final Widget? fab;
  final FloatingActionButtonLocation? fabLocation;
  final FloatingActionButtonAnimator? fabAnimator;

  const CustomScaffold({
    super.key,
    this.title = "",
    this.actions = const [],
    required this.body,
    this.fab,
    this.fabLocation,
    this.fabAnimator,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(title: Text(title), actions: actions),
        body: SizedBox.expand(
          child: Container(margin: EdgeInsets.all(8), child: body),
        ),
        floatingActionButton: fab,
        floatingActionButtonLocation: fabLocation,
        floatingActionButtonAnimator: fabAnimator,
      ),
    );
  }
}
