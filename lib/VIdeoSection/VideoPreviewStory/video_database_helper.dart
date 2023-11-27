// video_database_helper.dart
import 'package:learn_flutter/VIdeoSection/VideoPreviewStory/video_info2.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class VideoDatabaseHelper {
  static final VideoDatabaseHelper _instance = VideoDatabaseHelper._internal();

  factory VideoDatabaseHelper() => _instance;

  static Database? _database;

  VideoDatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final path = join(await getDatabasesPath(), 'video_database.db');
    return openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE videos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        videoUrl TEXT,
        latitude REAL,
        longitude REAL
      )
    ''');
  }

  Future<int> insertVideo(VideoInfo2 videoInfo) async {
    final db = await database;
    return await db.insert('videos', videoInfo.toMap());
  }

  Future<bool> hasVideos() async {
    final db = await database;
    if (db == null) {
      // Handle the case where the database is null
      return false;
    }

    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM videos')) ?? 0;
    return count > 0;
  }

  Future<void> deleteAllVideos() async {
    final db = await database;
    await db.delete('videos');
  }

  Future<void> deleteVideoByPath(String videoUrl) async {
    final db = await database;
    await db.delete('videos', where: 'videoUrl = ?', whereArgs: [videoUrl]);
  }

  Future<List<VideoInfo2>> getAllVideos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('videos');
    return List.generate(maps.length, (i) {
      return VideoInfo2(
        videoUrl: maps[i]['videoUrl'],
        latitude: maps[i]['latitude'],
        longitude: maps[i]['longitude'],
      );
    });
  }



}


