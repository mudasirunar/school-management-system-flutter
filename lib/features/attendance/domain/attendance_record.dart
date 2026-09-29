import 'attendance_status.dart';

class AttendanceRecord {
  const AttendanceRecord({
    this.id,
    required this.studentId,
    required this.date,
    required this.status,
    required this.updatedAt,
    this.studentName,
    this.studentRollNumber,
    this.className,
  });

  final int? id;
  final int studentId;
  final String date;
  final AttendanceStatus status;
  final String updatedAt;
  final String? studentName;
  final String? studentRollNumber;
  final String? className;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      if (id != null) 'id': id,
      'student_id': studentId,
      'date': date,
      'status': status.value,
      'updated_at': updatedAt,
    };
  }

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      id: map['id'] as int?,
      studentId: map['student_id'] as int,
      date: map['date'] as String,
      status: AttendanceStatus.fromValue(map['status'] as String?) ?? AttendanceStatus.present,
      updatedAt: map['updated_at'] as String,
      studentName: map['student_name'] as String?,
      studentRollNumber: map['roll_number'] as String?,
      className: map['class_name'] as String?,
    );
  }
}
