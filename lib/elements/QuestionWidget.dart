import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grid/models/question_model.dart';
import 'package:flutter_grid/screens/questions/Write_answer.dart';

// ignore: must_be_immutable
class QuestionWidget extends StatelessWidget {
  Question_model? model;

  QuestionWidget({Key? key, this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediadata = MediaQuery.of(context);
    return Container(
        width: mediadata.size.width - 100,
        margin: EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
                color: Theme.of(context).focusColor.withOpacity(0.1),
                blurRadius: 15,
                offset: Offset(0, 5)),
          ],
        ),
        child: Stack(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              child: CachedNetworkImage(
                height: double.infinity,
                width: double.infinity,
                fit: BoxFit.cover,
                imageUrl: model!.img!,
                placeholder: (context, url) => Image.asset(
                  'assets/loading.gif',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 150,
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
            Positioned(
              top: 50,
              left: 20,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    model!.title!,
                    style: TextStyle(color: Colors.black, fontSize: 30),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    model!.text!,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 20
                    ),
                  )
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              left: 30,
              child: FlatButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  color: Theme.of(context).backgroundColor,
                  padding: EdgeInsets.all(8),
                  textColor: Theme.of(context).primaryColor,
                  onPressed: (){
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => Write_answer(
                          model: model,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    alignment: Alignment.center,
                    child: Text('Answer',
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15
                      ),
                      textAlign: TextAlign.center,),
                  )
              ),
            )
          ],
        ));
  }
}
