import 'package:direct2/settings_widget.dart';
import 'package:direct2/survey_widget.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,
        overlays: [SystemUiOverlay.bottom]);
    return MaterialApp(
      title: 'Prosilieant',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.black87,
        ),
        child: Scaffold(
          body: SafeArea(
            child: // child: Row(children: [
               HomePage(),
            // ]),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  int selected = 0;
  final List<Widget> _fragments = [
    SurveyWidget(),
    SettingsWidget()
  ];
  final nav_titles = <String>["Surveys", "Settings"];
  final nav_icons = <IconData>[Icons.content_copy_outlined, Icons.settings];

  @override
  _HomePage createState() => _HomePage();
}

typedef void IntCallback(int selected);

class _HomePage extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          color: Colors.black87,
          height: 60,
          padding: EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 0.0),
          child: (Row(
            children: [
              Wrap(spacing: 10, children: [
                for (var i = 0; i < widget.nav_icons.length; i++)
                  ClickableButton(
                      index: i,
                      buttonIcon: widget.nav_icons[i],
                      callback: (val) => setState(() => widget.selected = val),
                      selected: widget.selected)
              ]),
              Container(
                width: 2.0,
                color: Colors.white,
                margin: const EdgeInsets.all(15),
              ),
              Text(
                widget.nav_titles[widget.selected],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          )),
        ),
        widget._fragments[widget.selected]
      ],
    );
  }
}

class ClickableButton extends StatefulWidget {
  IconData buttonIcon;
  int index, selected;
  final IntCallback callback;

  ClickableButton(
      {Key? key,
      required this.index,
      required this.buttonIcon,
      required this.callback,
      required this.selected})
      : super(key: key);

  @override
  _ClickableButton createState() => _ClickableButton();
}

class _ClickableButton extends State<ClickableButton> {
  bool clicked = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => [
        setState(() {
          clicked = !clicked;
        }),
        widget.callback(widget.index)
      ],
      child: Container(
        child: Icon(
          widget.buttonIcon,
          color: Colors.white,
        ),
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: widget.index != widget.selected
              ? Colors.transparent
              : Colors.grey,
          borderRadius: BorderRadius.circular(4.0),
        ),
      ),
    );
  }
}


