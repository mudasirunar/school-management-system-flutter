enum AttendanceStatus {
  present('present', 'Present'),
  absent('absent', 'Absent');

  const AttendanceStatus(this.value, this.label);
  final String value;
  final String label;

  static AttendanceStatus? fromValue(String? value) {
    if (value == null) return null;
    for (final AttendanceStatus status in AttendanceStatus.values) {
      if (status.value == value.toLowerCase()) return status;
    }
    return null;
  }
}
