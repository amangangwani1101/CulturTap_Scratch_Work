import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
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
            productDescription TEXT
          )
        ''');
      },
      version: 1,
    );
  }
}
