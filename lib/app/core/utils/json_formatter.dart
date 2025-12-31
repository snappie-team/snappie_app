import 'dart:convert';

import '../services/logger_service.dart';

class JsonFormatter {
  // JSON utilities for handling unstructured data
  /// Converts a Map<String, dynamic> to JSON string for storage
  /// Returns null if the map is null or empty
  static String? mapToJsonString(Map<String, dynamic>? map) {
    if (map == null || map.isEmpty) return null;
    try {
      return jsonEncode(map);
    } catch (e) {
      Logger.warning('Error converting map to JSON string: $e', 'JsonFormatter');
      return null;
    }
  }

  /// Converts any JSON-serializable object to string representation.
  /// Falls back to null if value is not serializable.
  static String? anyToJsonString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;

    try {
      return jsonEncode(value);
    } catch (e) {
      Logger.warning('Error converting value to JSON string: $e', 'JsonFormatter');
      return null;
    }
  }

  /// Converts a JSON string back to Map<String, dynamic>
  /// Returns null if the string is null, empty, or invalid JSON
  static Map<String, dynamic>? jsonStringToMap(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (e) {
      Logger.warning('Error parsing JSON string to map: $e', 'JsonFormatter');
      return null;
    }
  }

  /// Converts a JSON string to dynamic (Map/List) value
  static dynamic jsonStringToDynamic(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      return jsonDecode(jsonString);
    } catch (e) {
      Logger.warning('Error parsing JSON string to dynamic: $e', 'JsonFormatter');
      return null;
    }
  }

  /// Safely gets a value from a JSON string by key
  /// Returns the default value if key is not found or JSON is invalid
  static T? getValueFromJsonString<T>(String? jsonString, String key, [T? defaultValue]) {
    final map = jsonStringToMap(jsonString);
    if (map == null) return defaultValue;
    return map[key] as T? ?? defaultValue;
  }

  /// Updates a specific key-value pair in a JSON string
  /// Returns the updated JSON string or null if operation fails
  static String? updateJsonString(String? jsonString, String key, dynamic value) {
    final map = jsonStringToMap(jsonString) ?? <String, dynamic>{};
    map[key] = value;
    return mapToJsonString(map);
  }

  /// Removes a key from a JSON string
  /// Returns the updated JSON string or null if operation fails
  static String? removeKeyFromJsonString(String? jsonString, String key) {
    final map = jsonStringToMap(jsonString);
    if (map == null) return jsonString;
    map.remove(key);
    return mapToJsonString(map);
  }
}