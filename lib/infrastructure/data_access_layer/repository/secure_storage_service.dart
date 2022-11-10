import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/logging.dart';

class SecureStorage {
  static final SecureStorage _singleton = SecureStorage._internal();

  factory SecureStorage() {
    return _singleton;
  }

  SecureStorage._internal();

  final _storage = FlutterSecureStorage();

  Future write(String key, String value) => _storage.write(key: key, value: value);

  Future<String?> read(String key) => _storage.read(key: key);

  Future<void> remove(String key) => _storage.delete(key: key);

  Future<void> clear() async => await _storage.deleteAll();

  Future<List<String>> keys() async {
    log('SecureStorage - _storage=$_storage');
    final storageMap = await _storage.readAll();
    return storageMap.keys.toList();
  }
}
