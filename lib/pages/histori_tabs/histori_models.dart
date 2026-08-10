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

HistoriStatus _mapHistoriStatus(String raw) {
  switch (raw.toLowerCase()) {
    case 'pending':
    case 'draft':
      return HistoriStatus.menunggu;
    case 'approved':
      return HistoriStatus.disetujui;
    case 'rejected':
      return HistoriStatus.ditolak;
    default:
      return HistoriStatus.menunggu;
  }
}
