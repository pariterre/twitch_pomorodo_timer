import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:twitch_procastinator_puncher/models/app_theme.dart';
import 'package:twitch_procastinator_puncher/models/helpers.dart';
import 'package:twitch_procastinator_puncher/models/preferenced_element.dart';

class TimeOnlyInputFormatter extends TextInputFormatter {
  static final _reg = RegExp(r'^(\d*)(:(\d{0,2}))?$'); // Any format mm:ss or mm

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    return isValid(newValue.text) ? newValue : oldValue;
  }

  static bool isValid(String text) {
    return _reg.hasMatch(text);
  }

  static int getMinutes(String text) {
    if (!isValid(text)) return 0;

    final minutes = _reg.firstMatch(text)!.group(1)!;
    if (minutes.isEmpty) return 0;
    return int.parse(minutes);
  }

  static int getSeconds(String text) {
    if (!isValid(text)) return 0;

    final match = _reg.firstMatch(text)!;
    if (match.group(3) == null || match.group(3)!.isEmpty) return 0;

    return int.parse(match.group(3)!);
  }
}

class TimeSelectorTile extends StatefulWidget {
  const TimeSelectorTile({
    super.key,
    required this.title,
    required this.initialValue,
    required this.onValidChange,
  });

  final String title;
  final PreferencedDuration initialValue;
  final Function(Duration value) onValidChange;

  @override
  State<TimeSelectorTile> createState() => _TimeSelectorTileState();
}

class _TimeSelectorTileState extends State<TimeSelectorTile> {
  late final _controller =
      TextEditingController(text: durationAsString(widget.initialValue.value));

  @override
  Widget build(BuildContext context) {
    final windowHeight = MediaQuery.of(context).size.height;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(widget.title,
            style: TextStyle(
                color: ThemeColor().configurationText,
                fontSize: ThemeSize.text(context))),
        Theme(
          data: ThemeData(
            inputDecorationTheme: const InputDecorationTheme(
              labelStyle: TextStyle(color: Colors.black),
              hintStyle: TextStyle(color: Colors.black),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
          child: SizedBox(
              width: windowHeight * 0.1,
              child: TextField(
                textAlign: TextAlign.center,
                controller: _controller,
                inputFormatters: [TimeOnlyInputFormatter()],
                onChanged: (value) {
                  if (!TimeOnlyInputFormatter.isValid(value)) return;
                  final minutes = TimeOnlyInputFormatter.getMinutes(value);
                  final seconds = TimeOnlyInputFormatter.getSeconds(value);
                  widget.onValidChange(
                      Duration(minutes: minutes, seconds: seconds));
                },
                style: TextStyle(fontSize: ThemeSize.text(context)),
              )),
        ),
      ],
    );
  }
}
