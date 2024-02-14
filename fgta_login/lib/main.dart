import 'dart:io';

import 'package:fgta_login/BuyEngine.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_tiktok_sdk/flutter_tiktok_sdk.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'TiktokHttp.dart';
import 'firebase_options.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '海外平台第三方登录22',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage();

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String _userData;
  BuyEngin _buyEngin;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //Tiktok配置
    TikTokSDK.instance.setup(clientKey: 'aw7p7k5kjcuhthn9');

    _buyEngin = BuyEngin();
    _buyEngin.initializeInAppPurchase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter海外平台第三方登录及支付"),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 120),
            _createGoogleLoginWidget(),
            SizedBox(height: 20),
            _createFacebookLoginWidget(),
            SizedBox(height: 20),
            _createTiktokLoginWidget(),
            SizedBox(height: 20),
            _createAppleLoginWidget(),
            SizedBox(height: 20),
            _createGooglePayWidget(),
            SizedBox(height: 20),
            _createApplePayWidget(),
            SizedBox(height: 20),
            _userData == null?Container():_loginResultWidget()
          ],
        ),
      ),
    );
  }

  //google 登录组件
  Widget _createGoogleLoginWidget(){
    return Container(
      width: 260,
      height: 40,
      child: ElevatedButton(
        child: Text("Google 登录"),
        onPressed: (){
          _googleLoginAction();
        },
      ),
    );
  }

  //facebook 登录组件
  Widget _createFacebookLoginWidget(){
    return Container(
      width: 260,
      height: 40,
      child: ElevatedButton(
        child: Text("Facebook 登录"),
        onPressed: (){
          _facebookLoginAction();
        },
      ),
    );
  }

  //tiktok 登录组件
  Widget _createTiktokLoginWidget(){
    return Container(
      width: 260,
      height: 40,
      child: ElevatedButton(
        child: Text("Tiktok 登录"),
        onPressed: (){
          _tiktokLoginAction();
        },
      ),
    );
  }

  //apple 登录组件
  Widget _createAppleLoginWidget(){
    return Container(
      width: 260,
      height: 40,
      child: ElevatedButton(
        child: Text("Apple 登录"),
        onPressed: (){
          _appleLoginAction();
        },
      ),
    );
  }

  //google支付 组件
  Widget _createGooglePayWidget(){
    return Container(
      width: 260,
      height: 40,
      child: ElevatedButton(
        child: Text("google支付"),
        onPressed: (){
          _googlePayAction();
        },
      ),
    );
  }

  //苹果支付 组件
  Widget _createApplePayWidget(){
    return Container(
      width: 260,
      height: 40,
      child: ElevatedButton(
        child: Text("apple支付"),
        onPressed: (){
          _applePayAction();
        },
      ),
    );
  }

  //结果展示组件
  Widget _loginResultWidget(){
     return Container(
       width: 260,
       height: 40,
       child: Text("登录信息:\n${_userData}",softWrap: true,maxLines: 5,),
     );
  }

  //tiktok登录 - Action
  void _tiktokLoginAction() async{
    final result = await TikTokSDK.instance.login(
      permissions: {
        TikTokPermissionType.userInfoBasic,
      },
    );

    if(result.status == TikTokLoginStatus.success){
      try{
        TiktokHttp.getTikTokAccessToken(authCode:result.authCode).then((value){
          print("获取accesstoken ==" + value.toString());
          print("\n\n\n");

          if(value["message"] == "success"){
            TiktokHttp.getTikTokUserInfo(accessToken: value["data"]["access_token"]).then((value){

              _userData = value.toString();
              setState(() {

              });
              print("获取UserInfo ==" + value.toString());
              print("\n\n\n");
            });
          }else{
            throw "data error";
          }
        });
      }catch(e){
        print("tiktok 登录失败 " + e);
      }
    }else{
      print("tiktok 登录失败 " + result.errorMessage);
    }
    print("tiktok登录成功 " + result.toString());
  }

  //google登录 - Action
  void _googleLoginAction() async{
    GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: <String>[
        'email',
        'https://www.googleapis.com/auth/contacts.readonly',
      ],
    );
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    print("googleUser:${googleUser.toString()}");
    print("googleUser ID :${googleUser.id}");
    _userData = googleUser.toString();
    setState(() {

    });
  }

  //facebook登录 - Action
  void _facebookLoginAction() async{
    final LoginResult result = await FacebookAuth.instance.login(); // by default we request the email and the public profile
    if (result.status == LoginStatus.success) {
      // you are logged
      final AccessToken accessToken = result.accessToken;

      Map<String, dynamic> userData = await FacebookAuth.instance.getUserData();
      _userData = userData.toString();
      setState(() {

      });
      print("facebook 获取登录用户信息" + userData.toString());

    } else {
      print("facebook 登录失败");
      print(result.status);
      print(result.message);
    }
  }

  //apple登录 - Action
  void _appleLoginAction() async{

    if(checkPlatform(checkiOS: true, message: "请在iOS设备上进行Apple登录"))return;

    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    if (credential != null) {
      _userData = credential.toString();

      print(credential.toString());
      print(credential.email);
      print(credential.givenName);
      print(credential.userIdentifier);

      setState(() {
      });
    }
  }

  //google 支付 - action
  void _googlePayAction(){
    if(checkPlatform(checkAndroid:true, message: "请在安卓设备上进行google支付"))return;
    _buyEngin.buyProduct("应用内商品ID");
  }

  //apple 支付 - action
  void _applePayAction(){
    if(checkPlatform(checkiOS:true, message: "请在ios设备上进行Apple支付"))return;
    _buyEngin.buyProduct("应用内商品ID");
  }

  bool checkPlatform({bool checkAndroid = false,bool checkiOS = false,String message = ""}){
    bool checkUnable = false;
    if(checkiOS){
      if(Platform.isAndroid){
        checkUnable = true;
      }
    }
    if(checkAndroid){
      if(Platform.isIOS){
        checkUnable = true;
      }
    }

    if(checkUnable){
      showDialog(
          barrierDismissible: false, //表示点击灰色背景的时候是否消失弹出框
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("提示"),
              content: Text(message),
              actions: <Widget>[
                TextButton(
                  child: const Text("确定"),
                  onPressed: () {
                    Navigator.pop(context, "Ok");
                  },
                )
              ],
            );
          });
    }
    return checkUnable;
  }


}
