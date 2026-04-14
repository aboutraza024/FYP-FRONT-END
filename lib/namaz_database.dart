import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class NamazTimeModel {
  final String fajrBefore, fajrAfter;
  final String dhuhrBefore, dhuhrAfter;
  final String asrBefore, asrAfter;
  final String maghribBefore, maghribAfter;
  final String ishaBefore, ishaAfter;
  final String jummaBefore, jummaAfter;
  
  final int fajrOn, dhuhrOn, asrOn, maghribOn, ishaOn, jummaOn;

  NamazTimeModel({
    required this.fajrBefore, required this.fajrAfter,
    required this.dhuhrBefore, required this.dhuhrAfter,
    required this.asrBefore, required this.asrAfter,
    required this.maghribBefore, required this.maghribAfter,
    required this.ishaBefore, required this.ishaAfter,
    required this.jummaBefore, required this.jummaAfter,
    this.fajrOn = 1, this.dhuhrOn = 1, this.asrOn = 1,
    this.maghribOn = 1, this.ishaOn = 1, this.jummaOn = 1,
  });

  Map<String, dynamic> toMap() => {
    'id': 1,
    'fajrBefore': fajrBefore, 'fajrAfter': fajrAfter,
    'dhuhrBefore': dhuhrBefore, 'dhuhrAfter': dhuhrAfter,
    'asrBefore': asrBefore, 'asrAfter': asrAfter,
    'maghribBefore': maghribBefore, 'maghribAfter': maghribAfter,
    'ishaBefore': ishaBefore, 'ishaAfter': ishaAfter,
    'jummaBefore': jummaBefore, 'jummaAfter': jummaAfter,
    'fajrOn': fajrOn, 'dhuhrOn': dhuhrOn, 'asrOn': asrOn,
    'maghribOn': maghribOn, 'ishaOn': ishaOn, 'jummaOn': jummaOn,
  };

  factory NamazTimeModel.fromMap(Map<String, dynamic> map) {
    return NamazTimeModel(
      fajrBefore: map['fajrBefore'] ?? '', fajrAfter: map['fajrAfter'] ?? '',
      dhuhrBefore: map['dhuhrBefore'] ?? '', dhuhrAfter: map['dhuhrAfter'] ?? '',
      asrBefore: map['asrBefore'] ?? '', asrAfter: map['asrAfter'] ?? '',
      maghribBefore: map['maghribBefore'] ?? '', maghribAfter: map['maghribAfter'] ?? '',
      ishaBefore: map['ishaBefore'] ?? '', ishaAfter: map['ishaAfter'] ?? '',
      jummaBefore: map['jummaBefore'] ?? '', jummaAfter: map['jummaAfter'] ?? '',
      fajrOn: map['fajrOn'] ?? 1, dhuhrOn: map['dhuhrOn'] ?? 1, asrOn: map['asrOn'] ?? 1,
      maghribOn: map['maghribOn'] ?? 1, ishaOn: map['ishaOn'] ?? 1, jummaOn: map['jummaOn'] ?? 1,
    );
  }
}

class NamazDatabase {
  static Database? _db;
  static final NamazDatabase instance = NamazDatabase._internal();
  
  NamazDatabase._internal();

  // CRITICAL: Used by background alarms to ensure the connection is alive
  Future<Database> get database async {
    if (_db != null && _db!.isOpen) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'namaz_silencer.db');
    return await openDatabase(
      path, 
      version: 1, 
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE times(
            id INTEGER PRIMARY KEY, 
            fajrBefore TEXT, fajrAfter TEXT, 
            dhuhrBefore TEXT, dhuhrAfter TEXT, 
            asrBefore TEXT, asrAfter TEXT, 
            maghribBefore TEXT, maghribAfter TEXT, 
            ishaBefore TEXT, ishaAfter TEXT, 
            jummaBefore TEXT, jummaAfter TEXT, 
            fajrOn INTEGER, dhuhrOn INTEGER, asrOn INTEGER, 
            maghribOn INTEGER, ishaOn INTEGER, jummaOn INTEGER
          )
        ''');
      }
    );
  }

  // Helper for background tasks to check if they can access data
  Future<bool> ensureOpen() async {
    try {
      await database;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> saveTimes(NamazTimeModel model) async {
    final db = await database;
    await db.insert('times', model.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getTimes() async {
    final db = await database;
    // Always fetch ID 1 to maintain configuration consistency
    return await db.query('times', where: 'id = ?', whereArgs: [1]);
  }

  Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }
}