import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grid/elements/CardsCarouselLoaderWidget.dart';
import 'package:flutter_grid/screens/questions/songSearch.dart';
import 'package:flutter_grid/screens/util/color.dart';
import 'package:flutter_grid/models/question_model.dart';
import 'package:flutter_grid/elements/QuestionWidget.dart';

class Write_answer extends StatefulWidget {
  Question_model model;

  Write_answer({Key key, this.model}) : super(key: key);

  @override
  _Write_answerState createState() => _Write_answerState();
}

class _Write_answerState extends State<Write_answer> {

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
          title: Text(
            "Write Answer",
            style: TextStyle(color: Colors.white),
          ),
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
                onPressed: (){
                  _initiateSearch();
                },
                child: Container(
                  alignment: Alignment.center,
                  child: Text('Select Music',
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15
                    ),
                    textAlign: TextAlign.center,),
                )
            ),
          ],
        )
      ),
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
