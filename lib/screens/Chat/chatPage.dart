import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grid/models/user_model.dart';
import 'package:flutter_grid/screens/Calling/dial.dart';
import 'package:flutter_grid/screens/Calling/utils/settings.dart';
import 'package:flutter_grid/screens/Chat/largeImage.dart';
import 'package:flutter_grid/screens/match/Information.dart';
import 'package:flutter_grid/screens/util/CustomSnackbar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatPage extends StatefulWidget {
  final AppUser? sender;
  final String? chatId;
  final AppUser? second;

  ChatPage({this.sender, this.chatId, this.second});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool isBlocked = false;
  final db = FirebaseFirestore.instance;
  late CollectionReference chatReference;
  final TextEditingController _textController = new TextEditingController();
  bool _isWritting = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    print("object    -${widget.chatId}");
    super.initState();
    chatReference = db.collection("chats").doc(widget.chatId).collection('messages');
    checkblock();
  }

  var blockedBy;

  checkblock() {
    chatReference.doc('blocked').snapshots().listen((onData) {
      if (onData.data != null) {
        blockedBy = (onData.data() as Map<String, dynamic>)['blockedBy'];
        if ((onData.data() as Map<String, dynamic>)['isBlocked']) {
          isBlocked = true;
        } else {
          isBlocked = false;
        }

        if (mounted) setState(() {});
      }
      // print(onData.data['blockedBy']);
    });
  }

  List<Widget> generateSenderLayout(DocumentSnapshot documentSnapshot) {
    final ThemeData _theme = Theme.of(context);
    return <Widget>[
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Container(
              child: (documentSnapshot.data() as Map<String, dynamic>)['image_url'] != ''
                  ? InkWell(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          new Container(
                            margin: EdgeInsets.only(top: 2.0, bottom: 2.0, right: 15),
                            child: Stack(
                              children: <Widget>[
                                CachedNetworkImage(
                                  placeholder: (context, url) => Center(
                                    child: CupertinoActivityIndicator(
                                      radius: 10,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                  height: MediaQuery.of(context).size.height * .65,
                                  width: MediaQuery.of(context).size.width * .9,
                                  imageUrl: (documentSnapshot.data() as Map<String, dynamic>)['image_url'],
                                  fit: BoxFit.fitWidth,
                                ),
                                Container(
                                  alignment: Alignment.bottomRight,
                                  child: (documentSnapshot.data() as Map<String, dynamic>)['isRead'] == false
                                      ? Icon(
                                          Icons.done,
                                          color: _theme.backgroundColor,
                                          size: 15,
                                        )
                                      : Icon(
                                          Icons.done_all,
                                          color: _theme.primaryColor,
                                          size: 15,
                                        ),
                                )
                              ],
                            ),
                            height: 150,
                            width: 150.0,
                            color: _theme.backgroundColor.withOpacity(.5),
                            padding: EdgeInsets.all(5),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Text(
                                (documentSnapshot.data() as Map<String, dynamic>)["time"] != null
                                    ? DateFormat.yMMMd()
                                        .add_jm()
                                        .format((documentSnapshot.data() as Map<String, dynamic>)["time"]
                                            .toDate())
                                        .toString()
                                    : "",
                                style: TextStyle(
                                  color: _theme.backgroundColor,
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w600,
                                )),
                          )
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (context) => LargeImage(
                              (documentSnapshot.data() as Map<String, dynamic>)['image_url'],
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                      width: MediaQuery.of(context).size.width * 0.65,
                      margin: EdgeInsets.only(top: 8.0, bottom: 8.0, left: 80.0, right: 10),
                      decoration: BoxDecoration(
                          color: _theme.primaryColor.withOpacity(.1),
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  child: Text(
                                    (documentSnapshot.data() as Map<String, dynamic>)['text'],
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Text(
                                    (documentSnapshot.data() as Map<String, dynamic>)["time"] != null
                                        ? DateFormat.MMMd()
                                            .add_jm()
                                            .format((documentSnapshot.data() as Map<String, dynamic>)["time"]
                                                .toDate())
                                            .toString()
                                        : "",
                                    style: TextStyle(
                                      color: _theme.backgroundColor,
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  (documentSnapshot.data() as Map<String, dynamic>)['isRead'] == false
                                      ? Icon(
                                          Icons.done,
                                          color: _theme.backgroundColor,
                                          size: 15,
                                        )
                                      : Icon(
                                          Icons.done_all,
                                          color: _theme.primaryColor,
                                          size: 15,
                                        )
                                ],
                              ),
                            ],
                          ),
                        ],
                      )),
            ),
          ],
        ),
      ),
    ];
  }

  _messagesIsRead(documentSnapshot) {
    final ThemeData _theme = Theme.of(context);
    return <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InkWell(
            child: CircleAvatar(
              backgroundColor: _theme.backgroundColor,
              radius: 25.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(90),
                child: CachedNetworkImage(
                  imageUrl: widget.second!.imageUrl![0],
                  useOldImageOnUrlChange: true,
                  placeholder: (context, url) => CupertinoActivityIndicator(
                    radius: 15,
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
            onTap: () => showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) {
                  return Info(widget.second, widget.sender, null);
                }),
          ),
        ],
      ),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: documentSnapshot.data['image_url'] != ''
                  ? InkWell(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          new Container(
                            margin: EdgeInsets.only(top: 2.0, bottom: 2.0, right: 15),
                            child: CachedNetworkImage(
                              placeholder: (context, url) => Center(
                                child: CupertinoActivityIndicator(
                                  radius: 10,
                                ),
                              ),
                              errorWidget: (context, url, error) => Icon(Icons.error),
                              height: MediaQuery.of(context).size.height * .65,
                              width: MediaQuery.of(context).size.width * .9,
                              imageUrl: documentSnapshot.data['image_url'],
                              fit: BoxFit.fitWidth,
                            ),
                            height: 150,
                            width: 150.0,
                            color: Color.fromRGBO(0, 0, 0, 0.2),
                            padding: EdgeInsets.all(5),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Text(
                                documentSnapshot.data["time"] != null
                                    ? DateFormat.yMMMd()
                                        .add_jm()
                                        .format(documentSnapshot.data["time"].toDate())
                                        .toString()
                                    : "",
                                style: TextStyle(
                                  color: _theme.backgroundColor,
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w600,
                                )),
                          )
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).push(CupertinoPageRoute(
                          builder: (context) => LargeImage(
                            documentSnapshot.data['image_url'],
                          ),
                        ));
                      },
                    )
                  : Container(
                      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                      width: MediaQuery.of(context).size.width * 0.65,
                      margin: EdgeInsets.only(top: 8.0, bottom: 8.0, right: 10),
                      decoration: BoxDecoration(
                          color: _theme.backgroundColor.withOpacity(.3),
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  child: Text(
                                    documentSnapshot.data['text'],
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Text(
                                    documentSnapshot.data["time"] != null
                                        ? DateFormat.MMMd()
                                            .add_jm()
                                            .format(documentSnapshot.data["time"].toDate())
                                            .toString()
                                        : "",
                                    style: TextStyle(
                                      color: _theme.backgroundColor,
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      )),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> generateReceiverLayout(DocumentSnapshot documentSnapshot) {
    if (!(documentSnapshot.data() as Map<String, dynamic>)['isRead']) {
      chatReference.doc(documentSnapshot.id).update({
        'isRead': true,
      });

      return _messagesIsRead(documentSnapshot);
    }
    return _messagesIsRead(documentSnapshot);
  }

  generateMessages(AsyncSnapshot<QuerySnapshot> snapshot) {
    return snapshot.data!.docs
        .map<Widget>((doc) => Container(
              margin: const EdgeInsets.symmetric(vertical: 10.0),
              child: new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: (doc.data() as Map<String, dynamic>)['type'] == "Call"
                      ? [
                          Text((doc.data() as Map<String, dynamic>)["time"] != null
                              ? "${(doc.data() as Map<String, dynamic>)['text']} : " +
                                  DateFormat.yMMMd()
                                      .add_jm()
                                      .format((doc.data() as Map<String, dynamic>)["time"].toDate())
                                      .toString() +
                                  " by ${(doc.data() as Map<String, dynamic>)['sender_id'] == widget.sender!.id ? "You" : "${widget.second!.name}"}"
                              : "")
                        ]
                      : (doc.data() as Map<String, dynamic>)['sender_id'] != widget.sender!.id
                          ? generateReceiverLayout(
                              doc,
                            )
                          : generateSenderLayout(doc)),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: _theme.backgroundColor,
          title: Text(widget.second!.name!),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            color: Colors.white,
            onPressed: () => Navigator.pop(context),
          ),
          actions: <Widget>[
            APP_ID.length > 0
                ? IconButton(icon: Icon(Icons.call), onPressed: () => onJoin("AudioCall"))
                : Container(),
            APP_ID.length > 0
                ? IconButton(icon: Icon(Icons.video_call), onPressed: () => onJoin("VideoCall"))
                : Container(),
            PopupMenuButton(itemBuilder: (ct) {
              return [
                PopupMenuItem(
                  height: 20,
                  value: 1,
                  child: InkWell(
                    child: Text(isBlocked ? "Unblock user" : "Block user"),
                    onTap: () {
                      Navigator.pop(ct);
                      showDialog(
                        context: context,
                        builder: (BuildContext ctx) {
                          return AlertDialog(
                            title: Text(isBlocked ? 'Unblock' : 'Block'),
                            content: Text(
                                'Do you want to ${isBlocked ? 'Unblock' : 'Block'} ${widget.second!.name}?'),
                            actions: <Widget>[
                              FlatButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: Text('No'),
                              ),
                              FlatButton(
                                onPressed: () async {
                                  Navigator.pop(ctx);
                                  if (isBlocked && blockedBy == widget.sender!.id) {
                                    chatReference.doc('blocked').set({
                                      'isBlocked': !isBlocked,
                                      'blockedBy': widget.sender!.id,
                                    });
                                  } else if (!isBlocked) {
                                    chatReference.doc('blocked').set({
                                      'isBlocked': !isBlocked,
                                      'blockedBy': widget.sender!.id,
                                    });
                                  } else
                                    print("You can't unblock");
                                },
                                child: Text('Yes'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                )
              ];
            })
          ]),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: _theme.backgroundColor,
          body: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50.0),
              topRight: Radius.circular(50.0),
            ),
            child: Container(
              decoration: BoxDecoration(
                  // image: DecorationImage(
                  //     fit: BoxFit.fitWidth,
                  //     image: AssetImage("asset/chat.jpg")),
                  borderRadius:
                      BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50)),
                  color: Colors.white),
              padding: EdgeInsets.all(5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  StreamBuilder<QuerySnapshot>(
                    stream: chatReference.orderBy('time', descending: true).snapshots(),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData)
                        return Container(
                          height: 15,
                          width: 15,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(_theme.primaryColor),
                            strokeWidth: 2,
                          ),
                        );
                      return Expanded(
                        child: ListView(
                          reverse: true,
                          children: generateMessages(snapshot),
                        ),
                      );
                    },
                  ),
                  Divider(height: 1.0),
                  Container(
                    alignment: Alignment.bottomCenter,
                    decoration: BoxDecoration(color: Theme.of(context).cardColor),
                    child: isBlocked ? Text("Sorry You can't send message!") : _buildTextComposer(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getDefaultSendButton() {
    return IconButton(
      icon: Transform.rotate(
        angle: -pi / 9,
        child: Icon(
          Icons.send,
          size: 25,
        ),
      ),
      color: Theme.of(context).primaryColor,
      onPressed: _isWritting ? () => _sendText(_textController.text.trimRight()) : null,
    );
  }

  Widget _buildTextComposer() {
    ThemeData _theme = Theme.of(context);
    return IconTheme(
        data: IconThemeData(color: _isWritting ? _theme.primaryColor : _theme.backgroundColor),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(horizontal: 4.0),
                child: IconButton(
                    icon: Icon(
                      Icons.photo_camera,
                      color: _theme.backgroundColor,
                    ),
                    onPressed: () async {
                      XFile imageFile = (await ImagePicker().pickImage(source: ImageSource.gallery))!;
                      int timestamp = new DateTime.now().millisecondsSinceEpoch;
                      final storageReference = FirebaseStorage.instance
                          .ref()
                          .child('chats/${widget.chatId}/img_' + timestamp.toString() + '.jpg');
                      UploadTask uploadTask = storageReference.putFile(File(imageFile.path));
                      await uploadTask.whenComplete(() async {
                        String fileUrl = await storageReference.getDownloadURL();
                        _sendImage(messageText: 'Photo', imageUrl: fileUrl);
                      });
                    }),
              ),
              new Flexible(
                child: new TextField(
                  controller: _textController,
                  maxLines: 15,
                  minLines: 1,
                  autofocus: false,
                  onChanged: (String messageText) {
                    setState(() {
                      _isWritting = messageText.trim().length > 0;
                    });
                  },
                  decoration: new InputDecoration.collapsed(
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      // border: OutlineInputBorder(
                      //     borderRadius: BorderRadius.circular(18)),
                      hintText: "Send a message..."),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                child: getDefaultSendButton(),
              ),
            ],
          ),
        ));
  }

  Future<Null> _sendText(String text) async {
    _textController.clear();
    chatReference.add({
      'type': 'Msg',
      'text': text,
      'sender_id': widget.sender!.id,
      'receiver_id': widget.second!.id,
      'isRead': false,
      'image_url': '',
      'time': FieldValue.serverTimestamp(),
    }).then((documentReference) {
      setState(() {
        _isWritting = false;
      });
    }).catchError((e) {});
  }

  void _sendImage({String? messageText, String? imageUrl}) {
    chatReference.add({
      'type': 'Image',
      'text': messageText,
      'sender_id': widget.sender!.id,
      'receiver_id': widget.second!.id,
      'isRead': false,
      'image_url': imageUrl,
      'time': FieldValue.serverTimestamp(),
    });
  }

  Future<void> onJoin(callType) async {
    if (!isBlocked) {
      // await for camera and mic permissions before pushing video page

      await handleCameraAndMic(callType);
      await chatReference.add({
        'type': 'Call',
        'text': callType,
        'sender_id': widget.sender!.id,
        'receiver_id': widget.second!.id,
        'isRead': false,
        'image_url': "",
        'time': FieldValue.serverTimestamp(),
      });

      // push video page with given channel name
   /*   await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              DialCall(channelName: widget.chatId, receiver: widget.second, callType: callType),
        ),
      );*/
    } else {
      CustomSnackbar.snackbar("Blocked !", _scaffoldKey);
    }
  }
}

Future<void> handleCameraAndMic(callType) async {
  await callType == "VideoCall"
      ? Future.wait([Permission.camera.request(), Permission.microphone.request()])
      : Permission.microphone.request();
}
