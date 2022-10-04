import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../infrastructure/data_access_layer/services/logging.dart';

Future<Map> getTurnCredential(String host, int port) async {
  var url = 'https://$host:$port/api/turn?service=turn&username=flutter-webrtc';
  final res = await http.get(Uri.parse(url));
  if (res.statusCode == 200) {
    var data = json.decode(res.body);
    log('getTurnCredential:response => $data.');
    return data;
  }
  return {};
}
