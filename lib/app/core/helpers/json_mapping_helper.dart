// json_mapping_helpers.dart
typedef Json = Map<String, dynamic>;

/// Flatten selected keys from a container (default: 'additional_info')
/// into the top-level map.
/// - Does not mutate [src]; returns a new map.
/// - Only copies keys that exist & non-null.
/// - If [removeContainer] = true, removes the container key after flattening.
Json flattenContainerKeys(
  Json src, {
  String containerKey = 'additional_info',
  List<String> keysToLift = const [],
  bool removeContainer = false,
}) {
  final out = Map<String, dynamic>.from(src);
  final container = out[containerKey];

  if (container is Map<String, dynamic>) {
    for (final key in keysToLift) {
      final v = container[key];
      if (v != null) {
        out[key] = v;
      }
    }
    if (removeContainer) {
      out.remove(containerKey);
    }
  }

  return out;
}

/// Preset daftar kunci yang umum diangkat per-model.
/// Tambahkan model lain seiring kebutuhan.
const Map<String, List<String>> _liftKeysRegistry = {
  'user': [
    'user_detail',
    'userDetail',
    'user_preferences',
    'userPreferences',
    // 'user_saved', 
    // 'userSaved',
    'user_settings',
    'userSettings',
    'user_notification',
    'userNotification',
  ],
  'place': [
    'place_detail',
    'place_value',
    'food_type',
    'menu_image_url',
    'menu',
    'place_attributes',
  ],
  // contoh: 'review': [], 'checkin': []
};

/// Flatten dengan preset berdasarkan nama model.
/// - [modelKey] contoh: 'user', 'place'
/// - [containerKey] default 'additional_info'
Json flattenByModelPreset(
  Json src, {
  required String modelKey,
  String containerKey = 'additional_info',
  bool removeContainer = false,
}) {
  final keys = _liftKeysRegistry[modelKey] ?? const <String>[];

  // First, flatten the container keys
  var result = flattenContainerKeys(
    src,
    containerKey: containerKey,
    keysToLift: keys,
    removeContainer: removeContainer,
  );

  // Handle duplicate fields (snake_case and camelCase) by preferring camelCase
  // and converting snake_case to proper types if needed
  result = _fixDuplicateFieldsAndTypeMismatches(result);

  return result;
}

/// Fix duplicate fields and type mismatches in the flattened JSON
/// Prefers camelCase fields and handles type conversions
Json _fixDuplicateFieldsAndTypeMismatches(Json data) {
  final result = Map<String, dynamic>.from(data);

  // Handle user_detail vs userDetail - ALWAYS prefer camelCase
  if (result.containsKey('user_detail')) {
    // Keep snake_case for generated models, provide camelCase copy for convenience
    result['userDetail'] = result['userDetail'] ?? result['user_detail'];
  }

  // Handle user_preferences vs userPreferences - ALWAYS prefer camelCase
  if (result.containsKey('user_preferences')) {
    result['userPreferences'] =
        result['userPreferences'] ?? result['user_preferences'];
  }

  // Handle user_saved vs userSaved - ALWAYS prefer camelCase
  if (result.containsKey('user_saved')) {
    result['userSaved'] = result['userSaved'] ?? result['user_saved'];
  }

  // Handle user_settings vs userSettings - ALWAYS prefer camelCase
  if (result.containsKey('user_settings')) {
    result['userSettings'] = result['userSettings'] ?? result['user_settings'];
  }

  // Handle user_notification vs userNotification - ALWAYS prefer camelCase
  if (result.containsKey('user_notification')) {
    result['userNotification'] =
        result['userNotification'] ?? result['user_notification'];
  }

  // Fix type mismatches in numeric fields
  _fixNumericFieldTypes(result);

  return result;
}

/// Fix type mismatches for numeric fields that might come as strings
void _fixNumericFieldTypes(Json data) {
  final numericFields = [
    'totalCoin',
    'totalExp',
    'totalFollowing',
    'totalFollower',
    'totalCheckin',
    'totalPost',
    'totalArticle',
    'totalReview',
    'totalAchievement',
    'totalChallenge',
    'id'
  ];

  for (final field in numericFields) {
    if (data.containsKey(field) && data[field] is String) {
      try {
        final value = data[field] as String;
        if (value.isNotEmpty) {
          data[field] =
              int.tryParse(value) ?? double.tryParse(value) ?? data[field];
        }
      } catch (e) {
        // Keep original value if parsing fails
        print('⚠️ Failed to parse numeric field $field: ${data[field]}');
      }
    }
  }
}

/// Versi yang lebih eksplisit per model (sintaks manis).
Json flattenAdditionalInfoForUser(
  Json src, {
  bool removeContainer = false,
}) {
  return flattenByModelPreset(
    src,
    modelKey: 'user',
    containerKey: 'additional_info',
    removeContainer: removeContainer,
  );
}

Json flattenAdditionalInfoForPlace(
  Json src, {
  bool removeContainer = false,
}) {
  return flattenByModelPreset(
    src,
    modelKey: 'place',
    containerKey: 'additional_info',
    removeContainer: removeContainer,
  );
}

Json flattenAdditionalInfoForPost(
  Json src, {
  bool removeContainer = false,
}) {
  return flattenByModelPreset(
    src,
    modelKey: 'post',
    containerKey: 'additional_info',
    removeContainer: removeContainer,
  );
}
