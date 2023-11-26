import 'package:shared_preferences/shared_preferences.dart';

class VideoStorage {
  static const String videoListKey = 'videoListKey';

  static Future<List<String>> getVideoPaths() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(videoListKey) ?? [];
  }

  static Future<void> saveVideoPath(String path) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> videoPaths = prefs.getStringList(videoListKey) ?? [];
    videoPaths.add(path);
    prefs.setStringList(videoListKey, videoPaths);
  }

  static Future<void> removeVideoPath(String path) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> videoPaths = prefs.getStringList(videoListKey) ?? [];
    videoPaths.remove(path);
    prefs.setStringList(videoListKey, videoPaths);
  }
}
