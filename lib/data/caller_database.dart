import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class CallerDatabase {
  CallerDatabase._();

  static final CallerDatabase instance = CallerDatabase._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    final documentsDir = await getApplicationDocumentsDirectory();
    final dbPath = join(documentsDir.path, 'callers.db');

    _database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE callers(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            phone_number TEXT UNIQUE NOT NULL,
            name TEXT NOT NULL,
            company TEXT,
            outstanding_balance REAL,
            notes TEXT
          )
        ''');

        await db.insert('callers', {
          'phone_number': '+15551234567',
          'name': 'Jordan Lee',
          'company': 'Northwind Logistics',
          'outstanding_balance': 2450.75,
          'notes': 'Awaiting invoice approval from finance.',
        });

        await db.insert('callers', {
          'phone_number': '+15559876543',
          'name': 'Riley Chen',
          'company': 'Contoso Health',
          'outstanding_balance': 0.0,
          'notes': 'Recently renewed contract. Follow up in Q3.',
        });
      },
    );

    return _database!;
  }
}
