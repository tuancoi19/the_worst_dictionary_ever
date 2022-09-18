// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:the_worst_dictionary_ever/model/word.dart';

class DictDatabase {
  final String DB_NAME = 'en_vi_dict.db';
  final String TABLE = 'en_vi_dict';
  final String WORD = 'word';
  final String PRONOUNCE = 'pronounce';
  final String MEANING = 'meaning';

  static final DictDatabase _instance = DictDatabase._init();
  static Database? _database;

  DictDatabase._init();

  factory DictDatabase() {
    return _instance;
  }

  Future<Database> get db async {
    if (_database != null) {
      return _database!;
    }
    _database = await init();
    return _database!;
  }

  Future<Database> init() async {
    var databasePath = await getDatabasesPath();
    var path = join(databasePath, DB_NAME);
    var exists = await databaseExists(path);
    if (!exists) {
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}
      ByteData data = await rootBundle.load(join('assets/databases', DB_NAME));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes, flush: true);
    }
    var db = await openDatabase(path, readOnly: true);
    return db;
  }

  Future<Word?> fetchWordByWord(String word) async {
    var client = await db;
    final Future<List<Map<String, dynamic>>> futureMaps =
        client.query(TABLE, where: '$WORD = ?', whereArgs: [word]);
    var maps = await futureMaps;
    if (maps.isNotEmpty) {
      return Word.fromJson(maps.first);
    }
    return null;
  }

  Future<List<Word>> searchWordResults(String searchWord) async {
    var client = await db;
    var response = await client
        .query(TABLE, where: '$WORD like ?', whereArgs: ['$searchWord%%']);
    List<Word> list = response.map((c) => Word.fromJson(c)).toList();
    return list;
  }
}
