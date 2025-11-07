import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/dark_mode_provider/dark_mode_notifier.dart';


/*
* This is the provider of dark mode
* It accepts a DarkModeNotifier and returns a boolean
*
* */
final darkModeProvider = NotifierProvider<DarkModeNotifier, bool>(
  DarkModeNotifier.new
);