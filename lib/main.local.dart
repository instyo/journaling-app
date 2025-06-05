import 'package:flutter/material.dart';
import 'package:journaling/core/app.dart';
import 'package:journaling/core/utils/env.dart';
import 'package:journaling/core/utils/notification_utils.dart';
import 'package:journaling/core/utils/sembast_service.dart';

void main() async {
  Env.kLocalDb = true;
  WidgetsFlutterBinding.ensureInitialized();
  await SembastService().init();
  await NotificationService().init();
  runApp(const MyApp()); // Your main app widget
}

