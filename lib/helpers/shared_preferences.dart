import 'package:shared_preferences/shared_preferences.dart';

void clearSharedPreferences() async {
  final sharedPrefs = await SharedPreferences.getInstance();
  await sharedPrefs.remove('destinationId');
  await sharedPrefs.remove('projectId');
}

void saveString(String key, String value) async {
  final sharedPrefs = await SharedPreferences.getInstance();
  await sharedPrefs.setString(key, value);
}