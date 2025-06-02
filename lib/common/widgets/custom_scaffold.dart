import 'package:flutter/material.dart';

class CustomScaffold extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  final Widget body;

  const CustomScaffold({
    super.key,
    this.title = "",
    this.actions = const [],
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: SizedBox.expand(
        child: Container(margin: EdgeInsets.all(8), child: body),
      ),
    );
  }
}
