import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_restaurant/data/model/response/signup_model.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/provider/auth_provider.dart';
import 'package:flutter_restaurant/provider/theme_provider.dart';
import 'package:flutter_restaurant/provider/wishlist_provider.dart';
import 'package:flutter_restaurant/utill/routes.dart';
import 'package:flutter_restaurant/view/base/custom_snackbar.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

class LoginOtpScreen extends StatefulWidget {
  String phone;
  LoginOtpScreen({this.phone});

  @override
  _LoginOtpScreenState createState() => _LoginOtpScreenState();
}

class _LoginOtpScreenState extends State<LoginOtpScreen> {
  ConfirmationResult confirmationResult;
  var _seconds=60;
  var isOtpSend = false;
  var _secondsInString = "";
  Timer _timer;
  TextEditingController otpCtl =TextEditingController();
  String verificationId="";
  FirebaseAuth _auth;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    otpCtl=TextEditingController();
    _auth=FirebaseAuth.instance;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _initFirebase(context);
    });
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    otpCtl.dispose();
   }
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
        builder: (context, authProvider, child) =>Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics:const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              getTranslated('otp_verification', context)
                  .text
                  .bold
                  .size(25)
                  .makeCentered().p(10),
              VxCard(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  "${getTranslated('enter_the_otp_sent_to',context)} ${widget.phone}".text
                      .bold
                      .size(14)
                      .make().pOnly(top: 10,left: 10),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        maxHeight: 45, minHeight: 45),
                    child: TextFormField(
                      controller: otpCtl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          filled: true,
                          labelText: getTranslated('otp',context),
                          labelStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w200,
                              color: Theme.of(context).accentColor),
                          hintText: getTranslated('enter_otp',context),
                          hintStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w200),
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(7)),
                              borderSide: BorderSide(
                                  width: 1,
                                  color: Theme.of(context).primaryColor))),
                    ).pOnly(left: 10,right: 10,top: 16),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      getTranslated('did_nt_receive_otp',context).text
                          .medium
                          .size(12)
                          .make(),
                      "${getTranslated('resend_otp',context)} $_secondsInString".text
                          .bold
                          .color(isOtpSend ? Theme.of(context).primaryColor : Theme.of(context).primaryColor.withOpacity(0.3))
                          .size(12)
                          .make().onTap((){
                        if (isOtpSend) {
                          _seconds = 60;
                          _secondsInString = "";
                          isOtpSend = false;
                          resendOtp(context);
                        }
                      }),
                    ],
                  ).pOnly(top: 12,left: 10,right: 10),
                  MaterialButton(
                    minWidth: 170,
                    onPressed: () {
                      if(otpCtl.text.length==6)
                        {
                          verifyOtp(PhoneAuthProvider.credential(verificationId: verificationId, smsCode: otpCtl.text),context);
                        }
                      else
                        {
                          showCustomSnackBar(getTranslated('please_enter_6_digit_code', context), context);
                        }
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    child: getTranslated('verify',context)
                        .toUpperCase()
                        .text
                        .color(Colors.white)
                        .make(),
                    color: Theme.of(context).primaryColor,
                    height: 45,
                  ).objectCenter().pOnly(top:20,bottom: 30),
                ],
              ).p(10)).withRounded(value: 12)
                  .color(Colors.white)
                  .elevation(7)
                  .make().w(double.infinity).pOnly(left: 10,right: 10,top: 10)
            ],
          ),
        ),
      ),
    ));
  }

  void _initFirebase(BuildContext context) async{
    EasyLoading.show(status: 'loading...');
    if (!kIsWeb) {
      await _auth.verifyPhoneNumber(
            phoneNumber: "+"+widget.phone,
            timeout: Duration(seconds: 60),
            verificationCompleted: (PhoneAuthCredential credential) {
              EasyLoading.dismiss();
              if(credential.smsCode!=null)
                otpCtl.text=credential.smsCode;
              verifyOtp(credential,context);
            },
            verificationFailed: (FirebaseAuthException e) {
              print(e.message);
              EasyLoading.dismiss();
              showCustomSnackBar(e.message, context);
            },
            codeSent: (String verificationId, int resendToken) {
              this.verificationId=verificationId;
              EasyLoading.dismiss();
              startTimer();
            },
            codeAutoRetrievalTimeout: (String verificationId) {
              EasyLoading.dismiss();
            },
          );
    }
    else
      {
        confirmationResult = await _auth.signInWithPhoneNumber("+"+widget.phone,RecaptchaVerifier(
          container: 'recaptcha',
          size: RecaptchaVerifierSize.compact,
          theme: RecaptchaVerifierTheme.dark,
          // theme: Provider.of<ThemeProvider>(context).darkTheme?RecaptchaVerifierTheme.dark:RecaptchaVerifierTheme.light,
          onSuccess: () {
            EasyLoading.dismiss();
            startTimer();
          },
          onError: (FirebaseAuthException error) {
            EasyLoading.dismiss();
            showCustomSnackBar(error.message, context);
          },
          onExpired: () {

          },
        ));
      }
  }

  verifyOtp(PhoneAuthCredential credential,BuildContext context)async {
    EasyLoading.show(status: 'loading...');
    if (kIsWeb) {
      confirmationResult.confirm(otpCtl.text).then((value) {
        var authProvider=Provider.of<AuthProvider>(context,listen: false);
        authProvider.login(widget.phone).then((status) async {
          if (status.isSuccess) {

            if (authProvider.isActiveRememberMe) {
              authProvider.saveUserNumber(widget.phone);
            } else {
              authProvider.clearUserNumberAndPassword();
            }
            await Provider.of<WishListProvider>(context, listen: false).initWishList(context);
            Navigator.pushNamedAndRemoveUntil(context, Routes.getMainRoute(), (route) => false);
          }
          else
          {
            showCustomSnackBar(authProvider.loginErrorMessage, context);
          }
        }).onError((error, stackTrace){
          showCustomSnackBar(error.toString(), context);
        }).whenComplete(() => EasyLoading.dismiss());
      }).onError((error, stackTrace) {
        EasyLoading.dismiss();
        showCustomSnackBar(error.toString(), context);
      });
    }
    else {
      _auth.signInWithCredential(credential).then((value) {
        var authProvider=Provider.of<AuthProvider>(context,listen: false);
       authProvider.login(widget.phone).then((status) async {
          if (status.isSuccess) {

            if (authProvider.isActiveRememberMe) {
              authProvider.saveUserNumber(widget.phone);
            } else {
              authProvider.clearUserNumberAndPassword();
            }
            await Provider.of<WishListProvider>(context, listen: false).initWishList(context);
            Navigator.pushNamedAndRemoveUntil(context, Routes.getMainRoute(), (route) => false);
          }
          else
            {
              showCustomSnackBar(authProvider.loginErrorMessage, context);
            }
        }).onError((error, stackTrace){
          showCustomSnackBar(error.toString(), context);
        }).whenComplete(() => EasyLoading.dismiss());
      }).catchError((e) {
        EasyLoading.dismiss();
        print(e.toString());
        showCustomSnackBar(e.toString(), context);
      });
    }
  }

  resendOtp(BuildContext context) {
    _initFirebase(context);
  }
  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_seconds == 0) {
        setState(() {
          isOtpSend = true;
          _secondsInString = "";
          _timer.cancel();
        });
      } else {
        if(this.mounted)
        setState(() {
          _seconds--;
          if (_seconds < 10)
            _secondsInString = "00:0$_seconds";
          else
            _secondsInString = "00:$_seconds";
        });
      }
    });
  }
}
