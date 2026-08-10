import 'package:absenpro/pages/auth/login_page.dart';
import 'package:absenpro/pages/dashboard_page.dart';
import 'package:absenpro/pages/splash_page.dart';
import 'package:absenpro/providers/auth/auth_provider.dart';
import 'package:absenpro/providers/periode/periode_provider.dart';
import 'package:absenpro/providers/attendance/attendance_history_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:absenpro/providers/leave_type/leave_type_provider.dart';
import 'package:absenpro/providers/leave_request/leave_request_provider.dart';
import 'package:absenpro/providers/leave_request/leave_request_history_provider.dart';

void main() {
  // Atur warna status bar (sinyal, baterai, jam) secara global
  // supaya berlaku di semua halaman tanpa perlu AppBar.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF2FC7CF), // sama dengan warna tombol login
      statusBarIconBrightness: Brightness.light, // ikon jadi putih (Android)
      statusBarBrightness: Brightness.dark, // ikon jadi putih (iOS)
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PeriodeProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceHistoryProvider()),
        ChangeNotifierProvider(create: (_) => LeaveTypeProvider()),
        ChangeNotifierProvider(create: (_) => LeaveRequestProvider()),
        ChangeNotifierProvider(create: (_) => LeaveRequestHistoryProvider()),
      ],
      child: MaterialApp(
        title: 'Absen Pro',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily:
              'Questrial', // hapus baris ini kalau font belum ditambahkan
          scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        ),
        home: const SplashPage(),
        routes: {
          '/login': (_) => const LoginPage(),
          '/dashboard': (_) => const DashboardPage(),
        },
      ),
    );
  }
}
