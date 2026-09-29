import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/date_utils.dart';
import '../../students/data/student_repository.dart';
import '../../students/domain/student.dart';
import '../data/attendance_repository.dart';
import '../domain/attendance_filter.dart';
import '../domain/attendance_record.dart';
import '../domain/attendance_status.dart';

final StateProvider<DateTime> selectedAttendanceDateProvider =
    StateProvider<DateTime>((Ref ref) => DateTime.now());

final StateProvider<String?> selectedAttendanceClassProvider =
    StateProvider<String?>((Ref ref) => null);

class AttendanceSheetState {
  const AttendanceSheetState({
    required this.students,
    required this.savedStatuses,
    required this.currentStatuses,
    required this.hasSavedRecord,
    this.isSaving = false,
  });

  final List<Student> students;
  final Map<int, AttendanceStatus> savedStatuses;
  final Map<int, AttendanceStatus> currentStatuses;
  final bool hasSavedRecord;
  final bool isSaving;

  int get presentCount => currentStatuses.values
      .where((AttendanceStatus s) => s == AttendanceStatus.present)
      .length;

  int get absentCount => currentStatuses.values
      .where((AttendanceStatus s) => s == AttendanceStatus.absent)
      .length;

  int get unmarkedCount => students.length - currentStatuses.length;

  bool get isDirty {
    if (savedStatuses.length != currentStatuses.length) return true;
    for (final MapEntry<int, AttendanceStatus> entry in currentStatuses.entries) {
      if (savedStatuses[entry.key] != entry.value) return true;
    }
    return false;
  }

  bool get canSave => isDirty && currentStatuses.isNotEmpty && !isSaving;

  AttendanceSheetState copyWith({
    List<Student>? students,
    Map<int, AttendanceStatus>? savedStatuses,
    Map<int, AttendanceStatus>? currentStatuses,
    bool? hasSavedRecord,
    bool? isSaving,
  }) {
    return AttendanceSheetState(
      students: students ?? this.students,
      savedStatuses: savedStatuses ?? this.savedStatuses,
      currentStatuses: currentStatuses ?? this.currentStatuses,
      hasSavedRecord: hasSavedRecord ?? this.hasSavedRecord,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class AttendanceSheetNotifier extends AutoDisposeAsyncNotifier<AttendanceSheetState?> {
  @override
  FutureOr<AttendanceSheetState?> build() async {
    final DateTime selectedDate = ref.watch(selectedAttendanceDateProvider);
    final String? selectedClass = ref.watch(selectedAttendanceClassProvider);

    if (selectedClass == null || selectedClass.isEmpty) {
      return null;
    }

    final StudentRepository studentRepo = ref.watch(studentRepositoryProvider);
    final AttendanceRepository attendanceRepo = ref.watch(attendanceRepositoryProvider);

    final String isoDate = AppDateUtils.toIsoDate(selectedDate);

    // 1. Fetch students belonging to this class
    final List<Student> students = await studentRepo.getAll(className: selectedClass);

    // 2. Fetch existing saved statuses for date & class
    final Map<int, AttendanceStatus> saved = await attendanceRepo.getStatusesForDateAndClass(
      date: isoDate,
      className: selectedClass,
    );

    final bool hasRecord = saved.isNotEmpty;

    return AttendanceSheetState(
      students: students,
      savedStatuses: Map<int, AttendanceStatus>.from(saved),
      currentStatuses: Map<int, AttendanceStatus>.from(saved),
      hasSavedRecord: hasRecord,
      isSaving: false,
    );
  }

  void setStatus(int studentId, AttendanceStatus status) {
    final AttendanceSheetState? current = state.valueOrNull;
    if (current == null) return;

    final Map<int, AttendanceStatus> updated = Map<int, AttendanceStatus>.from(current.currentStatuses);
    updated[studentId] = status;

    state = AsyncData<AttendanceSheetState?>(current.copyWith(currentStatuses: updated));
  }

  void markAll(AttendanceStatus status) {
    final AttendanceSheetState? current = state.valueOrNull;
    if (current == null) return;

    final Map<int, AttendanceStatus> updated = <int, AttendanceStatus>{};
    for (final Student student in current.students) {
      if (student.id != null) {
        updated[student.id!] = status;
      }
    }

    state = AsyncData<AttendanceSheetState?>(current.copyWith(currentStatuses: updated));
  }

  Future<void> save() async {
    final AttendanceSheetState? current = state.valueOrNull;
    if (current == null || !current.canSave) return;

    state = AsyncData<AttendanceSheetState?>(current.copyWith(isSaving: true));

    try {
      final DateTime selectedDate = ref.read(selectedAttendanceDateProvider);
      final String? selectedClass = ref.read(selectedAttendanceClassProvider);
      final String isoDate = AppDateUtils.toIsoDate(selectedDate);

      final AttendanceRepository repo = ref.read(attendanceRepositoryProvider);
      await repo.saveBatch(
        date: isoDate,
        className: selectedClass!,
        statuses: current.currentStatuses,
      );

      // Invalidate attendance records and summary providers so other tabs refresh
      ref.invalidate(attendanceRecordsProvider);

      state = AsyncData<AttendanceSheetState?>(
        current.copyWith(
          savedStatuses: Map<int, AttendanceStatus>.from(current.currentStatuses),
          hasSavedRecord: true,
          isSaving: false,
        ),
      );
    } catch (e, st) {
      state = AsyncError<AttendanceSheetState?>(e, st);
    }
  }
}

final AutoDisposeAsyncNotifierProvider<AttendanceSheetNotifier, AttendanceSheetState?> attendanceSheetProvider =
    AsyncNotifierProvider.autoDispose<AttendanceSheetNotifier, AttendanceSheetState?>(
  AttendanceSheetNotifier.new,
);

// Attendance Records History
final StateProvider<AttendanceFilter> attendanceRecordsFilterProvider =
    StateProvider<AttendanceFilter>((Ref ref) => const AttendanceFilter());

final AutoDisposeFutureProvider<List<AttendanceRecord>> attendanceRecordsProvider =
    FutureProvider.autoDispose<List<AttendanceRecord>>((Ref ref) async {
  final AttendanceRepository repo = ref.watch(attendanceRepositoryProvider);
  final AttendanceFilter filter = ref.watch(attendanceRecordsFilterProvider);
  return repo.searchRecords(filter);
});
