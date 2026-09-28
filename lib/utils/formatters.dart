// lib/utils/formatters.dart

import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  /// Format currency (e.g., "LKR 1,250.00")
  static String currency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: 'LKR ',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  /// Format a short date (e.g., "28 Sep 2026")
  static String shortDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  /// Format just the day (e.g., "28")
  static String day(DateTime date) {
    return DateFormat('dd').format(date);
  }

  /// Format month and year (e.g., "September 2026")
  static String monthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  /// Format time (e.g., "2:30 PM")
  static String time(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  /// Format date for grouping headers (e.g., "Today", "Yesterday", or "28 Sep")
  static String groupHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Today';
    if (dateOnly == today.subtract(const Duration(days: 1))) return 'Yesterday';
    if (date.year == now.year) return DateFormat('dd MMM').format(date);
    return DateFormat('dd MMM yyyy').format(date);
  }

  /// Get the group key for a date (used for grouping expenses by day).
  static String groupKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
}
