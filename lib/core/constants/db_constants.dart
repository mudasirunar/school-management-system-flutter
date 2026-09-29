class DbConstants {
  DbConstants._();

  static const String databaseName = 'school_manager.db';
  static const int databaseVersion = 1;

  // Tables
  static const String tableStudents = 'students';
  static const String tableTeachers = 'teachers';
  static const String tableAttendance = 'attendance';
  static const String tableActivityLog = 'activity_log';

  // Common Columns
  static const String columnId = 'id';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';

  // Students Columns
  static const String columnStudentName = 'name';
  static const String columnStudentRollNumber = 'roll_number';
  static const String columnStudentClassName = 'class_name';
  static const String columnStudentAge = 'age';
  static const String columnStudentGender = 'gender';
  static const String columnStudentContact = 'contact';

  // Teachers Columns
  static const String columnTeacherName = 'name';
  static const String columnTeacherEmployeeId = 'employee_id';
  static const String columnTeacherSubject = 'subject';
  static const String columnTeacherContact = 'contact';
  static const String columnTeacherEmail = 'email';

  // Attendance Columns
  static const String columnAttendanceStudentId = 'student_id';
  static const String columnAttendanceDate = 'date';
  static const String columnAttendanceStatus = 'status';

  // Activity Log Columns
  static const String columnActivityType = 'type';
  static const String columnActivityMessage = 'message';

  // Activity Types
  static const String activityStudentAdded = 'student_added';
  static const String activityStudentUpdated = 'student_updated';
  static const String activityStudentDeleted = 'student_deleted';
  static const String activityTeacherAdded = 'teacher_added';
  static const String activityTeacherUpdated = 'teacher_updated';
  static const String activityTeacherDeleted = 'teacher_deleted';
  static const String activityAttendanceSaved = 'attendance_saved';

  // Attendance Statuses
  static const String statusPresent = 'present';
  static const String statusAbsent = 'absent';
  static const String statusLeave = 'leave';
}
