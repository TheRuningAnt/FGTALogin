import 'package:dio/dio.dart';
import 'dart:convert' as convert;

const String tikTokGetAccessTokenUrl = "https://open-api.tiktok.com/oauth/access_token"; //Tiktok获取accessToken
const tikTokGetUserInfoUrl = "https://open-api.tiktok.com/user/info/"; //Tiktok获取用户信息

class TiktokHttp{

  /*
  * TikTok获取accessToken
  * */
  static Future<Map<dynamic, dynamic>> getTikTokAccessToken({String authCode}) async {
    String requestUrl = "https://open-api.tiktok.com/oauth/access_token?client_key=aw7p7k5kjcuhthn9&client_secret=pf0kTB5lMjFaQioQYco3mt1FAxpdaNMs&code=" + Uri.decodeFull(authCode) + "&grant_type=authorization_code";
    Dio dio = Dio();
    final option = Options(
      method: "get",
    );
    Response response = await dio.request(requestUrl,options: option);

    Map<dynamic, dynamic> mapResult;
    if (response.data is String) {
      mapResult = convert.jsonDecode(response.data);
    } else {
      mapResult = response.data as Map;
    }
    return mapResult;
  }

  /*
  * TikTok获取用户信息
  * */
  static Future<Map<String, dynamic>> getTikTokUserInfo({String accessToken}) async {
    Map<String, dynamic> arguments = Map();
    arguments["access_token"] = accessToken;
    arguments["fields"] = ["open_id", "union_id", "avatar_url","display_name"];

    Dio dio = Dio();

    Map<String, dynamic> headers = Map();
    // headers["content-Type"] = "application/json";

    final option = Options(
      method: "post",
        receiveTimeout: 20000
    );

    Response response = await dio.request(tikTokGetUserInfoUrl,data: arguments,options: option);

    Map<dynamic, dynamic> mapResult;
    if (response.data is String) {
      mapResult = convert.jsonDecode(response.data);
    } else {
      mapResult = response.data as Map;
    }
    return mapResult;
  }


}