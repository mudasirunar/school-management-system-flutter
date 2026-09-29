import '../../../core/constants/db_constants.dart';

class Teacher {
  const Teacher({
    this.id,
    required this.name,
    required this.employeeId,
    required this.subject,
    required this.contact,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String name;
  final String employeeId;
  final String subject;
  final String contact;
  final String email;
  final String createdAt;
  final String updatedAt;

  Teacher copyWith({
    int? id,
    String? name,
    String? employeeId,
    String? subject,
    String? contact,
    String? email,
    String? createdAt,
    String? updatedAt,
  }) {
    return Teacher(
      id: id ?? this.id,
      name: name ?? this.name,
      employeeId: employeeId ?? this.employeeId,
      subject: subject ?? this.subject,
      contact: contact ?? this.contact,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      if (id != null) DbConstants.columnId: id,
      DbConstants.columnTeacherName: name.trim(),
      DbConstants.columnTeacherEmployeeId: employeeId.trim(),
      DbConstants.columnTeacherSubject: subject.trim(),
      DbConstants.columnTeacherContact: contact.trim(),
      DbConstants.columnTeacherEmail: email.trim().toLowerCase(),
      DbConstants.columnCreatedAt: createdAt,
      DbConstants.columnUpdatedAt: updatedAt,
    };
  }

  factory Teacher.fromMap(Map<String, dynamic> map) {
    return Teacher(
      id: map[DbConstants.columnId] as int?,
      name: map[DbConstants.columnTeacherName] as String,
      employeeId: map[DbConstants.columnTeacherEmployeeId] as String,
      subject: map[DbConstants.columnTeacherSubject] as String,
      contact: map[DbConstants.columnTeacherContact] as String,
      email: map[DbConstants.columnTeacherEmail] as String,
      createdAt: map[DbConstants.columnCreatedAt] as String,
      updatedAt: map[DbConstants.columnUpdatedAt] as String,
    );
  }
}
