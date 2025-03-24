import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';

class ChatDatabase {
  static final ChatDatabase instance = ChatDatabase._init();

  static Database? _database;

  ChatDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('chat.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // Increment the version
      onCreate: _createDB,
      // onUpgrade: _upgradeDB,
    );
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add 'status' and 'isRead' columns during upgrade
      await db.execute(
          'ALTER TABLE messages ADD COLUMN status TEXT DEFAULT "sent"');
      await db.execute(
          'ALTER TABLE messages ADD COLUMN isRead INTEGER DEFAULT false');
    }
  }

  Future<void> insertMessage(Map<String, dynamic> message) async {
    final db = await instance.database;
    await db.insert('messages', message);
  }

  Future<List<Map<String, dynamic>>> getMessages() async {
    final db = await instance.database;
    return await db.query('messages', orderBy: 'timestamp ASC');
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        senderId TEXT,
        receiverId TEXT,
        chatId TEXT,
        status TEXT,
        text TEXT,
        timestamp TEXT
      )
    ''');
  }

  // Future<void> removeIsReadColumn() async {
  //   try {
  //     final db = await database;
  //     await db.execute('DROP TABLE IF EXISTS messages');
  //     await _createDB(db, 1);
  //     print('Successfully removed isRead column from SQLite');
  //   } catch (e) {
  //     print('Error removing isRead column from SQLite: $e');
  //   }
  // }
}

// In any file that displays message status
// Widget buildMessageStatus(String status) {
//   switch (status) {
//     case 'sent':
//       return const Icon(Icons.check, size: 16);
//     case 'received':
//       return const Icon(Icons.done_all, size: 16);
//     case 'read':
//       return const Icon(Icons.done_all, size: 16, color: Colors.amber);
//     default:
//       return const Icon(Icons.check, size: 16);
//   }
// }

// For text styling based on read status
TextStyle getMessageStyle(String status) {
  return TextStyle(
    fontWeight: status == 'read' ? FontWeight.normal : FontWeight.bold,
    // ...other style properties...
  );
}
