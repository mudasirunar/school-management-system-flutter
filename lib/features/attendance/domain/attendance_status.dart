enum AttendanceStatus {
  present('present', 'Present'),
  absent('absent', 'Absent'),
  leave('leave', 'Leave');

  const AttendanceStatus(this.value, this.label);
  final String value;
  final String label;

  bool get isPresent => this == AttendanceStatus.present;
  bool get isAbsent => this == AttendanceStatus.absent;
  bool get isLeave => this == AttendanceStatus.leave;

  static AttendanceStatus? fromValue(String? value) {
    if (value == null) return null;
    for (final AttendanceStatus status in AttendanceStatus.values) {
      if (status.value == value.toLowerCase()) return status;
    }
    return null;
  }
}
