import '../../../core/constants/db_constants.dart';

class ActivityEntry {
  const ActivityEntry({
    this.id,
    required this.type,
    required this.message,
    required this.createdAt,
  });

  final int? id;
  final String type;
  final String message;
  final String createdAt;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      if (id != null) DbConstants.columnId: id,
      DbConstants.columnActivityType: type,
      DbConstants.columnActivityMessage: message,
      DbConstants.columnCreatedAt: createdAt,
    };
  }

  factory ActivityEntry.fromMap(Map<String, dynamic> map) {
    return ActivityEntry(
      id: map[DbConstants.columnId] as int?,
      type: map[DbConstants.columnActivityType] as String,
      message: map[DbConstants.columnActivityMessage] as String,
      createdAt: map[DbConstants.columnCreatedAt] as String,
    );
  }
}
