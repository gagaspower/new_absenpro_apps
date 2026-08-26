import 'package:absenpro/helpers/time_helper.dart';
import 'package:absenpro/models/attendance/attendance_model.dart';
import 'package:absenpro/pages/attendance/attendance_page.dart';
import 'package:absenpro/pages/histori_page.dart';
import 'package:absenpro/pages/home_page.dart';
import 'package:absenpro/pages/profil_page.dart';
import 'package:absenpro/providers/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const Color primaryTeal = Color(0xFF30CBD7);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  void _selectPage(int index) {
    setState(() => _currentIndex = index);
  }

  Widget _buildBottomNavigationBar() {
    return SizedBox(
      height: 85,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x40000000),
                    blurRadius: 5,
                    spreadRadius: 1,
                    offset: Offset(0, -1),
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
                  const SizedBox(width: 82),
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
            top: -26,
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
                      boxShadow: [
                        BoxShadow(
                          color: primaryTeal.withOpacity(0.22),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
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
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final color = selected ? primaryTeal : Colors.black87;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 72,
        height: 68,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
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
