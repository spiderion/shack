import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shack/models/question_model.dart';
import 'package:shack/screens/questions/song_search.dart';

import '../../themes/theme.dart';

class WriteAnswer extends StatefulWidget {
  final QuestionModel? model;

  WriteAnswer({Key? key, this.model}) : super(key: key);

  @override
  _WriteAnswerState createState() => _WriteAnswerState();
}

class _WriteAnswerState extends State<WriteAnswer> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: Text("Write Answer", style: TextStyle(color: Colors.white)),
          elevation: 0,
          backgroundColor: primaryColor),
      body: Container(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: <Widget>[
              FlatButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  color: Theme.of(context).backgroundColor,
                  padding: EdgeInsets.all(8),
                  textColor: Theme.of(context).primaryColor,
                  onPressed: () {
                    _initiateSearch();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    child: Text('Select Music',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                        textAlign: TextAlign.center),
                  )),
            ],
          )),
    );
  }

  void _initiateSearch() {
    showSearch(context: context, delegate: CustomSearchDelegate()).then((res) {
      if (res != null) {
        print('heel');
      }
    });
  }
}
