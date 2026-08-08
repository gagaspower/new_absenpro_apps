import 'dart:async';
import 'package:absenpro/helpers/time_helper.dart';
import 'package:absenpro/models/attendance/attendance_model.dart';
import 'package:absenpro/pages/attendance/attendance_page.dart';
import 'package:absenpro/providers/auth/auth_provider.dart';
import 'package:absenpro/pages/cuti/form_cuti_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  static const Color primaryTeal = Color(0xFF2FC7CF);
  static const Color absenPulangColor = Color(0xFFFF9B9B);
  static const Color disabledBg = Color(0xFFE0E0E0);
  static const Color disabledFg = Color(0xFF9E9E9E);

  late String _greeting;
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    _greeting = TimeHelper.greeting();

    // Cek ulang tiap detik — supaya salam dan status aktif/nonaktif tombol
    // absen ter-update mendekati realtime, tanpa perlu buka-tutup app.
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _greeting = TimeHelper.greeting());
    });

    // Sinkron status absen hari ini ke server begitu Home pertama kali
    // dibuka — jangan cuma andalkan cache attendance_today dari login
    // terakhir.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AuthProvider>().refreshTodayAttendance();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Sinkron ulang juga saat app kembali dibuka dari background —
    // menutup kasus di laporan bug: user tidak logout, app dibiarkan
    // idle sampai hari berganti, lalu dibuka lagi.
    if (state == AppLifecycleState.resumed) {
      context.read<AuthProvider>().refreshTodayAttendance();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _clockTimer?.cancel();
    super.dispose();
  }

  /// Validasi ulang jendela waktu TEPAT SAAT tombol ditekan — jangan cuma
  /// andalkan status `canCheckIn`/`canCheckOut` dari hasil build terakhir,
  /// karena bisa saja beda beberapa saat sama kondisi sekarang (misal user
  /// nge-tap pas jendela waktu baru saja tertutup).
  Future<void> _handleAbsen({
    required bool isCheckIn,
    required String? start,
    required String? end,
  }) async {
    final stillValid = TimeHelper.isWithinRange(start, end);

    if (!stillValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isCheckIn
                ? 'Jendela waktu absen masuk sudah tertutup'
                : 'Jendela waktu absen pulang sudah tertutup',
          ),
        ),
      );
      setState(() {}); // paksa rebuild supaya tombol langsung ikut nonaktif
      return;
    }

    // Buka halaman selfie untuk verifikasi wajah — panggil API absen
    // (POST reference/absen/masuk) baru terjadi di dalam AbsenSelfiePage
    // setelah foto diambil & lolos cek wajah, bukan di sini.
    final attendance = await Navigator.push<AttendanceModel?>(
      context,
      MaterialPageRoute(
        builder: (_) => AbsenSelfiePage(isCheckIn: isCheckIn),
      ),
    );

    // Kalau berhasil, simpan data attendance terbaru dari backend ke local storage
    // agar status absen di Home langsung ter-update.
    if (attendance != null && mounted) {
      await context.read<AuthProvider>().updateAttendanceFromServer(attendance);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final employee = user?.employee;
    final shift = employee?.shift;

    final displayName = employee?.fullName ?? user?.name ?? '-';
    final shiftText = shift != null ? '${shift.name} | ${shift.jamKerja}' : '-';

    final attendance = employee?.attendanceToday;
    final hasCheckedIn = attendance?.hasCheckedIn ?? false;
    final hasCheckedOut = attendance?.hasCheckedOut ?? false;

    // Window absen masuk & pulang, sesuai jam yang diatur di data shift —
    // DAN belum dilakukan hari ini (mencegah absen 2x).
    final withinCheckInWindow = shift != null &&
        TimeHelper.isWithinRange(shift.checkInStart, shift.checkInEnd);
    final withinCheckOutWindow = shift != null &&
        TimeHelper.isWithinRange(shift.checkOutStart, shift.checkOutEnd);

    final canCheckIn = withinCheckInWindow && !hasCheckedIn;
    // Absen pulang butuh sudah absen masuk duluan hari itu.
    final canCheckOut = withinCheckOutWindow && hasCheckedIn && !hasCheckedOut;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: salam + nama + notifikasi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting,
                      style:
                          const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                _buildNotificationButton(),
              ],
            ),
            const SizedBox(height: 20),

            // Kartu jadwal hari ini
            _buildJadwalCard(shiftText),
            const SizedBox(height: 28),

            // Menu: Izin & Cuti, Lembur, Agenda
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMenuItem(
                    icon: Icons.send_outlined,
                    label: 'Izin & Cuti',
                    bgColor: const Color(0xFFFBE0E4),
                    iconColor: const Color(0xFFE0637A),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FormCutiPage(),
                        ),
                      );
                    }),
                _buildMenuItem(
                  icon: Icons.nightlight_round,
                  label: 'Lembur',
                  bgColor: const Color(0xFFDCEBFA),
                  iconColor: const Color(0xFF4A87C9),
                ),
                _buildMenuItem(
                  icon: Icons.event_note_outlined,
                  label: 'Agenda',
                  bgColor: const Color(0xFFFBF0D2),
                  iconColor: const Color(0xFFC9A23B),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Tombol Absen masuk
            SizedBox(
              height: 52,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canCheckIn
                    ? () => _handleAbsen(
                          isCheckIn: true,
                          start: shift.checkInStart,
                          end: shift.checkInEnd,
                        )
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryTeal,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: disabledBg,
                  disabledForegroundColor: disabledFg,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Absen masuk',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            if (!canCheckIn && shift?.checkInStart != null)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Text(
                  hasCheckedIn
                      ? 'Anda sudah absen masuk hari ini'
                      : 'Absen masuk hanya bisa jam ${shift!.checkInStart} - ${shift.checkInEnd}',
                  style: const TextStyle(fontSize: 11, color: Colors.black38),
                ),
              ),
            const SizedBox(height: 12),

            // Tombol Absen pulang
            SizedBox(
              height: 52,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canCheckOut
                    ? () => _handleAbsen(
                          isCheckIn: false,
                          start: shift.checkOutStart,
                          end: shift.checkOutEnd,
                        )
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: absenPulangColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: disabledBg,
                  disabledForegroundColor: disabledFg,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Absen pulang',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            if (!canCheckOut && shift?.checkOutStart != null)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Text(
                  hasCheckedOut
                      ? 'Anda sudah absen pulang hari ini'
                      : !hasCheckedIn
                          ? 'Anda belum absen masuk hari ini'
                          : 'Absen pulang hanya bisa jam ${shift!.checkOutStart} - ${shift.checkOutEnd}',
                  style: const TextStyle(fontSize: 11, color: Colors.black38),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationButton() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.notifications_none, color: primaryTeal, size: 22),
          Positioned(
            top: 10,
            right: 11,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
              child: SizedBox(width: 8, height: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJadwalCard(String shiftText) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: primaryTeal,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Jadwal Hari ini',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Text(
                shiftText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Icon(Icons.calendar_today_outlined,
              color: Colors.white, size: 22),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ??
          () {
            // TODO: arahkan ke halaman terkait (Izin & Cuti / Lembur / Agenda)
          },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
