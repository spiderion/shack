import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shack/models/question_model.dart';
import 'package:shack/screens/util/color.dart';

import '../../widgets/cards_carousel_loader_widget.dart';
import '../../widgets/question_widget.dart';

class AnswerQuestions extends StatefulWidget {
  AnswerQuestions();

  @override
  _AnswerQuestionsState createState() => _AnswerQuestionsState();
}

class _AnswerQuestionsState extends State<AnswerQuestions> {
  List<QuestionModel> questions = [];

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _getQuestions();
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
            child: questions.length != 0
                ? ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      return QuestionWidget(model: questions.elementAt(index));
                    },
                  )
                : CardsCarouselLoaderWidget()),
      ),
    );
  }

  _getQuestions() {
    return FirebaseFirestore.instance.collection('questions').snapshots().listen((onData) {
      if (onData.docs.length > 0) {
        onData.docs.forEach((QueryDocumentSnapshot queryDocumentSnapshot) {
          QuestionModel tempmodel =
              QuestionModel.fromDocument(queryDocumentSnapshot.data() as Map<String, dynamic>? ?? {});
          questions.add(tempmodel);
          setState(() {});
        });
      }
    });
  }
}
