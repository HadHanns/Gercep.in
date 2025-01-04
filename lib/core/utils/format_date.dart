import 'package:intl/intl.dart';

String formatDateAndTime(DateTime dateTime) {
  // Format: d MMM, yyyy - hh:mm a (contoh: 4 Jan, 2025 - 10:30 PM)
  return DateFormat("d MMM, yyyy - hh:mm a").format(dateTime);
}

// void main() {
//   DateTime now = DateTime.now(); // Ambil waktu saat ini
//   String formattedDate = formatDateAndTime(now); // Format tanggal & waktu
//   print(formattedDate); // Output contoh: 4 Jan, 2025 - 10:30 PM
// }