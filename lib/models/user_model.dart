import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String? id;
  final String? name;
  final bool? isBlocked;
  String? address;
  final Map? coordinates;
  final List? sexualOrientation;
  final String? gender;
  final String? showGender;
  final int? age;
  final String? phoneNumber;
  final String? video;
  int? maxDistance;
  Timestamp? lastmsg;
  final Map? ageRange;
  final Map? editInfo;
  List? imageUrl = [];
  var distanceBW;
  final bool? isRunning;
  final bool? isActive;

  AppUser({
    required this.id,
    this.age,
    this.address,
    this.isBlocked,
    this.coordinates,
    required this.name,
    required this.imageUrl,
    this.phoneNumber,
    this.lastmsg,
    this.gender,
    this.showGender,
    this.ageRange,
    this.maxDistance,
    this.editInfo,
    this.distanceBW,
    this.sexualOrientation,
    this.isRunning,
    this.isActive,
    this.video,
  });

  factory AppUser.fromDocument(Map<String, dynamic> json) {
    // DateTime date = DateTime.parse(doc["user_DOB"]);
    return AppUser(
        id: json['userId'],
        isBlocked: json['isBlocked'] != null ? json['isBlocked'] : false,
        isRunning: json['isRunning'] != null ? json['isRunning'] : false,
        isActive: json['isActive'] != null ? json['isActive'] : true,
        video: json['video'] != null ? json['video'] : '',
        phoneNumber: json['phoneNumber'],
        name: json['UserName'],
        editInfo: json['editInfo'],
        ageRange: json['age_range'],
        showGender: json['showGender'],
        maxDistance: json['maximum_distance'],
        sexualOrientation: json['sexualOrientation']['orientation'] ?? "" as List<dynamic>?,
        age: ((DateTime.now().difference(DateTime.parse(json["user_DOB"])).inDays) / 365.2425).truncate(),
        address: json['location']['address'],
        coordinates: json['location'],
        // university: doc['editInfo']['university'],
        imageUrl: json['Pictures'] != null
            ? List.generate(json['Pictures'].length, (index) {
                return json['Pictures'][index];
              })
            : null);
  }

  factory AppUser.fromimageDocument(DocumentSnapshot doc) {
    // DateTime date = DateTime.parse(doc["user_DOB"]);
    return AppUser(
        id: doc['userId'],
        isBlocked: doc['isBlocked'] != null ? doc['isBlocked'] : false,
        phoneNumber: doc['phoneNumber'],
        name: doc['UserName'],
        editInfo: doc['editInfo'],
        ageRange: doc['age_range'],
        showGender: doc['showGender'],
        maxDistance: doc['maximum_distance'],
        imageUrl: doc['Pictures'] != null
            ? List.generate(doc['Pictures'].length, (index) {
                return doc['Pictures'][index];
              })
            : null);
  }
}
