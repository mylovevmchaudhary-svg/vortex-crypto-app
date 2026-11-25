import 'package:shared_preferences/shared_preferences.dart';

/// Abstraction for persistent key-value storage so repositories remain testable.
abstract class StorageService {
  Future<String?> readString(String key);
  Future<void> writeString(String key, String value);
  Future<void> remove(String key);
}

class SharedPreferencesStorageService implements StorageService {
  SharedPreferencesStorageService();

  SharedPreferences? _prefs;

  Future<SharedPreferences> _instance() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  @override
  Future<String?> readString(String key) async {
    final prefs = await _instance();
    return prefs.getString(key);
  }

  @override
  Future<void> writeString(String key, String value) async {
    final prefs = await _instance();
    await prefs.setString(key, value);
  }

  @override
  Future<void> remove(String key) async {
    final prefs = await _instance();
    await prefs.remove(key);
  }
}

class InMemoryStorageService implements StorageService {
  final Map<String, String> _store = <String, String>{};

  @override
  Future<String?> readString(String key) async => _store[key];

  @override
  Future<void> writeString(String key, String value) async {
    _store[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _store.remove(key);
  }
}
