import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as i;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shack/models/user_model.dart';
import 'package:shack/screens/user_info/user_name.dart';
import 'package:shack/widgets/loader.dart';
import 'package:shack/widgets/welcome_title_widget.dart';

import '../widgets/welcome_background_widget.dart';
import '../widgets/welcome_content_container_widget.dart';

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
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Container(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: <Widget>[
              WelcomeBackgroundWidget(),
              WelcomeTitleWidget(),
              Align(
                  alignment: Alignment.center, child: WelcomeContentContainerWidget(child: content(context)))
            ],
          )),
    );
  }

  Widget content(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    final ThemeData _theme = Theme.of(context);
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 10),
            child: Text("Add a photo so your friends can see you",
                textAlign: TextAlign.center, style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold)),
          ),
          mainImage(),
          SizedBox(height: 1),
          choosePhotoButton(context)
        ],
      ),
    );
  }

  Widget mainImage() {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(100)),
      child: Container(
        height: 180,
        width: 180,
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: Icon(
          Icons.camera_alt_outlined,
          size: 50,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget takePhotoWidget(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      margin: EdgeInsets.only(top: 10, bottom: 10),
      child: ElevatedButton(
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
    );
  }

  Widget choosePhotoButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      margin: EdgeInsets.only(top: 10, bottom: 10),
      child: ElevatedButton(
          onPressed: () async {
            getImage(ImageSource.gallery, context, currentUser);
            await showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) {
                  return LoaderWidget();
                });
          },
          child: Container(
              alignment: Alignment.center,
              child: Text('CHOOSE A PHOTO',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15), textAlign: TextAlign.center))),
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
