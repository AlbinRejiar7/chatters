String getLastSeen(DateTime lastSeen) {
  final now = DateTime.now();
  final difference = now.difference(lastSeen);

  if (difference.inMinutes < 1) {
    return "Last seen just now";
  } else if (difference.inMinutes < 60) {
    return "Last seen ${difference.inMinutes} minutes ago";
  } else if (difference.inHours < 24) {
    return "Last seen ${difference.inHours} hours ago";
  } else if (difference.inDays == 1) {
    return "Last seen yesterday at ${_formatTime(lastSeen)}";
  } else if (difference.inDays < 7) {
    return "Last seen ${difference.inDays} days ago";
  } else {
    return "Last seen on ${_formatDate(lastSeen)}";
  }
}

String _formatTime(DateTime time) {
  return "${time.hour % 12 == 0 ? 12 : time.hour % 12}:${time.minute.toString().padLeft(2, '0')} ${time.hour < 12 ? 'AM' : 'PM'}";
}

String _formatDate(DateTime date) {
  return "${_monthName(date.month)} ${date.day}, ${date.year}";
}

String _monthName(int month) {
  const months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];
  return months[month - 1];
}
