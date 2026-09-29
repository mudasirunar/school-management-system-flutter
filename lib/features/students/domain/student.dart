import '../../../core/constants/db_constants.dart';

class Student {
  const Student({
    this.id,
    required this.name,
    required this.rollNumber,
    required this.className,
    required this.age,
    required this.gender,
    required this.contact,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String name;
  final String rollNumber;
  final String className;
  final int age;
  final String gender;
  final String contact;
  final String createdAt;
  final String updatedAt;

  Student copyWith({
    int? id,
    String? name,
    String? rollNumber,
    String? className,
    int? age,
    String? gender,
    String? contact,
    String? createdAt,
    String? updatedAt,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      rollNumber: rollNumber ?? this.rollNumber,
      className: className ?? this.className,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      contact: contact ?? this.contact,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      if (id != null) DbConstants.columnId: id,
      DbConstants.columnStudentName: name.trim(),
      DbConstants.columnStudentRollNumber: rollNumber.trim(),
      DbConstants.columnStudentClassName: className.trim(),
      DbConstants.columnStudentAge: age,
      DbConstants.columnStudentGender: gender.trim(),
      DbConstants.columnStudentContact: contact.trim(),
      DbConstants.columnCreatedAt: createdAt,
      DbConstants.columnUpdatedAt: updatedAt,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map[DbConstants.columnId] as int?,
      name: map[DbConstants.columnStudentName] as String,
      rollNumber: map[DbConstants.columnStudentRollNumber] as String,
      className: map[DbConstants.columnStudentClassName] as String,
      age: map[DbConstants.columnStudentAge] as int,
      gender: map[DbConstants.columnStudentGender] as String,
      contact: map[DbConstants.columnStudentContact] as String,
      createdAt: map[DbConstants.columnCreatedAt] as String,
      updatedAt: map[DbConstants.columnUpdatedAt] as String,
    );
  }
}
