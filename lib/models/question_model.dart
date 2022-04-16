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

  QuestionModel.fromDocument(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        text = json['text'],
        img = json['img'];
}
