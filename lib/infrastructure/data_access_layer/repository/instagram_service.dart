import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../commons/instagram_config.dart';

class InstagramService {
  List<String> userFields = ['id', 'username'];

  String? authorizationCode;
  String? accessToken;
  String? userID;
  String? username;

  void getAuthorizationCode(String url) {
    authorizationCode = url.replaceAll('${InstagramConfig.redirectUri}?code=', '').replaceAll('#_', '');
  }

  Future<String> getTokenAndUserID() async {
    try {
      var url = Uri.parse('https://api.instagram.com/oauth/access_token');
      final response = await http.post(url, body: {
        'client_id': InstagramConfig.clientID,
        'redirect_uri': InstagramConfig.redirectUri,
        'client_secret': InstagramConfig.appSecret,
        'code': authorizationCode ?? "",
        'grant_type': 'authorization_code'
      });
      accessToken = json.decode(response.body)['access_token'];
      userID = json.decode(response.body)['user_id'].toString();
      if (accessToken != null && userID != null) {
        return '$accessToken:$userID';
      }
    } catch (e) {
      print(e);
    }
    return '';
  }

  Future<bool> getUserProfile() async {
    final fields = userFields.join(',');
    final responseNode = await http.get(Uri.parse('https://graph.instagram.com/$userID?fields=$fields&access_token=$accessToken'));
    // instaProfile not used
    // var instaProfile = {
    //   'id': json.decode(responseNode.body)['id'].toString(),
    //   'username': json.decode(responseNode.body)['username'],
    // };
    username = json.decode(responseNode.body)['username'];
    print('username: $username');
    return true;
    // return instaProfile != null ? true : false; // instaProfile is never null
  }
}
