import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:shack/models/user_model.dart';
import 'package:shack/screens/Video/camera_screen.dart';
import 'package:shack/screens/Video/video_preview.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

import '../../themes/theme.dart';

class MakeVideo extends StatefulWidget {
  final AppUser? currentUser;

  MakeVideo(this.currentUser);

  @override
  MakeVideoState createState() => MakeVideoState();
}

class MakeVideoState extends State<MakeVideo> {
  final _cameraKey = GlobalKey<CameraScreenState>();
  bool checkvideo = false;
  late String videopath;
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    checkVideoFile();
  }

  Future<void> checkVideoFile() async {
    final Directory extDir = await getTemporaryDirectory();
    final String dirPath = '${extDir.path}/media';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/profile.mp4';

    if (await File(filePath).exists()) {
      int size = await File(filePath).length();
      print(size);
      setState(() {
        videopath = filePath;
        _controller = VideoPlayerController.file(File(videopath))..initialize().then((_) => setState(() {}));
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
            child: Column(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
              SizedBox(
                height: mediaQueryData.padding.top + 20,
              ),
              ElevatedButton(
                  onPressed: () {
                    pushNewScreenWithRouteSettings(context,
                        screen: CameraScreen(
                            key: _cameraKey,
                            onCheckVideoFile: () {
                              checkVideoFile();
                            }),
                        withNavBar: false,
                        pageTransitionAnimation: PageTransitionAnimation.cupertino,
                        settings: RouteSettings());
                  },
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      'Capture Video',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                  )),
              checkvideo
                  ? Column(
                      children: <Widget>[
                        VideoPreview(controller: _controller),
                        ElevatedButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    uploadFile(File(videopath), widget.currentUser!);
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
                                'Upload Video',
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                                textAlign: TextAlign.center,
                              ),
                            )),
                        SizedBox(height: 30)
                      ],
                    )
                  : Container()
            ]),
          )),
    );
  }

  Future uploadFile(File image, AppUser currentUser) async {
    await VideoCompress.deleteAllCache();
    final info = await (VideoCompress.compressVideo(
      image.path,
      quality: VideoQuality.HighestQuality,
      deleteOrigin: false,
      includeAudio: true,
    ));
    Reference storageReference = FirebaseStorage.instance.ref().child('users/${currentUser.id}/profile.mp4');
    UploadTask uploadTask =
        storageReference.putFile(File(info!.path!), SettableMetadata(contentType: 'video/mp4'));
    uploadTask.whenComplete(() {
      storageReference.getDownloadURL().then((fileURL) async {
        if (mounted)
          setState(() {
            if (currentUser.imageUrl == null) {
              currentUser.imageUrl = [];
            }
            currentUser.imageUrl!.add(fileURL);
          });
        Map<String, dynamic> updateObject = {
          'video': fileURL,
        };
        try {
          await FirebaseFirestore.instance
              .collection("Users")
              .doc(currentUser.id)
              .set(updateObject, SetOptions(merge: true));
          Navigator.of(context, rootNavigator: true).pop('dialog');
        } catch (err) {}
      });
    });
  }
}
