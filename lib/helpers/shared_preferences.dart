import 'package:flutter_minimal_integration/helpers/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

void clearSharedPreferences() async {
  final sharedPrefs = await SharedPreferences.getInstance();
  await sharedPrefs.remove(destinationIdString);
  await sharedPrefs.remove(projectIdString);
}

void saveString(String key, String value) async {
  final sharedPrefs = await SharedPreferences.getInstance();
  await sharedPrefs.setString(key, value);
}

void saveBool(String key, bool value) async {
  final sharedPrefs = await SharedPreferences.getInstance();
  await sharedPrefs.setBool(key, value);
}

Future<String> getStringForKey(String key) async {
  final sharedPrefs = await SharedPreferences.getInstance();
  return sharedPrefs.getString(key) ?? '';
}

Future<bool> getBoolForKey(String key) async {
  final sharedPrefs = await SharedPreferences.getInstance();
  return sharedPrefs.getBool(key) ?? false;
}