import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/provider/auth_provider.dart';
import 'package:flutter_restaurant/utill/color_resources.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/utill/routes.dart';
import 'package:flutter_restaurant/view/base/custom_app_bar.dart';
import 'package:flutter_restaurant/view/base/custom_button.dart';
import 'package:flutter_restaurant/view/base/custom_snackbar.dart';
import 'package:flutter_restaurant/view/base/custom_text_field.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  @override
  Widget build(BuildContext context) {
    TextEditingController _emailController = TextEditingController();

    return Scaffold(
      appBar: CustomAppBar(title: getTranslated('forgot_password', context)),
      body: Scrollbar(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Center(
            child: SizedBox(
              width: 1170,
              child: Consumer<AuthProvider>(
                builder: (context, auth, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 55),
                      Image.asset(
                        Images.close_lock,
                        width: 142,
                        height: 142,
                      ),
                      SizedBox(height: 40),
                      Center(
                          child: Text(
                            getTranslated('please_enter_your_number_to', context),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headline2.copyWith(color: ColorResources.getHintColor(context)),
                          )),
                      Padding(
                        padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 80),
                            Text(
                              getTranslated('email', context),
                              style: Theme.of(context).textTheme.headline2.copyWith(color: ColorResources.getHintColor(context)),
                            ),
                            SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                            CustomTextField(
                              hintText: getTranslated('demo_gmail', context),
                              isShowBorder: true,
                              controller: _emailController,
                              inputType: TextInputType.emailAddress,
                              inputAction: TextInputAction.done,
                            ),
                            SizedBox(height: 24),
                            !auth.isForgotPasswordLoading ? CustomButton(
                              btnTxt: getTranslated('send', context),
                              onTap: () {
                                if (_emailController.text.isEmpty) {
                                  showCustomSnackBar(getTranslated('enter_email_address', context), context);
                                }else if (!_emailController.text.contains('@')) {
                                  showCustomSnackBar(getTranslated('enter_valid_email', context), context);
                                }else {
                                  Provider.of<AuthProvider>(context, listen: false).forgetPassword(_emailController.text).then((value) {
                                    if (value.isSuccess) {
                                      Navigator.pushNamed(context, Routes.getVerifyRoute('forget-password', _emailController.text));
                                    } else {
                                      showCustomSnackBar(value.message, context);
                                    }
                                  });
                                }
                              },
                            ) : Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor))),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
