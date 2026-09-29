import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/db_constants.dart';
import '../../../core/database/database_provider.dart';
import '../domain/activity_entry.dart';

class ActivityRepository {
  const ActivityRepository(this._db);

  final Database _db;

  Future<void> log(
    String type,
    String message, {
    DatabaseExecutor? executor,
  }) async {
    final DatabaseExecutor db = executor ?? _db;
    final String now = DateTime.now().toIso8601String();

    await db.insert(
      DbConstants.tableActivityLog,
      <String, dynamic>{
        DbConstants.columnActivityType: type,
        DbConstants.columnActivityMessage: message,
        DbConstants.columnCreatedAt: now,
      },
    );

    // Prune entries beyond maxActivityLogEntries (keep recent 200)
    await db.rawDelete('''
      DELETE FROM ${DbConstants.tableActivityLog}
      WHERE ${DbConstants.columnId} NOT IN (
        SELECT ${DbConstants.columnId}
        FROM ${DbConstants.tableActivityLog}
        ORDER BY ${DbConstants.columnCreatedAt} DESC
        LIMIT ${AppConstants.maxActivityLogEntries}
      )
    ''');
  }

  Future<List<ActivityEntry>> getRecent({
    int limit = AppConstants.recentActivityDisplayLimit,
  }) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      DbConstants.tableActivityLog,
      orderBy: '${DbConstants.columnCreatedAt} DESC',
      limit: limit,
    );

    return maps.map(ActivityEntry.fromMap).toList();
  }
}

final Provider<ActivityRepository> activityRepositoryProvider =
    Provider<ActivityRepository>((Ref ref) {
  final AsyncValue<Database> dbAsync = ref.watch(databaseProvider);
  return ActivityRepository(dbAsync.requireValue);
});
