import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grid/screens/SignUp.dart';
import 'package:permission_handler/permission_handler.dart';

import '../core/location_ebr.dart';

class AllowLocation extends StatefulWidget {
  final Map<String, dynamic> userData;

  AllowLocation(this.userData);

  @override
  _AllowLocationState createState() => _AllowLocationState();
}

class _AllowLocationState extends State<AllowLocation> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text("Location"),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Column(children: <Widget>[
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Center(
                      child: CircleAvatar(
                        backgroundColor: _theme.backgroundColor.withOpacity(.2),
                        radius: 110,
                        child: Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 90,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(top: 0),
                      child: RichText(
                        text: TextSpan(
                          text: "Enable location",
                          style: TextStyle(color: Colors.black, fontSize: 40),
                          children: [
                            TextSpan(
                                text: """\nYou'll need to provide a
location
in order to search users around you.
                              """,
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: _theme.backgroundColor,
                                    textBaseline: TextBaseline.alphabetic,
                                    fontSize: 18)),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      )),
                  Padding(
                    padding: const EdgeInsets.all(50.0),
                    // child: FlatButton.icon(
                    //     onPressed: null,
                    //     icon: Icon(Icons.arrow_drop_down),
                    //     label: Text("Show more")),
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                height: 50,
                margin: EdgeInsets.only(top: 10, bottom: 10, left: 25, right: 25),
                child: FlatButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    color: _theme.backgroundColor,
                    padding: EdgeInsets.all(8),
                    textColor: _theme.primaryColor,
                    onPressed: () async {
                      if (!(await Permission.location.isGranted)) {
                        var status = await Permission.locationWhenInUse.request();
                        if (!status.isGranted) {
                          return;
                        }
                        await onPermissionsAllowed(context);
                        return;
                      }
                      await onPermissionsAllowed(context);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      child: Text('ALLOW LOCATION',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                          textAlign: TextAlign.center),
                    )),
              ),
            ]),
          ),
        ));
  }

  Future<void> onPermissionsAllowed(BuildContext context) async {
    LocationEBR locationEBR = LocationEBR();
    LocationInfo? locationInfo = await locationEBR.getLocationData();
    widget.userData.addAll(
      {
        'location': {
          'latitude': locationInfo?.locationData.latitude,
          'longitude': locationInfo?.locationData.longitude,
          'address':
              "${locationInfo?.address.locality} ${locationInfo?.address.subLocality} ${locationInfo?.address.subAdminArea}\n ${locationInfo?.address.countryName} ,${locationInfo?.address.postalCode}"
        },
        'maximum_distance': 20,
        'age_range': {
          'min': "20",
          'max': "50",
        },
      },
    );
    widget.userData.addAll({
      'editInfo': {
        'university': "",
        'userGender': widget.userData['userGender'],
        'showOnProfile': widget.userData['showOnProfile']
      }
    });
    widget.userData.remove('showOnProfile');
    widget.userData.remove('userGender');
    Navigator.push(context, CupertinoPageRoute(builder: (context) => SignUp(widget.userData)));
  }
}
