import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:journaling/core/utils/env.dart';
import 'package:journaling/features/auth/cubit/auth_cubit.dart';

extension BuildContextX on BuildContext {
  Color get primaryColor => Theme.of(this).primaryColor;

  Color get backgroundColor => Theme.of(this).scaffoldBackgroundColor;

  Color get cardColor =>
      Theme.of(this).brightness == Brightness.dark
          ? Theme.of(this).cardColor
          : primaryColor.withOpacity(0.15);

  Color get cardColor2 =>
      Theme.of(this).brightness == Brightness.dark
          ? Color(0xff2a2a2a)
          : Color(0xFFF0F5ED);

  Color get white =>
      Theme.of(this).brightness == Brightness.dark
          ? Color(0xff2a2a2a)
          : Color(0xffffffff);

  Color get subtextColor =>
      Theme.of(this).brightness == Brightness.dark
          ? Colors.white
          : Colors.grey[800]!;

  TextTheme get textTheme => Theme.of(this).textTheme;

  String get userId =>
      Env.kLocalDb
          ? ''
          : read<AuthCubit>().state is Authenticated
          ? (read<AuthCubit>().state as Authenticated).user.uid
          : 'unknown'; // Fallback, should not happen if auth is handled
}
