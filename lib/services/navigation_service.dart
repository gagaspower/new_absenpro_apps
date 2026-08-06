import 'package:flutter/material.dart';

/// Dipakai supaya kode non-widget (misal interceptor Dio di ApiService)
/// tetap bisa melakukan navigasi tanpa butuh BuildContext dari widget.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
