import 'package:absenpro/helpers/time_helper.dart';
import 'package:absenpro/models/attendance/attendance_model.dart';
import 'package:absenpro/pages/attendance/attendance_page.dart';
import 'package:absenpro/pages/histori_page.dart';
import 'package:absenpro/pages/home_page.dart';
import 'package:absenpro/pages/profil_page.dart';
import 'package:absenpro/providers/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const Color primaryTeal = Color(0xFF30CBD7);
  // Soft neutral background instead of pure white — gives the whole
  // dashboard a slightly warmer, less clinical feel.
  static const Color softBackground = Color(0xFFF4F5F7);

  int _currentIndex = 0;
  bool _isSubmittingAttendance = false;

  final List<Widget> _pages = const [
    HomePage(),
    HistoriPage(),
    ProfilPage(),
  ];

  Future<void> _handleCenterAttendance() async {
    if (_isSubmittingAttendance) return;

    final employee = context.read<AuthProvider>().user?.employee;
    final shift = employee?.shift;
    final attendance = employee?.attendanceToday;

    if (shift == null) {
      _showMessage('Jadwal shift belum tersedia.');
      return;
    }

    final hasCheckedIn = attendance?.hasCheckedIn ?? false;
    final hasCheckedOut = attendance?.hasCheckedOut ?? false;

    final withinCheckOutWindow =
        TimeHelper.isWithinRange(shift.checkOutStart, shift.checkOutEnd);
    final withinCheckInWindow =
        TimeHelper.isWithinRange(shift.checkInStart, shift.checkInEnd);

    late final bool isCheckIn;

    if (withinCheckOutWindow && hasCheckedIn && !hasCheckedOut) {
      isCheckIn = false;
    } else if (withinCheckInWindow && !hasCheckedIn) {
      isCheckIn = true;
    } else {
      if (hasCheckedOut) {
        _showMessage('Absensi masuk dan pulang hari ini sudah selesai.');
      } else if (hasCheckedIn && !withinCheckOutWindow) {
        _showMessage(
          'Absen pulang hanya bisa jam ${shift.checkOutStart} - ${shift.checkOutEnd}.',
        );
      } else if (!hasCheckedIn && !withinCheckInWindow) {
        _showMessage(
          'Absen masuk hanya bisa jam ${shift.checkInStart} - ${shift.checkInEnd}.',
        );
      } else {
        _showMessage('Absensi belum tersedia pada waktu ini.');
      }
      return;
    }

    setState(() => _isSubmittingAttendance = true);

    try {
      final attendanceResult = await Navigator.push<AttendanceModel?>(
        context,
        MaterialPageRoute(
          builder: (_) => AbsenSelfiePage(isCheckIn: isCheckIn),
        ),
      );

      if (attendanceResult != null && mounted) {
        await context
            .read<AuthProvider>()
            .updateAttendanceFromServer(attendanceResult);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmittingAttendance = false);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _selectPage(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    // Without this, the OS system navigation bar keeps its own default
    // color (usually white/black) instead of blending with softBackground,
    // which shows up as a mismatched strip right behind the floating nav.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: softBackground,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: softBackground,
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    // Floating pill — only as wide as it needs to be for 3 items, with
    // margin on every side so the soft background peeks through around it.
    return Padding(
      padding: const EdgeInsets.only(left: 64, right: 64, bottom: 20),
      child: SizedBox(
        height: 60,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  // Fully rounded on every corner — a pill, not a slab.
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 20,
                      spreadRadius: 0,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      icon: Icons.home_outlined,
                      label: 'Home',
                      selected: _currentIndex == 0,
                      onTap: () => _selectPage(0),
                    ),
                    // Narrower gap than before — the whole bar is tighter now.
                    const SizedBox(width: 56),
                    _buildNavItem(
                      icon: Icons.person_outline,
                      label: 'Profil',
                      selected: _currentIndex == 2,
                      onTap: () => _selectPage(2),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: -22,
              left: 0,
              right: 0,
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _handleCenterAttendance,
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: primaryTeal,
                        shape: BoxShape.circle,
                        // Small white ring so the raised button reads as
                        // floating above the pill rather than merging into it.
                        border: Border.all(color: softBackground, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: primaryTeal.withOpacity(0.28),
                            blurRadius: 12,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _isSubmittingAttendance
                          ? const Padding(
                              padding: EdgeInsets.all(14),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.center_focus_strong,
                              color: Colors.white,
                              size: 25,
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final color = selected ? primaryTeal : Colors.black54;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 72,
        height: 59,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(icon, size: 23, color: color),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: color,
              ),
            ),
            const SizedBox(height: 7),
          ],
        ),
      ),
    );
  }
}
