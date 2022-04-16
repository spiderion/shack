import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shack/models/user_model.dart';
import 'package:shack/screens/user_name.dart';
import 'package:image/image.dart' as i;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:template_package/utils/build_mode_detector.dart';

class SelectImage extends StatefulWidget {
  SelectImage();

  @override
  _SelectImageState createState() => _SelectImageState();
}

class _SelectImageState extends State<SelectImage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String? code;
  CollectionReference docRef = FirebaseFirestore.instance.collection('Users');
  AppUser? currentUser;

  @override
  void initState() {
    super.initState();
    getcurrentuser();
  }

  getcurrentuser() async {
    final _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      docRef.doc("${_user.uid}").snapshots().listen((data) {
        currentUser = AppUser.fromimageDocument(data.data() as Map<String, dynamic>);
      });
    }
  }

  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("Profile"),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: <Widget>[
            Container(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 20,
                  ),
                  ListTile(
                      title: Text(
                        "ADD A PROFILE\nPICTURE",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.w900, color: _theme.backgroundColor),
                      ),
                      subtitle: Container(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                          "Add a photo so your friends can see you",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15, color: Colors.black),
                        ),
                      )),
                  Container(
                    height: 180,
                    margin: EdgeInsets.only(top: 80),
                    child: Image.asset(
                      'assets/auth/user.png',
                      fit: BoxFit.fitHeight,
                    ),
                  )
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                width: mediaQueryData.size.width,
                padding: EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      height: 50,
                      margin: EdgeInsets.only(top: 10, bottom: 10),
                      child: FlatButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          color: _theme.backgroundColor,
                          padding: EdgeInsets.all(8),
                          textColor: _theme.primaryColor,
                          onPressed: () async {
                            getImage(ImageSource.gallery, context, currentUser);
                            await showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) {
                                  return Center(
                                      child: isInDebugMode
                                          ? Text('loading')
                                          : CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ));
                                });
                          },
                          child: Container(
                              alignment: Alignment.center,
                              child: Text('CHOOSE A PHOTO',
                                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                                  textAlign: TextAlign.center))),
                    ),
                    Container(
                      width: double.infinity,
                      height: 50,
                      margin: EdgeInsets.only(top: 10, bottom: 10),
                      child: FlatButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          color: _theme.backgroundColor,
                          padding: EdgeInsets.all(8),
                          textColor: _theme.primaryColor,
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  getImage(ImageSource.camera, context, currentUser);
                                  return Center(
                                      child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ));
                                });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              'TAKE A PHOTO',
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                              textAlign: TextAlign.center,
                            ),
                          )),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future getImage(ImageSource imageSource, context, AppUser? currentUser) async {
    ThemeData _theme = Theme.of(context);
    var image = await ImagePicker().pickImage(source: imageSource);
    if (image != null) {
      File? croppedFile = await ImageCropper().cropImage(
          sourcePath: image.path,
          aspectRatioPresets: [CropAspectRatioPreset.square],
          androidUiSettings: AndroidUiSettings(
              toolbarTitle: 'Crop',
              toolbarColor: _theme.backgroundColor,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true),
          iosUiSettings: IOSUiSettings(
            minimumAspectRatio: 1.0,
          ));
      if (croppedFile != null) {
        final compressedIMage = await compressimage(croppedFile);
        await uploadFile(compressedIMage, currentUser);
      }
    }
    Navigator.pop(context);
  }

  Future uploadFile(File image, AppUser? currentUser) async {
    Reference storageReference =
        FirebaseStorage.instance.ref().child('users/${currentUser?.id}/${image.hashCode}.jpg');
    UploadTask uploadTask = storageReference.putFile(image);
    // if (uploadTask.isInProgress == true) {}
    uploadTask.whenComplete(() {
      storageReference.getDownloadURL().then((fileURL) async {
        if (mounted)
          setState(() {
            if (currentUser?.imageUrl == null) {
              currentUser?.imageUrl = [];
            }
            currentUser?.imageUrl?.add(fileURL);
          });
        Map<String, dynamic> updateObject = {
          'userId': currentUser?.id,
          'phoneNumber': currentUser?.phoneNumber,
          'timestamp': FieldValue.serverTimestamp(),
          "Pictures": FieldValue.arrayUnion([
            fileURL,
          ])
        };
        try {
          await FirebaseFirestore.instance.collection("Users").doc(currentUser?.id).set(updateObject);
          Navigator.push(context, CupertinoPageRoute(builder: (context) => UserName()));
        } catch (err) {}
      });
    });
  }

  Future<File> compressimage(File image) async {
    final tempdir = await getTemporaryDirectory();
    final path = tempdir.path;
    i.Image imagefile = i.decodeImage(image.readAsBytesSync())!;
    final compressedImageFile = File('$path.jpg')..writeAsBytesSync(i.encodeJpg(imagefile, quality: 80));
    return compressedImageFile;
  }
}
