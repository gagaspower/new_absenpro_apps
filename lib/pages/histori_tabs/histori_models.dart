import 'package:flutter/material.dart';

enum HistoriStatus { menunggu, disetujui, ditolak }

class HistoriItem {
  final String title;
  final HistoriStatus status;
  final String tanggal;

  const HistoriItem({
    required this.title,
    required this.status,
    required this.tanggal,
  });
}

class HistoriStatusStyle {
  final String label;
  final Color labelColor;
  final Color bgColor;
  final Color iconColor;
  final IconData icon;

  const HistoriStatusStyle({
    required this.label,
    required this.labelColor,
    required this.bgColor,
    required this.iconColor,
    required this.icon,
  });
}

HistoriStatusStyle historiStatusStyle(HistoriStatus status) {
  switch (status) {
    case HistoriStatus.menunggu:
      return const HistoriStatusStyle(
        label: 'Menunggu persetujuan',
        labelColor: Color(0xFFC9A23B),
        bgColor: Color(0xFFFBF0D2),
        iconColor: Color(0xFFC9A23B),
        icon: Icons.access_time,
      );
    case HistoriStatus.disetujui:
      return const HistoriStatusStyle(
        label: 'Disetujui',
        labelColor: Color(0xFF4CAF7D),
        bgColor: Color(0xFFDCF2E3),
        iconColor: Color(0xFF4CAF7D),
        icon: Icons.check_circle_outline,
      );
    case HistoriStatus.ditolak:
      return const HistoriStatusStyle(
        label: 'Ditolak',
        labelColor: Color(0xFFE0637A),
        bgColor: Color(0xFFFBE0E4),
        iconColor: Color(0xFFE0637A),
        icon: Icons.info_outline,
      );
  }
}
