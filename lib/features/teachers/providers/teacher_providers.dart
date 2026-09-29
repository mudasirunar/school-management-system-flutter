import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/teacher_repository.dart';
import '../domain/teacher.dart';

final StateProvider<String> teacherSearchProvider = StateProvider<String>((Ref ref) => '');

class TeacherListNotifier extends AsyncNotifier<List<Teacher>> {
  @override
  FutureOr<List<Teacher>> build() async {
    final TeacherRepository repo = ref.watch(teacherRepositoryProvider);
    final String query = ref.watch(teacherSearchProvider);

    return repo.getAll(query: query);
  }

  Future<void> addTeacher(Teacher teacher) async {
    final TeacherRepository repo = ref.read(teacherRepositoryProvider);
    await repo.insert(teacher);
    ref.invalidateSelf();
    await future;
  }

  Future<void> updateTeacher(Teacher teacher) async {
    final TeacherRepository repo = ref.read(teacherRepositoryProvider);
    await repo.update(teacher);
    ref.invalidateSelf();
    await future;
  }

  Future<void> deleteTeacher(int id, {String? teacherName}) async {
    final TeacherRepository repo = ref.read(teacherRepositoryProvider);
    await repo.delete(id, teacherName: teacherName);
    ref.invalidateSelf();
    await future;
  }
}

final AsyncNotifierProvider<TeacherListNotifier, List<Teacher>> teacherListProvider =
    AsyncNotifierProvider<TeacherListNotifier, List<Teacher>>(TeacherListNotifier.new);
