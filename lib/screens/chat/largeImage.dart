import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LargeImage extends StatelessWidget {
  final largeImage;
  LargeImage(this.largeImage);

  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    return Scaffold(
        appBar: AppBar(
            elevation: 0,
            automaticallyImplyLeading: false,
            backgroundColor: _theme.backgroundColor),
        backgroundColor: _theme.backgroundColor,
        body: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50)),
                color: Colors.white),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50.0),
                topRight: Radius.circular(50.0),
              ),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      CachedNetworkImage(
                        fit: BoxFit.contain,
                        placeholder: (context, url) => Center(
                          child: CupertinoActivityIndicator(
                            radius: 20,
                          ),
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                        height: MediaQuery.of(context).size.height * .75,
                        width: MediaQuery.of(context).size.width,
                        imageUrl: largeImage,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      FloatingActionButton(
                          backgroundColor: _theme.backgroundColor,
                          child: Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context)),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
            )));
  }
}
