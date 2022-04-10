import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class Question_model {
  final String title;
  final String text;
  final String img;
  final String id;
  Question_model({
    @required this.id,
    @required this.title,
    @required this.text,
    @required this.img,
  });
  factory Question_model.fromDocument(DocumentSnapshot doc) {
    // DateTime date = DateTime.parse(doc["user_DOB"]);
    return Question_model(
      id: doc['id'],
      title: doc['title'],
      text: doc['text'],
      img: doc['img'],
    );
  }
}
