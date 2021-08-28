import 'package:flutter/material.dart';

class SurveyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Expanded(
      child: Column(
          children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Text("Survey for ",
                    style: TextStyle(
                      fontSize: 13,
                    )),
                Text("Sunday, August 8th 2021",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ))
              ]),
        ),
        const Padding(
          padding: EdgeInsets.all(10.0),
          child: Text(
            "How were you feeling today",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(child: SurveyList())
      ]),
    ));
  }
}

class SurveyList extends StatefulWidget {
  const SurveyList({Key? key}) : super(key: key);

  @override
  _SurveyListState createState() => _SurveyListState();
}

class _SurveyListState extends State<SurveyList> {
  final _rating_text = <String>["Good", "Okay", "Bad", "Horrible", "Terrible"];
  final _rating_emoji = <String>["😊", "😕", "😞", "😟", "😩"];
  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(height: 350,child: _buildSurvey()),
    );
  }

  Widget _buildSurvey() {
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(20.0),
        itemCount: _rating_text.length,
        itemBuilder: /*1*/ (context, i) {
          // return _buildRow(_suggestions[i], i);
          return Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: Container(
              // width: MediaQuery.of(context).size.width * 0.6,
              width: 180.0,
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                color: Color.fromARGB(1, 234, 234, 234),
                child: Container(
                  child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Text(
                          _rating_emoji[i].toString(),
                          style: TextStyle(fontSize: 70.0),
                        ),
                      ),
                      Text(
                        _rating_text[i].toString(),
                        style: const TextStyle(
                            color: Colors.white, fontSize: 36.0),
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
