import 'package:flutter/material.dart';

class SettingsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                Expanded(
                    child: Align(alignment: Alignment.topLeft, child: SizedBox(width: 320,child: SettingsList())))
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
  final _settings_icon = <IconData>[Icons.watch, Icons.monitor_weight, Icons.wifi, Icons.power_settings_new];
  final _biggerFont = const TextStyle(fontSize: 18.0);

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
              child: Card(
                shape: RoundedRectangleBorder(
                    side: BorderSide(width: 2, color: Colors.black87),
                    borderRadius: BorderRadius.circular(20)),
                color: Colors.white,
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
                                  color: Colors.black87, fontSize: 18.0, fontWeight: FontWeight.w500),
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

  Widget _buildRow(String pair, int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ListTile(
          title: Text(
            pair,
            style: _biggerFont,
          ),
          onTap: () {
            showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(pair),
                  content: Text('$pair is gay'),
                ));
          },
        ),
        if (index != 2) ...[
          const Divider(
            thickness: 2.1,
          )
        ],
      ],
    );
  }
}
