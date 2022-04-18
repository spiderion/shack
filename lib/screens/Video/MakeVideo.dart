import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grid/models/user_model.dart';
import 'package:flutter_grid/screens/Video/camera_screen.dart';
import 'package:flutter_grid/screens/Video/video_preview.dart';
import 'package:flutter_grid/screens/util/color.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

class MakeVideo extends StatefulWidget {
  final User currentUser;

  MakeVideo(this.currentUser);

  @override
  MakeVideoState createState() => MakeVideoState();
}

class MakeVideoState extends State<MakeVideo> {

  final _cameraKey = GlobalKey<CameraScreenState>();
  bool checkvideo = false;
  String videopath;
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    checkvideofile();
  }

  checkvideofile() async {
    final Directory extDir = await getTemporaryDirectory();
    final String dirPath = '${extDir.path}/media';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/profile.mp4';

    if (await File(filePath).exists()) {
     int size =await File(filePath).length();
     print('asd');
     print(size);
      setState(() {
        videopath = filePath;
        _controller = VideoPlayerController.file(File(videopath))
          ..initialize().then(
                (_) {
              setState(() {});
            },
          );
        checkvideo = true;
      });
    } else {
      setState(() {
        checkvideo = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: primaryColor,
      body: Container(
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.only(left: 25, right: 25),
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: mediaQueryData.padding.top + 20,
                ),
                FlatButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    color: Theme.of(context).backgroundColor,
                    padding: EdgeInsets.all(8),
                    textColor: Theme.of(context).primaryColor,
                    onPressed: (){
                      pushNewScreenWithRouteSettings(
                        context,
                        screen:CameraScreen(
                          key: _cameraKey,
                          make: this
                        ),
                        withNavBar: false,
                        pageTransitionAnimation: PageTransitionAnimation.cupertino,
                      );
                    },
                    child: Container(
                      alignment: Alignment.center,
                      child: Text('Capture Video',
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15
                        ),
                        textAlign: TextAlign.center,),
                    )
                ),
                checkvideo ? Column(children: <Widget>[
                  VideoPreview(
                    controller: _controller,
                  ),
                  FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      color: Theme.of(context).backgroundColor,
                      padding: EdgeInsets.all(8),
                      textColor: Theme.of(context).primaryColor,
                      onPressed: (){
                        showDialog(
                            context: context,
                            builder: (context) {
                              uploadFile(File(videopath), widget.currentUser);
                              return Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ));
                            });

                      },
                      child: Container(
                        alignment: Alignment.center,
                        child: Text('Upload Video',
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15
                          ),
                          textAlign: TextAlign.center,),
                      )
                  ),
                  SizedBox(
                    height: 30,
                  )
                ],)
                    : Container()
              ]),
        )
      ),
    );
  }
  Future uploadFile(File image,User currentUser) async {
    await VideoCompress.deleteAllCache();
    final info = await VideoCompress.compressVideo(
      image.path,
      quality: VideoQuality.HighestQuality,
      deleteOrigin: false,
      includeAudio: true,
    );
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('users/${currentUser.id}/profile.mp4');
    StorageUploadTask uploadTask = storageReference.putFile(File(info.path), StorageMetadata(contentType: 'video/mp4'));
    if (uploadTask.isInProgress == true) {}
    if (await uploadTask.onComplete != null) {
      storageReference.getDownloadURL().then((fileURL) async {
        if (mounted)
          setState(() {
            if(currentUser.imageUrl == null){
              currentUser.imageUrl = List();
            }
            currentUser.imageUrl.add(fileURL);
          });
        Map<String, dynamic> updateObject = {
          'video': fileURL,
        };
        try {
          await Firestore.instance
              .collection("Users")
              .document(currentUser.id)
              .setData(updateObject, merge: true);
          Navigator.of(context, rootNavigator: true).pop('dialog');
        } catch (err) {
        }
      });
    }
  }
}