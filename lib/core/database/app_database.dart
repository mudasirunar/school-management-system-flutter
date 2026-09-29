import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../constants/db_constants.dart';

class AppDatabase {
  AppDatabase._();

  static Database? _instance;

  static Future<Database> get database async {
    if (_instance != null) {
      return _instance!;
    }
    _instance = await initDatabase();
    return _instance!;
  }

  static Future<Database> initDatabase({String? inMemoryPath}) async {
    final String dbPath = inMemoryPath ?? p.join(await getDatabasesPath(), DbConstants.databaseName);

    return openDatabase(
      dbPath,
      version: DbConstants.databaseVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onConfigure(Database db) async {
    // Foreign key cascade requires PRAGMA foreign_keys = ON in SQLite
    await db.execute('PRAGMA foreign_keys = ON');
  }

  static Future<void> _onCreate(Database db, int version) async {
    final Batch batch = db.batch();

    // 1. students table
    batch.execute('''
      CREATE TABLE ${DbConstants.tableStudents} (
        ${DbConstants.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.columnStudentName} TEXT NOT NULL,
        ${DbConstants.columnStudentRollNumber} TEXT NOT NULL UNIQUE,
        ${DbConstants.columnStudentClassName} TEXT NOT NULL,
        ${DbConstants.columnStudentAge} INTEGER NOT NULL,
        ${DbConstants.columnStudentGender} TEXT NOT NULL,
        ${DbConstants.columnStudentContact} TEXT NOT NULL,
        ${DbConstants.columnCreatedAt} TEXT NOT NULL,
        ${DbConstants.columnUpdatedAt} TEXT NOT NULL
      )
    ''');

    batch.execute(
      'CREATE INDEX idx_students_class ON ${DbConstants.tableStudents} (${DbConstants.columnStudentClassName})',
    );
    batch.execute(
      'CREATE INDEX idx_students_name ON ${DbConstants.tableStudents} (${DbConstants.columnStudentName} COLLATE NOCASE)',
    );

    // 2. teachers table
    batch.execute('''
      CREATE TABLE ${DbConstants.tableTeachers} (
        ${DbConstants.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.columnTeacherName} TEXT NOT NULL,
        ${DbConstants.columnTeacherEmployeeId} TEXT NOT NULL UNIQUE,
        ${DbConstants.columnTeacherSubject} TEXT NOT NULL,
        ${DbConstants.columnTeacherContact} TEXT NOT NULL,
        ${DbConstants.columnTeacherEmail} TEXT NOT NULL,
        ${DbConstants.columnCreatedAt} TEXT NOT NULL,
        ${DbConstants.columnUpdatedAt} TEXT NOT NULL
      )
    ''');

    batch.execute(
      'CREATE INDEX idx_teachers_name ON ${DbConstants.tableTeachers} (${DbConstants.columnTeacherName} COLLATE NOCASE)',
    );

    // 3. attendance table
    batch.execute('''
      CREATE TABLE ${DbConstants.tableAttendance} (
        ${DbConstants.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.columnAttendanceStudentId} INTEGER NOT NULL,
        ${DbConstants.columnAttendanceDate} TEXT NOT NULL,
        ${DbConstants.columnAttendanceStatus} TEXT NOT NULL,
        ${DbConstants.columnUpdatedAt} TEXT NOT NULL,
        FOREIGN KEY (${DbConstants.columnAttendanceStudentId})
          REFERENCES ${DbConstants.tableStudents} (${DbConstants.columnId})
          ON DELETE CASCADE,
        UNIQUE(${DbConstants.columnAttendanceStudentId}, ${DbConstants.columnAttendanceDate})
      )
    ''');

    batch.execute(
      'CREATE INDEX idx_attendance_date ON ${DbConstants.tableAttendance} (${DbConstants.columnAttendanceDate})',
    );
    batch.execute(
      'CREATE INDEX idx_attendance_student ON ${DbConstants.tableAttendance} (${DbConstants.columnAttendanceStudentId})',
    );

    // 4. activity_log table
    batch.execute('''
      CREATE TABLE ${DbConstants.tableActivityLog} (
        ${DbConstants.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.columnActivityType} TEXT NOT NULL,
        ${DbConstants.columnActivityMessage} TEXT NOT NULL,
        ${DbConstants.columnCreatedAt} TEXT NOT NULL
      )
    ''');

    batch.execute(
      'CREATE INDEX idx_activity_created ON ${DbConstants.tableActivityLog} (${DbConstants.columnCreatedAt})',
    );

    await batch.commit(noResult: true);
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migration hooks for future schema versions
  }

  static Future<void> close() async {
    if (_instance != null && _instance!.isOpen) {
      await _instance!.close();
      _instance = null;
    }
  }
}
