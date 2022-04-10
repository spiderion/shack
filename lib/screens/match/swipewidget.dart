import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grid/models/answer_model.dart';
import 'package:flutter_grid/models/question_model.dart';
import 'package:flutter_grid/models/user_model.dart';
import 'package:flutter_grid/screens/Tab.dart';
import 'package:flutter_grid/screens/util/color.dart';

class SwipeWidget extends StatefulWidget {
  final User currentUser;
  final User user;

  SwipeWidget(
    this.user,
    this.currentUser,
  );

  @override
  _SwipeWidget createState() => _SwipeWidget();
}

class _SwipeWidget extends State<SwipeWidget> {
  int tabindex = 0;

  List<Answer_model> myanswer = [];
  List<Answer_model> useranswer = [];
  List followedUser = [];
  List followingUser = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getanswerlist();
    getfollowlist();
  }
  @override
  Widget build(BuildContext context) {
    //  if()

    //matches.any((value) => value.id == user.id);
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    final ThemeData _theme = Theme.of(context);
    bool check_follow = false;
    for(int i= 0; i < followedUser.length; i++){
      if(followedUser[i] == widget.currentUser.id)
        check_follow = true;
    }
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text(
                        "${widget.user.name}, ${widget.user.age}",
                        style: TextStyle(
                            color: _theme.backgroundColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w900),
                      ),
                      Text(
                        "${widget.user.editInfo['DistanceVisible'] != null ? widget.user.editInfo['DistanceVisible'] ? 'Less than ${widget.user.distanceBW} KM away' : 'Distance not visible' : 'Less than ${widget.user.distanceBW} KM away'}",
                        style: TextStyle(
                            color: primaryColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(left: 3, right: 3),
                        child: Text(
                          '1\nPosts',
                          style: TextStyle(
                              color: primaryColor, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 3, right: 3),
                        child: Text(
                          '${followedUser.length}\nFollowers',
                          style: TextStyle(
                              color: primaryColor, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 3, right: 3),
                        child: Text(
                          '${followingUser.length}\nFollowing',
                          style: TextStyle(
                              color: primaryColor, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            Container(
              width: double.infinity,
              height: 50,
              margin: EdgeInsets.only(top: 10, bottom: 10),
              padding: EdgeInsets.only(left: 25, right: 25),
              child: FlatButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  color: primaryColor,
                  padding: EdgeInsets.all(8),
                  textColor: secondryColor,
                  onPressed: () {
                    if(check_follow){
                      unfollowuser();
                    } else{
                      followuser();
                    }
                  },
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      (check_follow? 'UNFOLLOW ': 'FOLLOW ') + widget.user.name,
                      style:
                          TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                  )),
            ),
            DefaultTabController(
              length: 3,
              child: Builder(
                builder: (BuildContext context) {
                  final TabController tabController =
                      DefaultTabController.of(context);
                  tabindex = DefaultTabController.of(context).index;
                  tabController.addListener(() {
                    if (!tabController.indexIsChanging) {
                      setState(() {});
                    }
                  });
                  return Column(
                    children: <Widget>[
                      TabBar(
                        tabs: <Widget>[
                          Tab(
                            icon: Icon(
                              Icons.image,
                              color: tabindex == 0 ? primaryColor : Colors.grey,
                            ),
                          ),
                          Tab(
                            icon: Icon(
                              Icons.check,
                              color: tabindex == 1 ? primaryColor : Colors.grey,
                            ),
                          ),
                          Tab(
                            icon: Icon(
                              Icons.clear,
                              color: tabindex == 2 ? primaryColor : Colors.grey,
                            ),
                          )
                        ],
                      ),
                      Container(
                        height: mediaQueryData.size.width,
                        width: mediaQueryData.size.width,
                        child: TabBarView(
                          children: <Widget>[
                            profileimage(),
                            answerview(),
                            ignoreview()
                          ],
                        ),
                      )
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  profileimage() {
    return Container(
      child: GridView.count(
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          padding: EdgeInsets.only(top: 10, left: 10, right: 10),
          children: List.generate(9, (index) {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: widget.user.imageUrl.length > index
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
                      widget.user.imageUrl.length > index
                          ? CachedNetworkImage(
                              height: MediaQuery.of(context).size.height * .2,
                              fit: BoxFit.cover,
                              imageUrl: widget.user.imageUrl[index],
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
                    ],
                  ),
                ),
              ),
            );
          })),
    );
  }

  answerview() {
    List<Question_model> temp = [];
    for(int i = 0; i < questions.length; i++){
      if(myanswer.length > i && useranswer.length > i){
        if(myanswer[i].answer == useranswer[i].answer && useranswer[i].answer == true){
          temp.add(questions[i]);
        }
      }
    }
    return Container(
        padding: EdgeInsets.all(30),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              widget.user.editInfo['about'] != null
                  ? Text(
                "${widget.user.editInfo['about']}",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
                textAlign: TextAlign.start,
              )
                  : Container(),
              for(int i = 0; i < temp.length; i++)
                Container(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: Row(
                    children: <Widget>[
                      Container(
                        height: 30,
                        width: 30,
                        margin: EdgeInsets.only(right: 5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border:
                            Border.all(color: primaryColor),
                            color: primaryColor),
                        child: Center(
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                      Text(
                          temp[i].title
                      )
                    ],

                  ),
                )
            ],
          ),
        )
    );
  }

  ignoreview() {
    List<Question_model> temp = [];
    for(int i = 0; i < questions.length; i++){
      if(myanswer.length > i && useranswer.length > i){
        if(myanswer[i].answer == useranswer[i].answer && useranswer[i].answer == false){
          temp.add(questions[i]);
        }
      }
    }
    return Container(
      padding: EdgeInsets.all(30),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            widget.user.editInfo['about'] != null
                ? Text(
              "${widget.user.editInfo['about']}",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.start,
            )
                : Container(),
            for(int i = 0; i < temp.length; i++)
              Container(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: Row(
                  children: <Widget>[
                    Container(
                      height: 30,
                      width: 30,
                      margin: EdgeInsets.only(right: 5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border:
                          Border.all(color: Colors.grey),
                          color: Colors.grey),
                      child: Center(
                        child: Icon(
                          Icons.clear,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                    Text(
                        temp[i].title
                    )
                  ],

                ),
              )
          ],
        ),
      )
    );
  }

  void getanswerlist() {

    Firestore.instance
        .collection('/Users/${widget.currentUser.id}/Questions').getDocuments().then((data) {

      List<Answer_model> tempanswer = [];

      data.documents.forEach((element) {
        Answer_model temp = Answer_model.fromDocument(element);
        tempanswer.add(temp);
      });
      print(questions.length );
      print(tempanswer.length);
      for(int i = 0; i < questions.length; i++){
        bool checkTemp = false;
        for(int j = 0; j < tempanswer.length; j++){

          if(questions[i].id == tempanswer[j].id){
            checkTemp = true;
            myanswer.insert(i, tempanswer[j]);

          }
        }
        if(!checkTemp){
          Answer_model tmp_model = Answer_model(answer: false, id: questions[i].id);
          myanswer.insert(i, tmp_model);
        }
        setState(() {

        });

      }
    });


    Firestore.instance
        .collection('/Users/${widget.user.id}/Questions').getDocuments().then((data) {

      List<Answer_model> tempanswer = [];

      data.documents.forEach((element) {
        Answer_model temp = Answer_model.fromDocument(element);
        tempanswer.add(temp);
      });
      print(questions.length );
      print(tempanswer.length);
      for(int i = 0; i < questions.length; i++){
        bool checkTemp = false;
        for(int j = 0; j < tempanswer.length; j++){

          if(questions[i].id == tempanswer[j].id){
            checkTemp = true;
            useranswer.insert(i, tempanswer[j]);

          }
        }
        if(!checkTemp){
          Answer_model tmp_model = Answer_model(answer: false, id: questions[i].id);
          useranswer.insert(i, tmp_model);
        }
        setState(() {

        });

      }
    });
  }

  void getfollowlist() {
    Firestore.instance.collection('Users/${widget.user.id}/followers').snapshots().listen((data) {
      followedUser.clear();
      followedUser.addAll(data.documents.map((f) => f['followers']));
      if(mounted)setState(() {

      });
    });
    Firestore.instance.collection('Users/${widget.user.id}/following').snapshots().listen((data) {
      followingUser.clear();
      followingUser.addAll(data.documents.map((f) => f['following']));
      if(mounted)setState(() {

      });
    });
  }

  void followuser() {
    Firestore.instance.collection('Users')
        .document(widget.user.id)
        .collection("followers")
        .document(widget.currentUser.id)
        .setData(
      {
        'followers': widget.currentUser.id,
      },
    );
    Firestore.instance.collection('Users')
        .document(widget.currentUser.id)
        .collection("following")
        .document(widget.user.id)
        .setData(
      {
        'following': widget.user.id,
      },
    );
  }

  void unfollowuser() {
    Firestore.instance.collection('Users')
        .document(widget.user.id)
        .collection("followers")
        .document(widget.currentUser.id)
        .delete();
    Firestore.instance.collection('Users')
        .document(widget.currentUser.id)
        .collection("following")
        .document(widget.user.id)
        .delete();
  }

}
