import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grid/elements/CardsCarouselLoaderWidget.dart';
import 'package:flutter_grid/screens/util/color.dart';
import 'package:flutter_grid/models/question_model.dart';
import 'package:flutter_grid/elements/QuestionWidget.dart';

class Answer_quetions extends StatefulWidget {

  Answer_quetions();

  @override
  _Answer_quetionsState createState() => _Answer_quetionsState();
}

class _Answer_quetionsState extends State<Answer_quetions> {

  List<Question_model> questions = [];

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _getquetions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: Text(
            "Answer Questions",
            style: TextStyle(color: Colors.white),
          ),
          elevation: 0,
          backgroundColor: primaryColor),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Container(
          child: questions.length != 0? ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: questions.length,
            itemBuilder: (context, index){
              return QuestionWidget(model: questions.elementAt(index),);
            },
          ):
          CardsCarouselLoaderWidget()
        ),
      ),
    );
  }

  _getquetions(){

    return Firestore.instance.collection('questions')
        .snapshots().listen((onData) {
          if(onData.documents.length > 0){
            onData.documents.forEach((f) {
              Question_model tempmodel = Question_model.fromDocument(f);
              questions.add(tempmodel);
              setState(() {

              });
            });
          }
    });
  }

}
