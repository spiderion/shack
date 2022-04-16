import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class QuestionModel {
  final String? title;
  final String? text;
  final String? img;
  final String? id;
  QuestionModel({
    required this.id,
    required this.title,
    required this.text,
    required this.img,
  });
  factory QuestionModel.fromDocument(DocumentSnapshot doc) {
    // DateTime date = DateTime.parse(doc["user_DOB"]);
    return QuestionModel(
      id: doc['id'],
      title: doc['title'],
      text: doc['text'],
      img: doc['img'],
    );
  }
}
