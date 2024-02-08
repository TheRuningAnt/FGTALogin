import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tiktok_sdk/flutter_tiktok_sdk.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //Tiktok配置
    TikTokSDK.instance.setup(clientKey: 'aw7p7k5kjcuhthn9');

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("海外平台第三方登录"),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 120),
            _createGoogleLogin(),
            SizedBox(height: 20),
            _createFacebookLogin(),
            SizedBox(height: 20),
            _createTiktokLogin(),
            SizedBox(height: 20),
            _createAppleLogin(),
            SizedBox(height: 20),
            _userData == null?Container():_loginResult()
          ],
        ),
      ),
    );
  }

  //google 登录
  Widget _createGoogleLogin(){
    return Container(
      width: 260,
      height: 40,
      child: ElevatedButton(
        child: Text("Google 登录"),
        onPressed: (){
          googleLogin();
        },
      ),
    );
  }

  //facebook 登录
  Widget _createFacebookLogin(){
    return Container(
      width: 260,
      height: 40,
      child: ElevatedButton(
        child: Text("Facebook 登录"),
        onPressed: (){
          print("facebook");
        },
      ),
    );
  }

  //tiktok 登录
  Widget _createTiktokLogin(){
    return Container(
      width: 260,
      height: 40,
      child: ElevatedButton(
        child: Text("Tiktok 登录"),
        onPressed: (){
          tiktokLogin();
        },
      ),
    );
  }

  //apple 登录
  Widget _createAppleLogin(){
    return Container(
      width: 260,
      height: 40,
      child: ElevatedButton(
        child: Text("Apple 登录"),
        onPressed: (){
          print("apple");
        },
      ),
    );
  }

  Widget _loginResult(){
     return Container(
       width: 260,
       height: 40,
       child: Text("登录信息:\n${_userData}",softWrap: true,maxLines: 5,),
     );
  }

  //tiktok登录
  void tiktokLogin() async{
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

  //google登录
  void googleLogin() async{
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
}
