// lib/services/local_db.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDb {
  static Database? _db;

  static Future<Database> get instance async {
    _db ??= await _open();
    return _db!;
  }

  static Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'myapp.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) => db.execute('''
        CREATE TABLE contacts (
          id TEXT PRIMARY KEY,
          name TEXT,
          phone TEXT,
          email TEXT,
          created_at TEXT,
          is_uploaded INTEGER DEFAULT 0
        )
      '''),
    );
  }

  static Future<void> insert(Map<String, dynamic> data) async {
    final db = await instance;
    await db.insert('contacts', data);
  }

  static Future<List<Map<String, dynamic>>> getPending() async {
    final db = await instance;
    return db.query('contacts', where: 'is_uploaded = 0');
  }

  static Future<void> markUploaded(String id) async {
    final db = await instance;
    await db.update(
      'contacts',
      {'is_uploaded': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // এটা যোগ করুন — সব data আনো
  static Future<List<Map<String, dynamic>>> getAll() async {
    final db = await instance;
    return db.query('contacts', orderBy: 'created_at DESC');
  }

  // এটাও যোগ করুন — একটা delete করো
  static Future<void> delete(String id) async {
    final db = await instance;
    await db.delete('contacts', where: 'id = ?', whereArgs: [id]);
  }

  // এটাও যোগ করুন — সব clear করো
  static Future<void> clearAll() async {
    final db = await instance;
    await db.delete('contacts');
  }
}