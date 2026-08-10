import 'package:absenpro/models/periode/periode_model.dart';
import 'package:absenpro/widgets/empty_state_widget.dart';
import 'package:absenpro/widgets/periode_filter_widget.dart';
import 'package:flutter/material.dart';
import 'histori_models.dart';

class HistoriIzinTab extends StatelessWidget {
  final List<HistoriItem> items;

  /// Dipanggil saat periode berubah (lewat pilih periode atau refresh).
  /// Wire ini ke provider/service histori izin untuk fetch ulang data.
  final ValueChanged<PeriodeModel>? onPeriodeChanged;

  const HistoriIzinTab({
    super.key,
    required this.items,
    this.onPeriodeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PeriodeFilterWidget(
          onPeriodeSelected: (p) => onPeriodeChanged?.call(p),
          onRefreshTap: (p) => onPeriodeChanged?.call(p),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: items.isEmpty
              ? const EmptyStateWidget(
                  assetPath: 'assets/images/oversight.svg',
                  title: 'Belum ada histori izin',
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      _HistoriCard(item: items[index]),
                ),
        ),
      ],
    );
  }
}

// _HistoriCard TETAP SAMA seperti sebelumnya, tidak ada perubahan.

class _HistoriCard extends StatelessWidget {
  final HistoriItem item;

  const _HistoriCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final style = historiStatusStyle('');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: style.bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(style.icon, color: style.iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  style.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: style.labelColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.tanggal,
                  style: const TextStyle(fontSize: 12, color: Colors.black38),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
