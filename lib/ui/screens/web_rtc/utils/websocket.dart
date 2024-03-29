import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import '../../../../infrastructure/data_access_layer/services/logging.dart';

class SimpleWebSocket {
  String _url;
  WebSocket? _socket;
  Function()? onOpen;
  Function(dynamic msg)? onMessage;
  Function(int code, String reaso)? onClose;
  int closeSocketCode = 7654321;

  SimpleWebSocket(this._url);

  connect() async {
    try {
      //_socket = await WebSocket.connect(_url);
      _socket = await _connectForSelfSignedCert(_url);
      onOpen?.call();
      _socket?.listen((data) {
        onMessage?.call(data);
      }, onDone: () {
        onClose?.call(_socket?.closeCode ?? 0, _socket?.closeReason ?? "");
      });
    } catch (e) {
      onClose?.call(500, e.toString());
    }
  }

  send(data) {
    if (_socket != null && (_socket!.closeCode ?? 0) != closeSocketCode) {
      _socket!.add(data);
      log('send: $data');
    }
  }

  closeSocket() async {
    log('code ==> : ${(_socket?.closeCode ?? 0)}');
    if (_socket != null && ((_socket?.closeCode ?? 0) != closeSocketCode)) {
      await _socket?.close(closeSocketCode);
    }
  }

  Future<WebSocket> _connectForSelfSignedCert(url) async {
    try {
      Random r = new Random();
      String key = base64.encode(List<int>.generate(8, (_) => r.nextInt(255)));
      HttpClient client = HttpClient(context: SecurityContext());
      client.badCertificateCallback = (X509Certificate cert, String host, int port) {
        log('SimpleWebSocket: Allow self-signed certificate => $host:$port. ');
        return true;
      };

      HttpClientRequest request = await client.getUrl(Uri.parse(url)); // form the correct url here
      request.headers.add('Connection', 'Upgrade');
      request.headers.add('Upgrade', 'websocket');
      request.headers.add('Sec-WebSocket-Version', '13'); // insert the correct version here
      request.headers.add('Sec-WebSocket-Key', key.toLowerCase());

      HttpClientResponse response = await request.close();
      // ignore: close_sinks
      Socket socket = await response.detachSocket();
      var webSocket = WebSocket.fromUpgradedSocket(
        socket,
        protocol: 'signaling',
        serverSide: false,
      );

      return webSocket;
    } catch (e) {
      throw e;
    }
  }
}
