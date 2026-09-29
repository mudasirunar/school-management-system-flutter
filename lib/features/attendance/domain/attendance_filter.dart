import 'attendance_status.dart';

class AttendanceFilter {
  const AttendanceFilter({
    this.query,
    this.className,
    this.date,
    this.status,
  });

  final String? query;
  final String? className;
  final String? date;
  final AttendanceStatus? status;

  AttendanceFilter copyWith({
    String? query,
    String? className,
    String? date,
    AttendanceStatus? status,
    bool clearQuery = false,
    bool clearClass = false,
    bool clearDate = false,
    bool clearStatus = false,
  }) {
    return AttendanceFilter(
      query: clearQuery ? null : (query ?? this.query),
      className: clearClass ? null : (className ?? this.className),
      date: clearDate ? null : (date ?? this.date),
      status: clearStatus ? null : (status ?? this.status),
    );
  }
}
