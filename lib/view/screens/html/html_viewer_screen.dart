import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_restaurant/helper/html_type.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/provider/splash_provider.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:flutter_restaurant/view/base/custom_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:universal_ui/universal_ui.dart';

import 'package:webview_flutter/webview_flutter.dart';

class HtmlViewerScreen extends StatefulWidget {
  final HtmlType htmlType;
  HtmlViewerScreen({@required this.htmlType});

  @override
  _HtmlViewerScreenState createState() => _HtmlViewerScreenState();
}

class _HtmlViewerScreenState extends State<HtmlViewerScreen> {
  final Completer<WebViewController> _controller = Completer<WebViewController>();
  WebViewController controllerGlobal;
  String _data;
  String _viewID;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    if(ResponsiveHelper.isMobilePhone()) {
      if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    }

    _data = widget.htmlType == HtmlType.TERMS_AND_CONDITION ? Provider.of<SplashProvider>(context, listen: false).configModel.termsAndConditions
        : widget.htmlType == HtmlType.ABOUT_US ? Provider.of<SplashProvider>(context, listen: false).configModel.aboutUs
        : widget.htmlType == HtmlType.PRIVACY_POLICY ? Provider.of<SplashProvider>(context, listen: false).configModel.privacyPolicy : null;

    _viewID = widget.htmlType.toString();
    if(ResponsiveHelper.isWeb()) {
      try{
        ui.platformViewRegistry.registerViewFactory(_viewID, (int viewId) {
          html.IFrameElement _ife = html.IFrameElement();
          _ife.width = '1170';
          _ife.height = MediaQuery.of(context).size.height.toString();
          _ife.src = _data;
          _ife.contentEditable = 'false';
          _ife.style.border = 'none';
          _ife.allowFullscreen = true;
          return _ife;
        });
      }catch(e) {}
    }
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _exitApp(context),
      child: Scaffold(
        appBar: CustomAppBar(title: getTranslated(widget.htmlType == HtmlType.TERMS_AND_CONDITION ? 'terms_and_condition'
            : widget.htmlType == HtmlType.ABOUT_US ? 'about_us' : widget.htmlType == HtmlType.PRIVACY_POLICY ? 'privacy_policy' : 'no_data_found', context)),
        body: Center(
          child: Container(
            width: 1170,
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
            child: ResponsiveHelper.isWeb() ? Column(
              children: [
                ResponsiveHelper.isDesktop(context) ? Container(
                  height: 100, alignment: Alignment.center,
                  child: SelectableText(getTranslated(widget.htmlType == HtmlType.TERMS_AND_CONDITION ? 'terms_and_condition'
                      : widget.htmlType == HtmlType.ABOUT_US ? 'about_us' : widget.htmlType == HtmlType.PRIVACY_POLICY ? 'privacy_policy' : 'no_data_found', context),
                    style: rubikBold.copyWith(fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE),
                  ),
                ) : SizedBox(),
                SizedBox(height: 20),
                Expanded(child: IgnorePointer(child: HtmlElementView(viewType: _viewID, key: Key(widget.htmlType.toString())))),
              ],
            ) : Stack(
              children: [
                Center(
                  child: SizedBox(width: 1170, child: WebView(
                    initialUrl: _data,
                    javascriptMode: JavascriptMode.unrestricted,
                    onWebViewCreated: (WebViewController webViewController) {
                      _controller.future.then((value) => controllerGlobal = value);
                      _controller.complete(webViewController);
                    },
                    onPageFinished: (String url) {
                      setState(() {
                        _isLoading = false;
                      });
                    },
                ),
                  ),
                ),
                _isLoading ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor))) : SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _exitApp(BuildContext context) async {
    if (await controllerGlobal.canGoBack()) {
      controllerGlobal.goBack();
      return Future.value(false);
    } else {
      return true;
    }
  }
}
