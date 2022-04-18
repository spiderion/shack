import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shack/screens/phonesign/otp_verification.dart';
import 'package:shack/screens/util/custom_snackbar.dart';
import 'package:shack/screens/welcome.dart';

class OTP extends StatefulWidget {
  final bool updateNumber;

  OTP(this.updateNumber);

  @override
  _OTPState createState() => _OTPState();
}

class _OTPState extends State<OTP> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool cont = false;
  String? _smsVerificationCode;
  String? countryCode = '+44';
  TextEditingController phoneNumController = new TextEditingController();
  WelcomePage _login = new WelcomePage();

  @override
  void dispose() {
    super.dispose();
    cont = false;
  }

  /// method to verify phone number and handle phone auth
  Future _verifyPhoneNumber(String phoneNumber) async {
    phoneNumber = countryCode! + phoneNumber.toString();
    print(phoneNumber);
    final FirebaseAuth _auth = FirebaseAuth.instance;
    await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: Duration(seconds: 30),
        verificationCompleted: (authCredential) => _verificationComplete(authCredential, context),
        verificationFailed: (authException) => _verificationFailed(authException, context),
        codeAutoRetrievalTimeout: (verificationId) => _codeAutoRetrievalTimeout(verificationId),
        // called when the SMS code is sent
        codeSent: (verificationId, [code]) => _smsCodeSent(verificationId, [code]));
  }

  Future updatePhoneNumber() async {
    print("here");
    User user = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(user.uid)
        .set({'phoneNumber': user.phoneNumber}, SetOptions(merge: true)).then((_) {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (_) {
            Future.delayed(Duration(seconds: 2), () async {
              // Navigator.pop(context);
              // Navigator.pushReplacement(context,
              //     MaterialPageRoute(builder: (context) => Tabbar(null, null)));
            });
            return Center(
                child: Container(
                    width: 180.0,
                    height: 200.0,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      children: <Widget>[
                        Image.asset(
                          "assets/images/verified.jpg",
                          height: 100,
                        ),
                        Text(
                          "Phone Number\nChanged\nSuccessfully",
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(decoration: TextDecoration.none, color: Colors.black, fontSize: 20),
                        )
                      ],
                    )));
          });
    });
  }

  /// will get an AuthCredential object that will help with logging into Firebase.
  _verificationComplete(AuthCredential authCredential, BuildContext context) async {
    if (widget.updateNumber) {
      User user = FirebaseAuth.instance.currentUser!;
      user
          .updatePhoneNumber(authCredential as PhoneAuthCredential)
          .then((_) => updatePhoneNumber())
          .catchError((e) {
        CustomSnackbar.snackbar("$e", _scaffoldKey);
      });
    } else {
      FirebaseAuth.instance.signInWithCredential(authCredential).then((authResult) async {
        print(authResult.user!.uid);
        //snackbar("Success!!! UUID is: " + authResult.user.uid);
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (_) {
              Future.delayed(Duration(seconds: 2), () async {
                Navigator.pop(context);
                await _login.navigationCheck(authResult.user!, context);
              });
              return Center(
                  child: Container(
                      width: 150.0,
                      height: 160.0,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        children: <Widget>[
                          Text(
                            "Verified\n Successfully",
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(decoration: TextDecoration.none, color: Colors.black, fontSize: 20),
                          )
                        ],
                      )));
            });
        await FirebaseFirestore.instance
            .collection('Users')
            .where('userId', isEqualTo: authResult.user!.uid)
            .get()
            .then((QuerySnapshot snapshot) async {
          if (snapshot.docs.length <= 0) {
            await setDataUser(authResult.user!);
          }
        });
      });
    }
  }

  _smsCodeSent(String verificationId, List<int?> code) async {
    // set the verification code so that we can use it to log the user in
    _smsVerificationCode = verificationId;
    final ThemeData _theme = Theme.of(context);
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) {
          Future.delayed(Duration(seconds: 2), () {
            Navigator.pop(context);
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => Verification(
                        countryCode! + phoneNumController.text, _smsVerificationCode, widget.updateNumber)));
          });
          return Center(

              // Aligns the container to center
              child: Container(
                  // A simplified version of dialog.
                  width: 300.0,
                  height: 150.0,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    children: <Widget>[
                      Image.asset(
                        "assets/images/verified.jpg",
                        height: 60,
                        color: _theme.primaryColor,
                        colorBlendMode: BlendMode.color,
                      ),
                      Text(
                        "Please check your messages for a verification code",
                        textAlign: TextAlign.center,
                        style: TextStyle(decoration: TextDecoration.none, color: Colors.black, fontSize: 20),
                      )
                    ],
                  )));
        });
  }

  _verificationFailed(FirebaseAuthException authException, BuildContext context) {
    CustomSnackbar.snackbar("Exception!! message:" + authException.message.toString(), _scaffoldKey);
  }

  _codeAutoRetrievalTimeout(String verificationId) {
    // set the verification code so that we can use it to log the user in
    _smsVerificationCode = verificationId;
    print("timeout $_smsVerificationCode");
  }

  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("Verify Phone"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ListTile(
                title: Text(
                  "Verify Your Number",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
                ),
                subtitle: Text(
                  r"""Please enter Your mobile Number to
receive a verification code. Message and data 
rates may apply.""",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.black),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
                  child: ListTile(
                      leading: Container(
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(width: 1.0, color: Theme.of(context).primaryColor))),
                        child: CountryCodePicker(
                          onChanged: (value) {
                            countryCode = value.dialCode;
                          },
                          initialSelection: 'GB',
                          favorite: [countryCode!, 'GB'],
                          showCountryOnly: false,
                          showOnlyCountryWhenClosed: false,
                          alignLeft: false,
                        ),
                      ),
                      title: Container(
                        child: TextFormField(
                          keyboardType: TextInputType.phone,
                          style: TextStyle(fontSize: 20),
                          cursorColor: Colors.black,
                          controller: phoneNumController,
                          onChanged: (value) {
                            cont = true;
                            setState(() {});
                          },
                          decoration: InputDecoration(
                            hintText: "Enter your number",
                            hintStyle: TextStyle(fontSize: 18),
                            focusColor: Theme.of(context).primaryColor,
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).primaryColor)),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).primaryColor)),
                          ),
                        ),
                      ))),
              cont
                  ? Container(
                      width: double.infinity,
                      height: 50,
                      margin: EdgeInsets.all(25),
                      child: ElevatedButton(
                          onPressed: () async {
                            showDialog(
                              builder: (context) {
                                Future.delayed(Duration(seconds: 1), () {
                                  Navigator.pop(context);
                                });
                                return Center(
                                    child: CupertinoActivityIndicator(
                                  radius: 20,
                                ));
                              },
                              barrierDismissible: false,
                              context: context,
                            );
                            await _verifyPhoneNumber(phoneNumController.text);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              'Continue',
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                              textAlign: TextAlign.center,
                            ),
                          )),
                    )
                  : Container(
                      width: double.infinity,
                      height: 50,
                      margin: EdgeInsets.all(25),
                      child: ElevatedButton(
                          onPressed: () {
                            print('on pressed newely added');
                          },
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              'Continue',
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                              textAlign: TextAlign.center,
                            ),
                          )),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

Future setDataUser(User user) async {
  await FirebaseFirestore.instance.collection("Users").doc(user.uid).set({
    'userId': user.uid,
    'phoneNumber': user.phoneNumber,
    'timestamp': FieldValue.serverTimestamp(),

    // 'name': user.displayName,
    // 'pictureUrl': user.photoUrl,
  }, SetOptions(merge: true));
}
