import 'package:app_2i2i/services/logging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final _storage = FlutterSecureStorage();
  Future write(String key, String value) =>
      _storage.write(key: key, value: value);
  Future<String?> read(String key) => _storage.read(key: key);
  Future<List<String>> keys() async {
    log('SecureStorage - _storage=$_storage');
    final storageMap = await _storage.readAll();
    return storageMap.keys.toList();
  }
}
