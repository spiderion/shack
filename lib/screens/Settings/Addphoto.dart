import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_grid/models/user_model.dart';
import 'package:flutter_grid/screens/util/color.dart';
import 'package:image/image.dart' as i;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class Addphoto extends StatefulWidget {
  final AppUser currentUser;
  Addphoto(this.currentUser);

  @override
  AddphotoState createState() => AddphotoState();
}

class AddphotoState extends State<Addphoto> {
  final TextEditingController aboutCtlr = new TextEditingController();
  final TextEditingController companyCtlr = new TextEditingController();
  final TextEditingController livingCtlr = new TextEditingController();
  final TextEditingController jobCtlr = new TextEditingController();
  final TextEditingController universityCtlr = new TextEditingController();
  bool visibleAge = false;
  bool visibleDistance = true;

  var showMe;
  Map editInfo = {};

  @override
  void initState() {
    super.initState();
    aboutCtlr.text = widget.currentUser.editInfo['about'];
    companyCtlr.text = widget.currentUser.editInfo['company'];
    livingCtlr.text = widget.currentUser.editInfo['living_in'];
    universityCtlr.text = widget.currentUser.editInfo['university'];
    jobCtlr.text = widget.currentUser.editInfo['job_title'];
    setState(() {
      showMe = widget.currentUser.editInfo['userGender'];
      visibleAge = widget.currentUser.editInfo['showMyAge']??false;
      visibleDistance = widget.currentUser.editInfo['DistanceVisible']??true;
    });
  }

  @override
  void dispose() {
    super.dispose();
    print(editInfo.length);
    if (editInfo.length > 0) {
      updateData();
    }
  }

  Future updateData() async {
    Firestore.instance
        .collection("Users")
        .document(widget.currentUser.id)
        .setData({'editInfo': editInfo, 'age': widget.currentUser.age},
        merge: true);
  }

