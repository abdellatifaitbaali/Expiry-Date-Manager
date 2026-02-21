import 'package:flutter/material.dart';
import 'constants.dart';

class DateHelpers {
  static int daysUntilExpiry(DateTime expiryDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return expiry.difference(today).inDays;
  }

  static String expiryLabel(DateTime expiryDate) {
    final days = daysUntilExpiry(expiryDate);
    if (days < 0) return 'Expired ${-days} day${-days == 1 ? '' : 's'} ago';
    if (days == 0) return 'Expires today!';
    if (days == 1) return 'Expires tomorrow';
    return 'Expires in $days days';
  }

  static Color expiryColor(DateTime expiryDate) {
    final days = daysUntilExpiry(expiryDate);
    if (days < 0) return AppConstants.expiredColor;
    if (days == 0) return AppConstants.expiredColor;
    if (days <= 1) return AppConstants.warningColor;
    if (days <= 3) return AppConstants.cautionColor;
    if (days <= 7) return AppConstants.accentColor;
    return AppConstants.safeColor;
  }

  static IconData expiryIcon(DateTime expiryDate) {
    final days = daysUntilExpiry(expiryDate);
    if (days < 0) return Icons.error_rounded;
    if (days <= 1) return Icons.warning_amber_rounded;
    if (days <= 3) return Icons.access_time_rounded;
    return Icons.check_circle_rounded;
  }

  static String formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
