import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grid/models/user_model.dart';
import 'package:image/image.dart' as i;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class EditProfile extends StatefulWidget {
  final AppUser currentUser;

  EditProfile(this.currentUser);

  @override
  EditProfileState createState() => EditProfileState();
}

class EditProfileState extends State<EditProfile> {
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
      visibleAge = widget.currentUser.editInfo['showMyAge'] ?? false;
      visibleDistance = widget.currentUser.editInfo['DistanceVisible'] ?? true;
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
    FirebaseFirestore.instance
        .collection("Users")
        .doc(widget.currentUser.id)
        .set({'editInfo': editInfo, 'age': widget.currentUser.age}, SetOptions(merge: true));
  }

  Future source(BuildContext context, currentUser, bool isProfilePicture) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
              title: Text(isProfilePicture ? "Update profile picture" : "Add pictures"),
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
                                    fontSize: 15, color: Colors.black, decoration: TextDecoration.none),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            showDialog(
                                context: context,
                                builder: (context) {
                                  getImage(ImageSource.camera, context, currentUser, isProfilePicture);
                                  return Center(
                                      child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                                    fontSize: 15, color: Colors.black, decoration: TextDecoration.none),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) {
                                  getImage(ImageSource.gallery, context, currentUser, isProfilePicture);
                                  return Center(
                                      child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                                  fontSize: 15, color: Colors.black, decoration: TextDecoration.none),
                            ),
                          ],
                        )),
                      )
                    ]);
        });
  }

  Future getImage(ImageSource imageSource, context, currentUser, isProfilePicture) async {
    XFile image = await ImagePicker().pickImage(source: imageSource);
    if (image != null) {
      File croppedFile = await ImageCropper().cropImage(
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
        await uploadFile(await compressimage(croppedFile), currentUser, isProfilePicture);
      }
    }
    Navigator.pop(context);
  }

  Future uploadFile(File image, AppUser currentUser, isProfilePicture) async {
    Reference storageReference =
        FirebaseStorage.instance.ref().child('users/${currentUser.id}/${image.hashCode}.jpg');
    UploadTask uploadTask = storageReference.putFile(image);
    uploadTask.whenComplete(() {
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
            await FirebaseFirestore.instance
                .collection("Users")
                .doc(currentUser.id)
                .set({"Pictures": currentUser.imageUrl}, SetOptions(merge: true));
          } else {
            await FirebaseFirestore.instance
                .collection("Users")
                .doc(currentUser.id)
                .set(updateObject, SetOptions(merge: true));
            widget.currentUser.imageUrl.add(fileURL);
          }
          if (mounted) setState(() {});
        } catch (err) {
          print("Error: $err");
        }
      });
    });
  }

  Future compressimage(File image) async {
    final tempdir = await getTemporaryDirectory();
    final path = tempdir.path;
    i.Image imagefile = i.decodeImage(image.readAsBytesSync());
    final compressedImagefile = File('$path.jpg')..writeAsBytesSync(i.encodeJpg(imagefile, quality: 80));
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
            "Edit Profile",
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            color: Colors.white,
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: Theme.of(context).backgroundColor),
      body: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50)),
              color: Colors.white),
          child: ClipRRect(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50)),
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
                        childAspectRatio: MediaQuery.of(context).size.aspectRatio * 1.5,
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
                                decoration: widget.currentUser.imageUrl.length > index
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
                                            height: MediaQuery.of(context).size.height * .2,
                                            fit: BoxFit.cover,
                                            imageUrl: widget.currentUser.imageUrl[index],
                                            placeholder: (context, url) => Center(
                                              child: CupertinoActivityIndicator(
                                                radius: 10,
                                              ),
                                            ),
                                            errorWidget: (context, url, error) => Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
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
                                            color: widget.currentUser.imageUrl.length > index
                                                ? Colors.white
                                                : Theme.of(context).primaryColor,
                                          ),
                                          child: widget.currentUser.imageUrl.length > index
                                              ? InkWell(
                                                  child: Icon(
                                                    Icons.cancel,
                                                    color: Theme.of(context).primaryColor,
                                                    size: 22,
                                                  ),
                                                  onTap: () async {
                                                    if (widget.currentUser.imageUrl.length > 1) {
                                                      setState(() {
                                                        widget.currentUser.imageUrl.removeAt(index);
                                                      });
                                                      var temp = [];
                                                      temp.add(widget.currentUser.imageUrl);
                                                      await FirebaseFirestore.instance
                                                          .collection("Users")
                                                          .doc("${widget.currentUser.id}")
                                                          .set(
                                                              {"Pictures": temp[0]}, SetOptions(merge: true));
                                                    } else {
                                                      source(context, widget.currentUser, true);
                                                    }
                                                  },
                                                )
                                              : InkWell(
                                                  child: Icon(
                                                    Icons.add_circle_outline,
                                                    size: 22,
                                                    color: Colors.white,
                                                  ),
                                                  onTap: () => source(context, widget.currentUser, false),
                                                )),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        })),
                  ),
                  InkWell(
                    child: Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(25),
                            gradient:
                                LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [
                              Theme.of(context).primaryColor.withOpacity(.5),
                              Theme.of(context).primaryColor.withOpacity(.8),
                              Theme.of(context).primaryColor,
                              Theme.of(context).primaryColor,
                            ])),
                        height: 50,
                        width: 340,
                        child: Center(
                            child: Text(
                          "Add media",
                          style: TextStyle(
                              fontSize: 15,
                              color: Theme.of(context).backgroundColor,
                              fontWeight: FontWeight.bold),
                        ))),
                    onTap: () async {
                      await source(context, widget.currentUser, false);
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListBody(
                      mainAxis: Axis.vertical,
                      children: <Widget>[
                        ListTile(
                          title: Text(
                            "About ${widget.currentUser.name}",
                            style:
                                TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.black87),
                          ),
                          subtitle: CupertinoTextField(
                            controller: aboutCtlr,
                            cursorColor: Theme.of(context).primaryColor,
                            maxLines: 10,
                            minLines: 3,
                            placeholder: "About you",
                            padding: EdgeInsets.all(10),
                            onChanged: (text) {
                              editInfo.addAll({'about': text});
                            },
                          ),
                        ),
                        ListTile(
                          title: Text(
                            "Job title",
                            style:
                                TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.black87),
                          ),
                          subtitle: CupertinoTextField(
                            controller: jobCtlr,
                            cursorColor: Theme.of(context).primaryColor,
                            placeholder: "Add job title",
                            padding: EdgeInsets.all(10),
                            onChanged: (text) {
                              editInfo.addAll({'job_title': text});
                            },
                          ),
                        ),
                        ListTile(
                          title: Text(
                            "Company",
                            style:
                                TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.black87),
                          ),
                          subtitle: CupertinoTextField(
                            controller: companyCtlr,
                            cursorColor: Theme.of(context).primaryColor,
                            placeholder: "Add company",
                            padding: EdgeInsets.all(10),
                            onChanged: (text) {
                              editInfo.addAll({'company': text});
                            },
                          ),
                        ),
                        ListTile(
                          title: Text(
                            "University",
                            style:
                                TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.black87),
                          ),
                          subtitle: CupertinoTextField(
                            controller: universityCtlr,
                            cursorColor: Theme.of(context).primaryColor,
                            placeholder: "Add university",
                            padding: EdgeInsets.all(10),
                            onChanged: (text) {
                              editInfo.addAll({'university': text});
                            },
                          ),
                        ),
                        ListTile(
                          title: Text(
                            "Living in",
                            style:
                                TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.black87),
                          ),
                          subtitle: CupertinoTextField(
                            controller: livingCtlr,
                            cursorColor: Theme.of(context).primaryColor,
                            placeholder: "Add city",
                            padding: EdgeInsets.all(10),
                            onChanged: (text) {
                              editInfo.addAll({'living_in': text});
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: ListTile(
                            title: Text(
                              "I am",
                              style:
                                  TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.black87),
                            ),
                            subtitle: DropdownButton(
                              iconEnabledColor: Theme.of(context).primaryColor,
                              iconDisabledColor: Theme.of(context).backgroundColor,
                              isExpanded: true,
                              items: [
                                DropdownMenuItem(
                                  child: Text("Man"),
                                  value: "man",
                                ),
                                DropdownMenuItem(child: Text("Woman"), value: "woman"),
                                DropdownMenuItem(child: Text("Other"), value: "other"),
                              ],
                              onChanged: (val) {
                                editInfo.addAll({'userGender': val});
                                setState(() {
                                  showMe = val;
                                });
                              },
                              value: showMe,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        ListTile(
                            title: Text(
                              "Control your profile",
                              style:
                                  TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.black87),
                            ),
                            subtitle: Card(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text("Don't Show My Age"),
                                      ),
                                      Switch(
                                          activeColor: Theme.of(context).primaryColor,
                                          value: visibleAge,
                                          onChanged: (value) {
                                            editInfo.addAll({'showMyAge': value});
                                            setState(() {
                                              visibleAge = value;
                                            });
                                          })
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text("Make My Distance Visible"),
                                      ),
                                      Switch(
                                          activeColor: Theme.of(context).primaryColor,
                                          value: visibleDistance,
                                          onChanged: (value) {
                                            editInfo.addAll({'DistanceVisible': value});
                                            setState(() {
                                              visibleDistance = value;
                                            });
                                          })
                                    ],
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
