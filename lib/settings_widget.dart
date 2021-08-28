import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:redis/redis.dart';

class SettingsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Expanded(
      child: Row(children: [
        Expanded(
            child: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(width: 320, child: SettingsList()))),
        Expanded(
            child: Align(alignment: Alignment.topLeft, child: DetailsFrag())),
      ]),
    ));
  }
}

class SettingsList extends StatefulWidget {
  const SettingsList({Key? key}) : super(key: key);

  @override
  _SettingsListState createState() => _SettingsListState();
}

class _SettingsListState extends State<SettingsList> {
  final _settings_text = <String>["Wearable", "Scale", "Internet", "Power"];
  final _settings_icon = <IconData>[
    Icons.watch,
    Icons.monitor_weight,
    Icons.wifi,
    Icons.power_settings_new
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildSettings(),
    );
  }

  Widget _buildSettings() {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.all(20.0),
        itemCount: _settings_text.length,
        itemBuilder: /*1*/ (context, i) {
          // return _buildRow(_suggestions[i], i);
          return Padding(
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
            child: Container(
              // width: MediaQuery.of(context).size.width * 0.6,
              child: OutlinedButton(
                onPressed: () {},
                style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.circular(20)),
                )),
                child: Container(
                  child: Center(
                      child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Icon(
                          _settings_icon[i],
                          color: Colors.black87,
                        ),
                      ),
                      Align(
                        child: Text(
                          _settings_text[i].toString(),
                          style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w500),
                        ),
                      )
                    ],
                  )),
                ),
              ),
            ),
          );
        });
  }
}

class DetailsFrag extends StatefulWidget {
  int selected = 0;
  final List<Widget> _fragments = [WearablesList(), SettingsList()];

  @override
  _DetailsFrag createState() => _DetailsFrag();
}

typedef void IntCallback(int selected);

class _DetailsFrag extends State<DetailsFrag> {
  @override
  Widget build(BuildContext context) {
    return widget._fragments[widget.selected];
  }

  void setSelected(int i) {
    widget.selected = i;
    setState(() {});
  }
}

class WearablesList extends StatefulWidget {
  //const WearablesList({Key? key}) : super(key: key);
  final List<Widget> buttons = [
    MyBlinkingButton(buttonColor: Colors.red),
    MyBlinkingButton(buttonColor: Colors.green),
    MyBlinkingButton(buttonColor: Colors.yellow)
  ];

  //final client = await Client.connect('redis://localhost:6379');
  @override
  _WearablesList createState() => _WearablesList();
}

class _WearablesList extends State<WearablesList> {
  var _available_devices_names = [];
  bool devices_loading = true;
  String wearable_status = "Searching for Devices";
  bool show_connection_status = false;
  Timer? timer;
  MaterialColor _conn_status_color = Colors.yellow;
  int selected_button = 2;
  StreamSubscription<dynamic>? stream_handle;
  Map<String, dynamic>? current_meta;
  String current_name = "";
  bool show_devices = false;
  bool attempting_to_connect = false;

