import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:twitch_pomorodo_timer/common/config.dart';

String _path(Directory directory, String filename) =>
    '${directory.path}/$filename';

String get rootPath => Platform.isWindows ? r'C:\' : '/';

class AppPreferences with ChangeNotifier {
  // Path to save data folder and file
  final Directory preferencesDirectory;
  String get _preferencesPath =>
      _path(preferencesDirectory, preferencesFilename);
  Directory _lastVisitedDirectory = Directory('');
  Directory get lastVisitedDirectory => _lastVisitedDirectory;

  // Number of total session
  int _nbSessions;
  int get nbSessions => _nbSessions;
  set nbSessions(int value) {
    _nbSessions = value;
    notifyListeners();
    save();
  }

  // Session time
  Duration _sessionDuration;
  Duration get sessionDuration => _sessionDuration;
  set sessionDuration(Duration value) {
    _sessionDuration = value;
    notifyListeners();
    save();
  }

  // Pause time
  Duration _pauseDuration;
  Duration get pauseDuration => _pauseDuration;
  set pauseDuration(Duration value) {
    _pauseDuration = value;
    notifyListeners();
    save();
  }

  // Background image during the countdown
  String? _activeBackgroundImageFilename;
  String? get activeBackgroundImagePath =>
      _activeBackgroundImageFilename == null
          ? null
          : _path(preferencesDirectory, _activeBackgroundImageFilename!);
  Future<void> setActiveBackgroundImagePath(String? value) async {
    if (value == null) {
      _activeBackgroundImageFilename = null;
    } else {
      _activeBackgroundImageFilename = await _copyFile(original: value);
    }
    notifyListeners();
    save();
  }

  // Background image during the pause
  String? _pauseBackgroundImageFilename;
  String? get pauseBackgroundImagePath => _pauseBackgroundImageFilename == null
      ? null
      : _path(preferencesDirectory, _pauseBackgroundImageFilename!);
  Future<void> setPauseBackgroundImagePath(String? value) async {
    if (value == null) {
      _pauseBackgroundImageFilename = null;
    } else {
      _pauseBackgroundImageFilename = await _copyFile(original: value);
    }
    notifyListeners();
    save();
  }

  // Background image during the pause
  String _textDuringActiveSession;
  String get textDuringActiveSession => _textDuringActiveSession;
  set textDuringActiveSession(String value) {
    _textDuringActiveSession = value;
    notifyListeners();
    save();
  }

  ///
  /// Vanilla way to save the current preferences to a file
  void save() async {
    final file = File(_preferencesPath);
    await file.writeAsString(json.encode(_serializePreferences));
  }

  // CONSTRUCTOR AND ACCESSORS

  ///
  /// Main accessor of the AppPreference
  static AppPreferences of(BuildContext context, {listen = true}) =>
      Provider.of<AppPreferences>(context, listen: listen);

  ///
  /// Main constructor of the AppPreferences. If [reload] is false, then the
  /// previously saved folder is ignored
  static Future<AppPreferences> factory({reload = true}) async {
    final documentDirectory = await getApplicationDocumentsDirectory();
    final directory = Directory('${documentDirectory.path}/$appName');
    if (!(await directory.exists())) {
      await directory.create(recursive: true);
    }

    final preferencesFile = File(_path(directory, preferencesFilename));
    Map<String, dynamic>? previousPreferences;
    if (reload && await preferencesFile.exists()) {
      previousPreferences = jsonDecode(await preferencesFile.readAsString());
    }
    return AppPreferences._(
        nbSessions: previousPreferences?['nbSessions'] ?? 0,
        sessionDuration:
            Duration(minutes: previousPreferences?['sessionTime'] ?? 0),
        pauseDuration:
            Duration(minutes: previousPreferences?['pauseDuration'] ?? 0),
        directory: directory,
        activeBackgroundImageFilename:
            previousPreferences?['activeBackgroundImageFilename'],
        pauseBackgroundImageFilename:
            previousPreferences?['pauseBackgroundImageFilename'],
        textDuringActiveSession:
            previousPreferences?['textDuringActiveSession'],
        lastVisitedDirectory: Directory(
            previousPreferences?['lastVisitedDirectory'] ??
                documentDirectory.path));
  }

  AppPreferences._({
    required int nbSessions,
    required Duration sessionDuration,
    required Duration pauseDuration,
    required Directory directory,
    required String? activeBackgroundImageFilename,
    required String? pauseBackgroundImageFilename,
    required String? textDuringActiveSession,
    required Directory lastVisitedDirectory,
  })  : _nbSessions = nbSessions,
        _sessionDuration = sessionDuration,
        _pauseDuration = pauseDuration,
        preferencesDirectory = directory,
        _activeBackgroundImageFilename = activeBackgroundImageFilename,
        _pauseBackgroundImageFilename = pauseBackgroundImageFilename,
        _textDuringActiveSession = textDuringActiveSession ??
            'Session {currentSession}/{maxSessions}\n{timer}',
        _lastVisitedDirectory = lastVisitedDirectory;

  // INTERNAL METHODS

  ///
  /// Copy a file and return the name of the new file
  Future<String> _copyFile({required String original}) async {
    final file = File(original);
    final newFile =
        await file.copy(_path(preferencesDirectory, basename(file.path)));

    _lastVisitedDirectory = file.parent;
    return basename(newFile.path);
  }

  ///
  /// Serialize all the values
  Map<String, dynamic> get _serializePreferences => {
        'nbSessions': _nbSessions,
        'sessionTime': _sessionDuration.inMinutes,
        'pauseDuration': _pauseDuration.inMinutes,
        'activeBackgroundImageFilename': _activeBackgroundImageFilename,
        'pauseBackgroundImageFilename': _pauseBackgroundImageFilename,
        'textDuringActiveSession': _textDuringActiveSession,
        'lastVisitedDirectory': _lastVisitedDirectory.path,
      };
}
