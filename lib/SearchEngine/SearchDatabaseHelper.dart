import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SearchDatabaseHelper {
  static final SearchDatabaseHelper _instance = SearchDatabaseHelper.internal();

  factory SearchDatabaseHelper() => _instance;

  static Database? _database;

  SearchDatabaseHelper.internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'search_history.db');
    return await openDatabase(path, version: 1, onCreate: _createTable);
  }

  Future<void> _createTable(Database db, int version) async {
    await db.execute('''
      CREATE TABLE search_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        query TEXT
      )
    ''');
  }

  Future<void> insertSearchQuery(String query) async {
    Database db = await database;
    await db.insert('search_history', {'query': query});
  }

  Future<List<String>> getSearchHistory() async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query('search_history');
    return result.map((e) => e['query'].toString()).toList();
  }
}
