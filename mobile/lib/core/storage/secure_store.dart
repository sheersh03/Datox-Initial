import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStore {
  static final _s = FlutterSecureStorage(
    aOptions: const AndroidOptions(resetOnError: true),
  );

  static Future<void> write(String key, String value) async {
    try {
      await _s.write(key: key, value: value);
    } catch (_) {
      // Emulator KeyStore can fail; avoid crashing
    }
  }

  static Future<String?> read(String key) async {
    try {
      return await _s.read(key: key);
    } catch (_) {
      // Emulator KeyStore can fail; return null instead of crashing
      return null;
    }
  }

  static Future<void> delete(String key) async {
    try {
      await _s.delete(key: key);
    } catch (_) {
      // Emulator KeyStore can fail; avoid crashing
    }
  }
}
