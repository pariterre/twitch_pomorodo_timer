import 'package:common_lib/providers/app_preferences.dart';
import 'package:common_lib/providers/participants.dart';
import 'package:common_lib/providers/pomodoro_status.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitch_procastinator_puncher/screens/main_screen.dart';

void main() async {
  final appPreferences = await AppPreferences.factory();
  final participants = await Participants.factory(
      mustFollowForFaming: appPreferences.mustFollowForFaming.value,
      whitelist: appPreferences.textWhitelist.text,
      blacklist: appPreferences.textBlacklist.text);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => appPreferences),
      ChangeNotifierProvider(create: (context) => participants),
      ChangeNotifierProvider(
          create: (context) => PomodoroStatus(
              sessionHasFinishedCallback:
                  participants.addPomodoroToAllConnected)),
    ],
    child: MaterialApp(
      initialRoute: MainScreen.route,
      routes: {
        MainScreen.route: (ctx) => const MainScreen(),
      },
    ),
  ));
}
