import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shack/models/user_model.dart';
import 'package:shack/screens/phonesign/otp.dart';
import 'package:shack/screens/util/color.dart';
class UpdateNumber extends StatelessWidget {
  final AppUser currentUser;
  UpdateNumber(this.currentUser);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: Text(
          "Phone number settings",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: Container(

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text("Phone number",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            Card(
                child: ListTile(
                  title: Text(
                      currentUser.phoneNumber != null
                          ? "${currentUser.phoneNumber}"
                          : "Verify Phone number",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400)),
                  trailing: Icon(
                    currentUser.phoneNumber != null ? Icons.done : null,
                    color: primaryColor,
                  ),
                )),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Text("Verified phone number",
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: secondryColor)),
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Center(
                child: InkWell(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Text("Update my phone number",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: primaryColor)),
                    ),
                  ),
                  onTap: () => Navigator.push(context,
                      CupertinoPageRoute(builder: (context) => OTP(true))),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
