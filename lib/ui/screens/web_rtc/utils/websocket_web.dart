import 'package:universal_html/html.dart';

import '../../../../infrastructure/data_access_layer/services/logging.dart';

class SimpleWebSocket {
  String _url;
  var _socket;
  Function()? onOpen;
  Function(dynamic msg)? onMessage;
  Function(int code, String reason)? onClose;

  SimpleWebSocket(this._url) {
    _url = _url.replaceAll('https:', 'wss:');
  }

  connect() async {
    try {
      _socket = WebSocket(_url);
      _socket.onOpen.listen((e) {
        onOpen?.call();
      });

      _socket.onMessage.listen((e) {
        onMessage?.call(e.data);
      });

      _socket.onClose.listen((e) {
        onClose?.call(e.code, e.reason);
      });
    } catch (e) {
      onClose?.call(500, e.toString());
    }
  }

  send(data) {
    if (_socket != null && _socket.readyState == WebSocket.OPEN) {
      _socket.send(data);
      log('send: $data');
    } else {
      log('WebSocket not connected, message $data not sent');
    }
  }

  close() {
    if (_socket != null) {
      _socket.close();
    }
  }
}
