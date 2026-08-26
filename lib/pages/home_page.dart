import 'dart:async';

import 'package:absenpro/helpers/time_helper.dart';
import 'package:absenpro/pages/histori_page.dart';
import 'package:absenpro/pages/permohonan_cuti/form_cuti_page.dart';
import 'package:absenpro/providers/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  static const Color primaryTeal = Color(0xFF30CBD7);
  // Same soft neutral background as the dashboard shell, so Home doesn't
  // flash pure white while its own Scaffold paints.
  static const Color softBackground = Color(0xFFF4F5F7);

  late String _greeting;
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _greeting = TimeHelper.greeting();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final greeting = TimeHelper.greeting();
      if (greeting != _greeting) {
        setState(() => _greeting = greeting);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AuthProvider>().refreshTodayAttendance();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
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

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final employee = user?.employee;
    final shift = employee?.shift;

    final displayName = employee?.fullName ?? user?.name ?? '-';
    final shiftText = shift != null ? '${shift.name} | ${shift.jamKerja}' : '-';

    return Scaffold(
      backgroundColor: softBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(26, 32, 26, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _greeting,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.black54,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                  ),
                  _buildNotificationButton(),
                ],
              ),
              const SizedBox(height: 40),
              _buildJadwalCard(shiftText),
              const SizedBox(height: 50),
              _buildMenuGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationButton() {
    return Container(
      width: 47,
      height: 47,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(
            Icons.notifications_none_outlined,
            color: primaryTeal,
            size: 22,
          ),
          Positioned(
            top: 11,
            right: 10,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFFF9FB2),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJadwalCard(String shiftText) {
    return Container(
      width: double.infinity,
      height: 87,
      padding: const EdgeInsets.fromLTRB(18, 16, 20, 14),
      decoration: BoxDecoration(
        color: primaryTeal,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryTeal.withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Jadwal hari ini',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                shiftText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
          const Icon(
            Icons.calendar_month_outlined,
            color: Colors.white,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMenuItem(
          icon: Icons.send_outlined,
          label: 'Izin & Cuti',
          bgColor: const Color(0xFFF8D7DA),
          iconColor: const Color(0xFF7C1F2C),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FormCutiPage()),
            );
          },
        ),
        _buildMenuItem(
          icon: Icons.nightlight_outlined,
          label: 'Lembur',
          bgColor: const Color(0xFFCCE5FF),
          iconColor: const Color(0xFF07549B),
        ),
        _buildMenuItem(
          icon: Icons.calendar_month_outlined,
          label: 'Agenda',
          bgColor: const Color(0xFFFFF3CD),
          iconColor: const Color(0xFF8B6500),
        ),
        _buildMenuItem(
          icon: Icons.access_time_outlined,
          label: 'Kehadiran',
          bgColor: const Color(0xFFD4EDDA),
          iconColor: const Color(0xFF176B2E),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoriPage()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    // Boxes trimmed down slightly from 74x74 -> 66x66 (kept square and
    // evenly spaced by the parent Row) so the grid feels a bit lighter
    // without breaking proportions with the icon/label below it.
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 70,
        child: Column(
          children: [
            Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 14),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
