import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:learn_flutter/VIdeoSection/Draft_Local_Database/draft.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }


  Future<void> deleteDraft(int? draftId) async {
    final db = await database;
    if (draftId != null) {
      await db.delete('drafts', where: 'id = ?', whereArgs: [draftId]);
    }
  }


  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), 'drafts.db');
    return await openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE drafts(
            id INTEGER PRIMARY KEY,
            latitude REAL,
            longitude REAL,
            liveLocation Text,
            videoPaths TEXT,
            selectedLabel TEXT,
            selectedCategory TEXT,
            selectedGenre TEXT,
            experienceDescription TEXT,
            selectedLoveAboutHere TEXT,
            dontLikeAboutHere TEXT,
            selectedaCategory TEXT,
            reviewText TEXT,
            starRating INTEGER,
            selectedVisibility TEXT,
            storyTitle TEXT,
            productDescription TEXT,
            selectedOption TEXT,
            productPrice TEXT,
            transportationPricing TEXT
          )
        ''');
      },
      version: 1,
    );
  }

  Future<void> updateDraft(Draft draft) async {
    final db = await database;
    await db.update(
      'drafts',
      draft.toMap(),
      where: 'id = ?',
      whereArgs: [draft.id],
    );
  }


  // Add this method to get all drafts from the database
  Future<List<Map<String, dynamic>>?> getAllDrafts() async {
    final Database db = await database;
    return db.query('drafts');
  }
}
