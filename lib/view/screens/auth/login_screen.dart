import 'package:flutter/material.dart';
import 'package:flutter_restaurant/helper/email_checker.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/provider/auth_provider.dart';
import 'package:flutter_restaurant/provider/splash_provider.dart';
import 'package:flutter_restaurant/provider/wishlist_provider.dart';
import 'package:flutter_restaurant/utill/color_resources.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/utill/routes.dart';
import 'package:flutter_restaurant/view/base/custom_button.dart';
import 'package:flutter_restaurant/view/base/custom_snackbar.dart';
import 'package:flutter_restaurant/view/base/custom_text_field.dart';
import 'package:flutter_restaurant/view/base/main_app_bar.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  // FocusNode _emailNumberFocus = FocusNode();
  FocusNode _phoneFocus = FocusNode();
  // FocusNode _passwordFocus = FocusNode();
  // TextEditingController _emailController;
  TextEditingController _phoneController;
  TextEditingController _passwordController;
  GlobalKey<FormState> _formKeyLogin;

  @override
  void initState() {
    super.initState();
    _formKeyLogin = GlobalKey<FormState>();
    // _emailController = TextEditingController();
    _phoneController = TextEditingController();
    // _passwordController = TextEditingController();

    // _emailController.text = Provider.of<AuthProvider>(context, listen: false).getUserNumber() ?? '';
    _phoneController.text = Provider.of<AuthProvider>(context, listen: false).getUserNumber() ?? '';
    // _passwordController.text = Provider.of<AuthProvider>(context, listen: false).getUserPassword() ?? '';
  }

  @override
  void dispose() {
    // _emailController.dispose();
    _phoneController.dispose();
    // _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context) ? PreferredSize(child: MainAppBar(), preferredSize: Size.fromHeight(80)) : null,
      body: SafeArea(
        child: Scrollbar(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
            physics: BouncingScrollPhysics(),
            child: Center(
              child: SizedBox(
                width: 1170,
                child: Consumer<AuthProvider>(
                  builder: (context, authProvider, child) => Form(
                    key: _formKeyLogin,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: ResponsiveHelper.isWeb() ? Consumer<SplashProvider>(
                              builder:(context, splash, child) => FadeInImage.assetNetwork(
                                placeholder: Images.placeholder_rectangle,
                                image: splash.baseUrls != null ? '${splash.baseUrls.restaurantImageUrl}/${splash.configModel.restaurantLogo}' : '',
                                height: MediaQuery.of(context).size.height / 4.5,
                              ),
                            ) : Image.asset(
                              Images.logo,
                              height: MediaQuery.of(context).size.height / 4.5,
                              fit: BoxFit.scaleDown,
                              matchTextDirection: true,
                            ),
                          ),
                        ),
                        Center(
                            child: Text(
                          getTranslated('login', context),
                          style: Theme.of(context).textTheme.headline3.copyWith(fontSize: 24, color: ColorResources.getGreyBunkerColor(context)),
                        )),
                        SizedBox(height: 35),
                        Text(
                          getTranslated('mobile_number', context),
                          style: Theme.of(context).textTheme.headline2.copyWith(color: ColorResources.getHintColor(context)),
                        ),
                        SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                        CustomTextField(
                          hintText: getTranslated('number_hint', context),
                          isShowBorder: true,
                          controller: _phoneController,
                          focusNode: _phoneFocus,
                          // nextFocus: _passwordFocus,
                          inputType: TextInputType.phone,
                        ),
                        /*Text(
                          getTranslated('email', context),
                          style: Theme.of(context).textTheme.headline2.copyWith(color: ColorResources.getHintColor(context)),
                        ),
                        SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                        CustomTextField(
                          hintText: getTranslated('demo_gmail', context),
                          isShowBorder: true,
                          focusNode: _emailNumberFocus,
                          nextFocus: _passwordFocus,
                          controller: _emailController,
                          inputType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                        Text(
                          getTranslated('password', context),
                          style: Theme.of(context).textTheme.headline2.copyWith(color: ColorResources.getHintColor(context)),
                        ),
                        SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                        CustomTextField(
                          hintText: getTranslated('password_hint', context),
                          isShowBorder: true,
                          isPassword: true,
                          isShowSuffixIcon: true,
                          focusNode: _passwordFocus,
                          controller: _passwordController,
                          inputAction: TextInputAction.done,
                        ),*/
                        SizedBox(height: 22),

                        // for remember me section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Consumer<AuthProvider>(
                                builder: (context, authProvider, child) => InkWell(
                                      onTap: () {
                                        authProvider.toggleRememberMe();
                                      },
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 18,
                                            height: 18,
                                            decoration: BoxDecoration(
                                                color: authProvider.isActiveRememberMe ? Theme.of(context).primaryColor : ColorResources.COLOR_WHITE,
                                                border:
                                                    Border.all(color: authProvider.isActiveRememberMe ? Colors.transparent : Theme.of(context).primaryColor),
                                                borderRadius: BorderRadius.circular(3)),
                                            child: authProvider.isActiveRememberMe
                                                ? Icon(Icons.done, color: ColorResources.COLOR_WHITE, size: 17)
                                                : SizedBox.shrink(),
                                          ),
                                          SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
                                          Text(
                                            getTranslated('remember_me', context),
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline2
                                                .copyWith(fontSize: Dimensions.FONT_SIZE_EXTRA_SMALL, color: ColorResources.getHintColor(context)),
                                          )
                                        ],
                                      ),
                                    )),
                            /*InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, Routes.getForgetPassRoute());
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  getTranslated('forgot_password', context),
                                  style:
                                      Theme.of(context).textTheme.headline2.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL, color: ColorResources.getHintColor(context)),
                                ),
                              ),
                            )*/
                          ],
                        ),

                        SizedBox(height: 22),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            authProvider.loginErrorMessage.length > 0
                                ? CircleAvatar(backgroundColor: Theme.of(context).primaryColor, radius: 5)
                                : SizedBox.shrink(),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                authProvider.loginErrorMessage ?? "",
                                style: Theme.of(context).textTheme.headline2.copyWith(
                                      fontSize: Dimensions.FONT_SIZE_SMALL,
                                      color: Theme.of(context).primaryColor,
                                    ),
                              ),
                            )
                          ],
                        ),

                        // for login button
                        SizedBox(height: 10),
                        !authProvider.isLoading
                            ? CustomButton(
                                btnTxt: getTranslated('login', context),
                                onTap: () async {
                                  String _number=_phoneController.text.trim();
                                 /* String _email = _emailController.text.trim();
                                  String _password = _passwordController.text.trim();
                                  if (_email.isEmpty) {
                                    showCustomSnackBar(getTranslated('enter_email_address', context), context);
                                  }else if (EmailChecker.isNotValid(_email)) {
                                    showCustomSnackBar(getTranslated('enter_valid_email', context), context);
                                  }else if (_password.isEmpty) {
                                    showCustomSnackBar(getTranslated('enter_password', context), context);
                                  }else if (_password.length < 6) {
                                    showCustomSnackBar(getTranslated('password_should_be', context), context);
                                  }*/
                                  if(_number.isEmpty){
                                    showCustomSnackBar(getTranslated('enter_phone_number', context), context);
                                  }else {

                                    Navigator.pushNamed(context, Routes.getLoginOtpRoute(_number));
                                  }
                                },
                              )
                            : Center(
                                child: CircularProgressIndicator(
                                valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                              )),

                        // for create an account
                        SizedBox(height: 30),
                        InkWell(
                          onTap: () {
                           Navigator.pushNamed(context, Routes.getCreateAccountRoute());
                          },
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  getTranslated('create_an_account', context),
                                  style:
                                      Theme.of(context).textTheme.headline2.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL, color: ColorResources.getGreyColor(context)),
                                ),
                                SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
                                Text(
                                  getTranslated('signup', context),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline3
                                      .copyWith(fontSize: Dimensions.FONT_SIZE_SMALL, color: ColorResources.getGreyBunkerColor(context)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
