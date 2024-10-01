import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  DbHelper._();

  static final DbHelper getInstance = DbHelper._();

  static final String TABLE_NOTE = 'note';
  static final String COLUMN_NOTE_SNO = 's_no';
  static final String COLUMN_NOTE_TITLE = 'title';
  static final String COLUMN_NOTE_DESC = 'desc';

  Database? myDb;

  Future<Database> getDB() async {
    if (myDb != null) {
      return myDb!;
    } else {
      myDb = await openDB();
      return myDb!;
    }
  }

  Future<Database> openDB() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbPath = join(appDir.path, 'noteDB.db');
    return await openDatabase(dbPath, onCreate: (db, version) {
      db.execute(
          'CREATE TABLE $TABLE_NOTE($COLUMN_NOTE_SNO INTEGER PRIMARY KEY AUTOINCREMENT, $COLUMN_NOTE_TITLE TEXT, $COLUMN_NOTE_DESC TEXT)');
    }, version: 1);
  }

  Future<bool> addNote({required String mTitle, required String mDesc}) async {
    var db = await getDB();
    try {
      int rowsAffected = await db.insert(
        TABLE_NOTE,
        {
          COLUMN_NOTE_TITLE: mTitle,
          COLUMN_NOTE_DESC: mDesc,
        },
      );
      print('Rows affected: $rowsAffected');
      return rowsAffected > 0;
    } catch (e) {
      print('Error inserting note: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getAllNotes() async {
    var db = await getDB();
    return await db.query(TABLE_NOTE);
  }

  // Update Data
  Future<bool> updateNode(
      {required String title, required desc, required int sno}) async {
    var db = await getDB();
    int rowsEffected = await db.update(
        TABLE_NOTE,
        {
          COLUMN_NOTE_TITLE: title,
          COLUMN_NOTE_DESC: desc,
        },
        where: '$COLUMN_NOTE_SNO = $sno');
    return rowsEffected > 0;
  }

  // Delete Data

  Future<bool> deleteNote({required int sno}) async {
    var db = await getDB();
    int rowEffected =
        await db.delete(TABLE_NOTE, where: '$COLUMN_NOTE_SNO = $sno');
    return rowEffected > 0;
  }
}
