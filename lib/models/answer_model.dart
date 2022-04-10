import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class Answer_model {
  final String? id;
  final bool? answer;
  Answer_model({
    required this.id,
    required this.answer,
  });
  factory Answer_model.fromDocument(DocumentSnapshot doc) {
    // DateTime date = DateTime.parse(doc["user_DOB"]);
    return Answer_model(
      id: doc['id'],
      answer: doc['answer'],
    );
  }
}
