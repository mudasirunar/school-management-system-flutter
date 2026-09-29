import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _isoFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _displayFormat = DateFormat('EEE, d MMM yyyy');
  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy');
  static final DateFormat _shortDisplayFormat = DateFormat('d MMM yyyy');

  static String toIsoDate(DateTime date) {
    return _isoFormat.format(date);
  }

  static DateTime parseIsoDate(String dateString) {
    return _isoFormat.parse(dateString);
  }

  static String todayIso() {
    return _isoFormat.format(DateTime.now());
  }

  static String formatForDisplay(DateTime date) {
    return _displayFormat.format(date);
  }

  static String formatIsoForDisplay(String isoDate) {
    try {
      final DateTime dt = parseIsoDate(isoDate);
      return _displayFormat.format(dt);
    } catch (_) {
      return isoDate;
    }
  }

  static String formatShortForDisplay(DateTime date) {
    return _shortDisplayFormat.format(date);
  }

  static String formatMonthYear(DateTime date) {
    return _monthYearFormat.format(date);
  }

  static String formatMonthYearFromYearMonth(int year, int month) {
    final DateTime dt = DateTime(year, month, 1);
    return _monthYearFormat.format(dt);
  }

  static (String, String) monthDateRange(int year, int month) {
    final DateTime firstDay = DateTime(year, month, 1);
    final DateTime nextMonth = (month == 12) ? DateTime(year + 1, 1, 1) : DateTime(year, month + 1, 1);
    final DateTime lastDay = nextMonth.subtract(const Duration(days: 1));
    return (toIsoDate(firstDay), toIsoDate(lastDay));
  }

  static bool isFutureDate(DateTime date) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime target = DateTime(date.year, date.month, date.day);
    return target.isAfter(today);
  }

  static String timeAgo(String isoCreatedAt) {
    try {
      final DateTime dt = DateTime.parse(isoCreatedAt);
      final Duration difference = DateTime.now().difference(dt);

      if (difference.inSeconds < 60) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 30) {
        return '${difference.inDays}d ago';
      } else {
        return DateFormat('d MMM').format(dt);
      }
    } catch (_) {
      return '';
    }
  }
}
