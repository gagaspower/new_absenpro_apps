class TimeHelper {
  /// Ubah format jam dari backend, misal "08:00:00" (HH:mm:ss),
  /// jadi "08:00" (HH:mm) tanpa detik.
  /// Return null kalau data-nya kosong/null.
  static String? formatTime(dynamic rawTime) {
    if (rawTime == null) return null;
    final value = rawTime.toString();
    if (value.length >= 5) return value.substring(0, 5);
    return value;
  }

  /// Gabungkan dua jam jadi satu string rentang, misal "08:00 - 17:00".
  /// Return "-" kalau salah satu (atau dua-duanya) kosong.
  static String formatTimeRange(String? start, String? end) {
    if (start == null || end == null) return '-';
    return '$start - $end';
  }

  /// Ucapan salam otomatis sesuai jam saat ini:
  /// 04.00–10.59 -> Selamat pagi
  /// 11.00–14.59 -> Selamat siang
  /// 15.00–17.59 -> Selamat sore
  /// selain itu   -> Selamat malam
  static String greeting([DateTime? now]) {
    final hour = (now ?? DateTime.now()).hour;
    if (hour >= 4 && hour < 11) return 'Selamat pagi';
    if (hour >= 11 && hour < 15) return 'Selamat siang';
    if (hour >= 15 && hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  /// Cek apakah jam sekarang berada di antara [start] dan [end]
  /// (format "HH:mm", boleh juga "HH:mm:ss" — otomatis dipotong).
  /// Dipakai misal untuk cek apakah window absen masuk/pulang masih buka.
  /// Return false kalau start atau end kosong/null/tidak valid.
  static bool isWithinRange(String? start, String? end, [DateTime? now]) {
    final startMinutes = _toMinutes(start);
    final endMinutes = _toMinutes(end);
    if (startMinutes == null || endMinutes == null) return false;

    final current = now ?? DateTime.now();
    final currentMinutes = current.hour * 60 + current.minute;

    if (startMinutes <= endMinutes) {
      // Rentang normal dalam hari yang sama, misal 07:30 - 08:00
      return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
    } else {
      // Rentang melewati tengah malam, misal 22:00 - 02:00
      return currentMinutes >= startMinutes || currentMinutes <= endMinutes;
    }
  }

  /// Ubah "HH:mm" atau "HH:mm:ss" jadi total menit sejak 00:00.
  /// Return null kalau formatnya tidak valid.
  static int? _toMinutes(String? time) {
    if (time == null) return null;
    final parts = time.split(':');
    if (parts.length < 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;

    return hour * 60 + minute;
  }
}
