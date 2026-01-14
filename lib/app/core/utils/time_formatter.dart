class TimeFormatter {
  /// Format DateTime to "time ago" format (e.g., "2 hours ago", "3 days ago")
  static String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes menit yang lalu';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours jam yang lalu';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days hari yang lalu';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks minggu yang lalu';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months bulan yang lalu';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years tahun yang lalu';
    }
  }

  /// Format DateTime to readable date format
  static String formatDate(DateTime dateTime) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
  }

  /// Format DateTime to readable datetime format
  static String formatDateTime(DateTime dateTime) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year} ${hour}:${minute}';
  }
}
