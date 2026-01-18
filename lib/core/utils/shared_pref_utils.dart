import 'package:shared_preferences/shared_preferences.dart';

import '../../di/injector.dart';

class SharedPrefUtils {
  /// We creates a [SharedPreferences] class instance.
  /// It will use to set and get the data.
  static final SharedPreferences _sharedPreferences = sl<SharedPreferences>();

  static T getValue<T>(String key, T defaultValue) {
    dynamic value = _sharedPreferences.get(key) ?? defaultValue;
    if (value is List) {
      return List<String>.from(value) as T;
    }
    return value as T;
  }

  static void setValue(String key, Object value) {
    if (value is int) {
      _sharedPreferences.setInt(key, value);
    } else if (value is bool) {
      _sharedPreferences.setBool(key, value);
    } else if (value is double) {
      _sharedPreferences.setDouble(key, value);
    } else if (value is String) {
      _sharedPreferences.setString(key, value);
    } else if (value is List<String>) {
      _sharedPreferences.setStringList(key, value);
    }
  }

  static void removeValue(String key) {
    _sharedPreferences.remove(key);
  }

  static Future<void> clearSharedPref() async {
    await _sharedPreferences.clear();
  }
}

class SharedPrefUtilsKeys {
  static String isLoggedIn = 'isLoggedIn';
  static String userToken = 'userToken';
  static String userName = 'userName';
  static String isRememberMe = 'isRememberMe';
  static String setControlPermissions = 'setControlPermissions';
  static String userPermissions = 'userPermissions';
  static String postcodesApiKey = 'postcodesApiKey';
}
