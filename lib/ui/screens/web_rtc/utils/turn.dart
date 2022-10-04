import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../../../infrastructure/data_access_layer/services/logging.dart';

Future<Map> getTurnCredential(String host, int port) async {
  HttpClient client = HttpClient(context: SecurityContext());
  client.badCertificateCallback = (X509Certificate cert, String host, int port) {
    log('getTurnCredential: Allow self-signed certificate => $host:$port. ');
    return true;
  };
  var url = 'https://$host:$port/api/turn?service=turn&username=flutter-webrtc';
  var request = await client.getUrl(Uri.parse(url));
  var response = await request.close();
  var responseBody = await response.transform(Utf8Decoder()).join();
  log('getTurnCredential:response => $responseBody.');
  Map data = JsonDecoder().convert(responseBody);
  return data;
}
