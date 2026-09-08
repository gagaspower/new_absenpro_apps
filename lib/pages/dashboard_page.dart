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
  static const Color softBackground = Color(0xFFF4F5F7);

  int _currentIndex = 0;
  bool _isSubmittingAttendance = false;

  final List<Widget> _pages = const [HomePage(), HistoriPage(), ProfilPage()];

  Future<void> _handleCenterAttendance() async {
    if (_isSubmittingAttendance) return;

    final employee = context.read<AuthProvider>().user?.employee;
    final workSchedule = employee?.workSchedule;
    final attendance = employee?.attendanceToday;

    if (workSchedule == null) {
      _showMessage('Jadwal kerja hari ini belum tersedia.');
      return;
    }

    final hasCheckedIn = attendance?.hasCheckedIn ?? false;
    final hasCheckedOut = attendance?.hasCheckedOut ?? false;

    final withinCheckInWindow = TimeHelper.isWithinRange(
      workSchedule.checkInStart,
      workSchedule.checkInEnd,
    );
    final withinCheckOutWindow = TimeHelper.isWithinRange(
      workSchedule.checkOutStart,
      workSchedule.checkOutEnd,
    );

    late final bool isCheckIn;

    if (hasCheckedOut) {
      _showMessage('Absensi masuk dan pulang hari ini sudah selesai.');
      return;
    }

    if (!hasCheckedIn) {
      if (!withinCheckInWindow) {
        _showMessage(
          'Absen masuk hanya bisa jam ${workSchedule.checkInStart ?? '-'} - ${workSchedule.checkInEnd ?? '-'}.',
        );
        return;
      }
      isCheckIn = true;
    } else {
      if (!withinCheckOutWindow) {
        _showMessage(
          'Absen pulang hanya bisa jam ${workSchedule.checkOutStart ?? '-'} - ${workSchedule.checkOutEnd ?? '-'}.',
        );
        return;
      }
      isCheckIn = false;
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
      if (mounted) setState(() => _isSubmittingAttendance = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _selectPage(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: softBackground,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: softBackground,
        extendBody: true,
        body: IndexedStack(index: _currentIndex, children: _pages),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Material(
      type: MaterialType.transparency,
      child: Padding(
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
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 20,
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
