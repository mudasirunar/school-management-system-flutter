import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'app_database.dart';

final FutureProvider<Database> databaseProvider = FutureProvider<Database>((Ref ref) async {
  return AppDatabase.database;
});