  @override
  void initState() {
    super.initState();
    _startStream();

    fetchItems().then((value) => {
          _available_devices_names = json.decode(value),
          if (_available_devices_names.isNotEmpty & !show_connection_status & !attempting_to_connect)
            {devices_loading = false, show_devices = true, wearable_status = "Select Device"},
          setState(() {})
        });

    timer = Timer.periodic(Duration(seconds: 2), (Timer t) {
      fetchItems().then((value) => {
            _available_devices_names = json.decode(value),
        if (_available_devices_names.isNotEmpty & !show_connection_status& !attempting_to_connect)
          {devices_loading = false, show_devices = true, wearable_status = "Select Device"},
            setState(() {})
          });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    stream_handle?.cancel();
    super.dispose();
  }

  Future<String> fetchItems() async {
    RedisConnection conn = new RedisConnection();
    try {
      var command = await conn.connect('127.0.0.1', 6379);
      // await command.set("available_wearables",
      //     "[{\"device_name\" : \"bangle-1\",\"device_adder\" : \"22:ed:33\"},{\"device_name\" : \"bangle-2\",\"device_adder\" : \"22:ed:37\"}]");
      return await command.send_object(["GET", "available_wearables"]);
    } catch (err) {
      print(err);
      return "[]";
    }

  }

  void _connectWearable(int index) async {
    //wearable_status = "Connecting";
    devices_loading = true;
    show_devices = false;
    attempting_to_connect = true;
    setState(() {});
    RedisConnection conn = new RedisConnection();
    var command = await conn.connect('localhost', 6379);
    var data = {
      "command": {"BTCONNECT": _available_devices_names[index]['device_addr']}
    };
    command.send_object(["PUBLISH", "frontend", jsonEncode(data)]);
    Future.delayed(const Duration(seconds: 10), () {
      if(!show_connection_status){
        attempting_to_connect = false;
        devices_loading = false;
        show_devices = true;
        setState(() {});
      }
    });
  }

  void _disconnectWearable() async {
    if (current_meta != null) {
      show_connection_status = false;
      devices_loading =  true;
      wearable_status = "Disconnecting";
      RedisConnection conn = new RedisConnection();
      var command = await conn.connect('localhost', 6379);
      var data = {
        "command": {"BTDISCONNECT": current_meta?["device_addr"]}
      };
      command.send_object(["PUBLISH", "frontend", jsonEncode(data)]);
    } else {
      show_connection_status = false;
      attempting_to_connect = false;
      show_devices = true;
    }
    setState(() {});
  }

  void _startStream() async {
    RedisConnection conn = new RedisConnection();
    var command = await conn.connect('localhost', 6379);
    PubSub pubsub = new PubSub(command);
    pubsub.subscribe(["backend_message"]);
    stream_handle = pubsub.getStream().listen((message) {
      if (message[2] != 1) {
        print(message.toString());
        var wearable_event = jsonDecode(message[2].toString());
        show_connection_status = true;
        devices_loading = false;
        attempting_to_connect = false;
        show_devices = false;
        current_meta = wearable_event["meta"];
        current_name = current_meta?["device_name"];
        String event = wearable_event["event"];
        if (event == "Connected" || event == "Recovered") {
          _conn_status_color = Colors.green;
          selected_button = 1;
        } else if (event == "AttemptingConnection" ||
            event == "TimedOut" ||
            event == "FailedToRecover" ||
            event == "FailedToConnect") {
          _conn_status_color = Colors.yellow;
          selected_button = 2;
        } else if (event == "Disconnecting"){
          _conn_status_color = Colors.red;
          selected_button = 0;
        }else {
          _conn_status_color = Colors.red;
          selected_button = 0;
          Future.delayed(const Duration(milliseconds: 1500), () {
            show_connection_status = false;
            current_meta = null;
            current_name = "";
            show_devices = true;
            attempting_to_connect = false;
            setState(() {});
          });
        }
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            maintainState: true,
            visible: show_connection_status,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
              child: Row(
                children: [
                  SizedBox(
                    width: 275,
                    child: OutlinedButton(
                      onPressed: () {
                        _disconnectWearable();
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Disconnecting')));
                      },
                      style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      )),
                      child: Text(
                        current_name,
                        style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: widget.buttons[selected_button]
                    // Icon(
                    //   Icons.circle,
                    //   color: _conn_status_color,
                    //   size: 18,
                    // ),
                  ),

                ],
              ),
            ),
          ),
          Visibility(
              maintainState: true,
              visible: devices_loading,
              child: Container(
                  margin: EdgeInsets.only(top: 15, bottom: 10, left: 120),
                  child: CircularProgressIndicator())),

          Expanded(
            child: Visibility(
                maintainState: true,
                visible: show_devices,
                child: SizedBox(width: 320, child: _buildWearables())),
          ),
        ],
      ),
    );
  }

  Widget _buildWearables() {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
        itemCount: _available_devices_names.length,
        itemBuilder: /*1*/ (context, i) {
          // return _buildRow(_suggestions[i], i);
          return Padding(
            padding: const EdgeInsets.fromLTRB(0, 5, 15, 5),
            child: Container(
              // width: MediaQuery.of(context).size.width * 0.6,
              child: OutlinedButton(
                onPressed: () {
                  _connectWearable(i);
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Connecting')));
                },
                style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                )),
                child: Text(
                  _available_devices_names[i]['device_name'].toString(),
                  style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400),
                ),
              ),
            ),
          );
        });
  }
}


class MyBlinkingButton extends StatefulWidget {
  MaterialColor buttonColor;

  MyBlinkingButton(
      {Key? key,
        required this.buttonColor})
      : super(key: key);

  @override
  _MyBlinkingButtonState createState() => _MyBlinkingButtonState();
}

class _MyBlinkingButtonState extends State<MyBlinkingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController =
    new AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animationController.repeat(reverse: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animationController,
      child: Icon(
        Icons.circle,
        color: widget.buttonColor,
        size: 18,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

//device_adder, frontend,

// Padding(
// padding: const EdgeInsets.fromLTRB(0, 20, 0, 5),
// child: Text(
// wearable_status,
// style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w700),
// ),
// )