  Future source(
      BuildContext context, currentUser, bool isProfilePicture) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
              title: Text(
                  isProfilePicture ? "Update profile picture" : "Add pictures"),
              content: Text(
                "Select source",
              ),
              insetAnimationCurve: Curves.decelerate,
              actions: currentUser.imageUrl.length < 9
                  ? <Widget>[
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: GestureDetector(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.photo_camera,
                          size: 28,
                        ),
                        Text(
                          " Camera",
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                              decoration: TextDecoration.none),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) {
                            getImage(ImageSource.camera, context,
                                currentUser, isProfilePicture);
                            return Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ));
                          });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: GestureDetector(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.photo_library,
                          size: 28,
                        ),
                        Text(
                          " Gallery",
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                              decoration: TextDecoration.none),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) {
                            getImage(ImageSource.gallery, context,
                                currentUser, isProfilePicture);
                            return Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ));
                          });
                    },
                  ),
                ),
              ]
                  : [
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Center(
                      child: Column(
                        children: <Widget>[
                          Icon(Icons.error),
                          Text(
                            "Can't uplaod more than 9 pictures",
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                decoration: TextDecoration.none),
                          ),
                        ],
                      )),
                )
              ]);
        });
  }

  Future getImage(
      ImageSource imageSource, context, currentUser, isProfilePicture) async {
    var image = await ImagePicker.pickImage(source: imageSource);
    if (image != null) {
      File croppedFile = await ImageCropper.cropImage(
          sourcePath: image.path,
          aspectRatioPresets: [CropAspectRatioPreset.square],
          androidUiSettings: AndroidUiSettings(
              toolbarTitle: 'Crop',
              toolbarColor: Theme.of(context).primaryColor,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true),
          iosUiSettings: IOSUiSettings(
            minimumAspectRatio: 1.0,
          ));
      if (croppedFile != null) {
        await uploadFile(
            await compressimage(croppedFile), currentUser, isProfilePicture);
      }
    }
    Navigator.pop(context);
  }

  Future uploadFile(File image, AppUser currentUser, isProfilePicture) async {
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('users/${currentUser.id}/${image.hashCode}.jpg');
    StorageUploadTask uploadTask = storageReference.putFile(image);
    if (uploadTask.isInProgress == true) {}
    if (await uploadTask.onComplete != null) {
      storageReference.getDownloadURL().then((fileURL) async {
        Map<String, dynamic> updateObject = {
          "Pictures": FieldValue.arrayUnion([
            fileURL,
          ])
        };
        try {
          if (isProfilePicture) {
            //currentUser.imageUrl.removeAt(0);
            currentUser.imageUrl.insert(0, fileURL);
            print("object");
            await Firestore.instance
                .collection("Users")
                .document(currentUser.id)
                .setData({"Pictures": currentUser.imageUrl}, merge: true);
          } else {
            await Firestore.instance
                .collection("Users")
                .document(currentUser.id)
                .setData(updateObject, merge: true);
            widget.currentUser.imageUrl.add(fileURL);
          }
          if (mounted) setState(() {});
        } catch (err) {
          print("Error: $err");
        }
      });
    }
  }

  Future compressimage(File image) async {
    final tempdir = await getTemporaryDirectory();
    final path = tempdir.path;
    i.Image imagefile = i.decodeImage(image.readAsBytesSync());
    final compressedImagefile = File('$path.jpg')
      ..writeAsBytesSync(i.encodeJpg(imagefile, quality: 80));
    // setState(() {
    return compressedImagefile;
    // });
  }

  @override
  Widget build(BuildContext context) {
    // Profile _profile = new Profile(widget.currentUser);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          elevation: 0,
          title: Text(
            "Add Photos",
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            color: Colors.black,
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: Colors.white),
      body: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          child: ClipRRect(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50), topRight: Radius.circular(50)),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    height: MediaQuery.of(context).size.height * .65,
                    width: MediaQuery.of(context).size.width,
                    child: GridView.count(
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        childAspectRatio:
                        MediaQuery.of(context).size.aspectRatio * 1.5,
                        crossAxisSpacing: 4,
                        padding: EdgeInsets.all(10),
                        children: List.generate(9, (index) {
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                decoration: widget.currentUser.imageUrl.length >
                                    index
                                    ? BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  // image: DecorationImage(
                                  //     fit: BoxFit.cover,
                                  //     image: CachedNetworkImageProvider(
                                  //       widget.currentUser.imageUrl[index],
                                  //     )),
                                )
                                    : BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        style: BorderStyle.solid,
                                        width: 1,
                                        color: Theme.of(context).backgroundColor)),
                                child: Stack(
                                  children: <Widget>[
                                    widget.currentUser.imageUrl.length > index
                                        ? CachedNetworkImage(
                                      height: MediaQuery.of(context)
                                          .size
                                          .height *
                                          .2,
                                      fit: BoxFit.cover,
                                      imageUrl: widget
                                          .currentUser.imageUrl[index],
                                      placeholder: (context, url) =>
                                          Center(
                                            child: CupertinoActivityIndicator(
                                              radius: 10,
                                            ),
                                          ),
                                      errorWidget:
                                          (context, url, error) => Center(
                                        child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: <Widget>[
                                            Icon(
                                              Icons.error,
                                              color: Colors.black,
                                              size: 25,
                                            ),
                                            Text(
                                              "Enable to load",
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                        : Container(),
                                    // Center(
                                    //     child:
                                    //         widget.currentUser.imageUrl.length >
                                    //                 index
                                    //             ? CupertinoActivityIndicator(
                                    //                 radius: 10,
                                    //               )
                                    //             : Container()),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Container(
                                        // width: 12,
                                        // height: 16,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: widget.currentUser.imageUrl
                                                .length >
                                                index
                                                ? Colors.white
                                                : Theme.of(context).primaryColor,
                                          ),
                                          child: widget.currentUser.imageUrl
                                              .length >
                                              index
                                              ? InkWell(
                                            child: Icon(
                                              Icons.cancel,
                                              color: Theme.of(context).primaryColor,
                                              size: 22,
                                            ),
                                            onTap: () async {
                                              if (widget.currentUser
                                                  .imageUrl.length >
                                                  1) {
                                                setState(() {
                                                  widget.currentUser
                                                      .imageUrl
                                                      .removeAt(index);
                                                });
                                                var temp = [];
                                                temp.add(widget
                                                    .currentUser
                                                    .imageUrl);
                                                await Firestore.instance
                                                    .collection("Users")
                                                    .document(
                                                    "${widget.currentUser.id}")
                                                    .setData({
                                                  "Pictures": temp[0]
                                                }, merge: true);
                                              } else {
                                                source(
                                                    context,
                                                    widget.currentUser,
                                                    true);
                                              }
                                            },
                                          )
                                              : InkWell(
                                            child: Icon(
                                              Icons.add_circle_outline,
                                              size: 22,
                                              color: Colors.white,
                                            ),
                                            onTap: () => source(
                                                context,
                                                widget.currentUser,
                                                false),
                                          )),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        })),
                  ),
                  Container(
                    width: double.infinity,
                    height: 50,
                    margin: EdgeInsets.only(top: 10, bottom: 30),
                    padding: EdgeInsets.only(left: 25, right: 25),
                    child: FlatButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        color: primaryColor,
                        padding: EdgeInsets.all(8),
                        textColor: secondryColor,
                        onPressed: () async {
                          await source(context, widget.currentUser, false);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          child: Text('UPDATE PHOTOS',
                            style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15
                            ),
                            textAlign: TextAlign.center,),
                        )
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
