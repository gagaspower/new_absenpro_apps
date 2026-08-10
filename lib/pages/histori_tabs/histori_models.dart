import 'package:flutter/material.dart';

enum HistoriStatus { draft, menunggu, disetujui, ditolak, dibatalkan }

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
    case 'draft':
      return HistoriStatus.draft;
    case 'pending':
      return HistoriStatus.menunggu;
    case 'approved':
      return HistoriStatus.disetujui;
    case 'rejected':
      return HistoriStatus.ditolak;
    case 'cancelled':
      return HistoriStatus.dibatalkan;
    default:
      return HistoriStatus.menunggu;
  }
}

HistoriStatusStyle historiStatusStyle(String raw) {
  final status = _mapHistoriStatus(raw);
  switch (status) {
    case HistoriStatus.draft:
      return const HistoriStatusStyle(
        label: 'Draft',
        labelColor: Color(0xFF616161),
        bgColor: Color(0xFFEEEEEE),
        iconColor: Color(0xFF616161),
        icon: Icons.edit_note,
      );
    case HistoriStatus.menunggu:
      return const HistoriStatusStyle(
        label: 'Menunggu persetujuan',
        labelColor: Color(0xFFEF6C00),
        bgColor: Color(0xFFFFF3E0),
        iconColor: Color(0xFFEF6C00),
        icon: Icons.hourglass_empty,
      );
    case HistoriStatus.disetujui:
      return const HistoriStatusStyle(
        label: 'Disetujui',
        labelColor: Color(0xFF2E7D32),
        bgColor: Color(0xFFE8F5E9),
        iconColor: Color(0xFF2E7D32),
        icon: Icons.check_circle,
      );
    case HistoriStatus.ditolak:
      return const HistoriStatusStyle(
        label: 'Ditolak',
        labelColor: Color(0xFFC62828),
        bgColor: Color(0xFFFFEBEE),
        iconColor: Color(0xFFC62828),
        icon: Icons.cancel,
      );
    case HistoriStatus.dibatalkan:
      return const HistoriStatusStyle(
        label: 'Dibatalkan',
        labelColor: Color(0xFF616161),
        bgColor: Color(0xFFF5F5F5),
        iconColor: Color(0xFF616161),
        icon: Icons.block,
      );
  }
}
