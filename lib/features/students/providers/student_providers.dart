import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/student_repository.dart';
import '../domain/student.dart';

final StateProvider<String> studentSearchProvider = StateProvider<String>((Ref ref) => '');

final StateProvider<String?> studentClassFilterProvider = StateProvider<String?>((Ref ref) => null);

final FutureProvider<List<String>> studentClassListProvider =
    FutureProvider<List<String>>((Ref ref) async {
  final StudentRepository repo = ref.watch(studentRepositoryProvider);
  return repo.getClassNamesWithStudents();
});

class StudentListNotifier extends AsyncNotifier<List<Student>> {
  @override
  FutureOr<List<Student>> build() async {
    final StudentRepository repo = ref.watch(studentRepositoryProvider);
    final String query = ref.watch(studentSearchProvider);
    final String? className = ref.watch(studentClassFilterProvider);

    return repo.getAll(
      query: query,
      className: className,
    );
  }

  Future<void> addStudent(Student student) async {
    final StudentRepository repo = ref.read(studentRepositoryProvider);
    await repo.insert(student);
    ref.invalidate(studentClassListProvider);
    ref.invalidateSelf();
    await future;
  }

  Future<void> updateStudent(Student student) async {
    final StudentRepository repo = ref.read(studentRepositoryProvider);
    await repo.update(student);
    ref.invalidate(studentClassListProvider);
    ref.invalidateSelf();
    await future;
  }

  Future<void> deleteStudent(int id, {String? studentName}) async {
    final StudentRepository repo = ref.read(studentRepositoryProvider);
    await repo.delete(id, studentName: studentName);
    ref.invalidate(studentClassListProvider);
    ref.invalidateSelf();
    await future;
  }
}

final AsyncNotifierProvider<StudentListNotifier, List<Student>> studentListProvider =
    AsyncNotifierProvider<StudentListNotifier, List<Student>>(StudentListNotifier.new);
