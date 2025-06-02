import 'package:get_storage/get_storage.dart';

class StorageUtils {
  static final GetStorage _box = GetStorage();
  static final StorageUtils _instance = StorageUtils._internal();

  StorageUtils._internal();

  factory StorageUtils() {
    return _instance;
  }

  // Initialize storage (call this once, e.g., in main)
  static Future<void> init() async {
    await GetStorage.init();
  }

  // Save a value with a key
  static void save(String key, dynamic value) {
    _box.write(key, value);
  }

  // Read a value by key
  static dynamic read(String key) {
    return _box.read(key);
  }

  // Delete a value by key
  static void delete(String key) {
    _box.remove(key);
  }

  // Clear all stored data
  static void clear() {
    _box.erase();
  }
}
