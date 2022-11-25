import 'package:universal_html/html.dart';

class SimpleWebSocket {
  String _url;
  WebSocket? _socket;
  Function()? onOpen;
  Function(dynamic msg)? onMessage;
  Function(int code, String reason)? onClose;

  SimpleWebSocket(this._url) {
    _url = _url.replaceAll('https:', 'wss:');
  }

  connect() async {
    try {
      _socket = WebSocket(_url);
      _socket?.onOpen.listen((e) {
        this.onOpen?.call();
      });

      _socket?.onMessage.listen((e) {
        this.onMessage?.call(e.data);
      });

      _socket?.onClose.listen(
        (e) {
          this.onClose?.call(e.code ?? 500, e.reason ?? "");
        },
      );
    } on DomException catch (e) {
      onClose?.call(500, e.message ?? "");
    } catch (e) {
      onClose?.call(500, e.toString());
    }
  }

  send(data) {
    if (_socket != null && _socket?.readyState == WebSocket.OPEN) {
      _socket?.send(data);
      print('send: $data');
    } else {
      print('WebSocket not connected, message $data not sent');
    }
  }

  closeSocket() {
    if (_socket != null) {
      _socket?.close();
    }
  }
}
