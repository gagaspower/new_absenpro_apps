import 'package:absenpro/models/attendance_history/attendance_history_model.dart';
import 'package:absenpro/providers/attendance/attendance_history_provider.dart';
import 'package:absenpro/providers/periode/periode_provider.dart';
import 'package:absenpro/widgets/empty_state_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HistoriAbsenTab extends StatefulWidget {
  const HistoriAbsenTab({super.key});

  @override
  State<HistoriAbsenTab> createState() => _HistoriAbsenTabState();
}

class _HistoriAbsenTabState extends State<HistoriAbsenTab> {
  final ScrollController _absenScrollController = ScrollController();

  static const Color primaryTeal = Color(0xFF2FC7CF);

  @override
  void initState() {
    super.initState();
    _absenScrollController.addListener(_onAbsenScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialHistory();
    });
  }

  void _loadInitialHistory() {
    final periodeProvider = context.read<PeriodeProvider>();
    final historyProvider = context.read<AttendanceHistoryProvider>();

    if (periodeProvider.selectedPeriode != null) {
      historyProvider.fetchInitial(
        periode: periodeProvider.selectedPeriode!.periodeValue,
      );
      return;
    }

    if (periodeProvider.periodeList.isNotEmpty) {
      historyProvider.fetchInitial(
        periode: periodeProvider.periodeList.first.periodeValue,
      );
      return;
    }

    periodeProvider.fetchPeriode().then((_) {
      if (!mounted) return;
      final selected = context.read<PeriodeProvider>().selectedPeriode;
      if (selected != null) {
        context.read<AttendanceHistoryProvider>().fetchInitial(
          periode: selected.periodeValue,
        );
      }
    });
  }

  void _onAbsenScroll() {
    if (!_absenScrollController.hasClients) return;
    final position = _absenScrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      context.read<AttendanceHistoryProvider>().loadMore();
    }
  }

  @override
  void dispose() {
    _absenScrollController.removeListener(_onAbsenScroll);
    _absenScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPeriodeFilter(),
        const SizedBox(height: 12),
        Expanded(
          child: Consumer<AttendanceHistoryProvider>(
            builder: (context, historyProvider, _) {
              if (historyProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (historyProvider.errorMessage != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      historyProvider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black45, fontSize: 13),
                    ),
                  ),
                );
              }

              if (historyProvider.items.isEmpty) {
                return const EmptyStateWidget(
                  assetPath: 'assets/images/oversight.svg',
                  title: 'Tidak ada data',
                );
              }

              return ListView.separated(
                controller: _absenScrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: historyProvider.items.length + (historyProvider.hasMore ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index >= historyProvider.items.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      ),
                    );
                  }

                  return _AbsenCard(attendance: historyProvider.items[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodeFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Consumer<PeriodeProvider>(
        builder: (context, periodeProvider, _) {
          final selected = periodeProvider.selectedPeriode;

          return Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    _showPeriodeBottomSheet(context, periodeProvider);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            periodeProvider.isLoading
                                ? 'Memuat periode...'
                                : (selected?.periodeLabel ?? 'Pilih Periode'),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down,
                            size: 20, color: Colors.black45),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  final activePeriode = periodeProvider.selectedPeriode;
                  if (activePeriode != null) {
                    context.read<AttendanceHistoryProvider>().fetchInitial(
                      periode: activePeriode.periodeValue,
                    );
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: primaryTeal,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showPeriodeBottomSheet(
    BuildContext context,
    PeriodeProvider periodeProvider,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Pilih Periode',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: periodeProvider.periodeList.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    thickness: 1,
                    indent: 20,
                    endIndent: 20,
                    color: Color(0xFFF0F0F0),
                  ),
                  itemBuilder: (context, index) {
                    final periode = periodeProvider.periodeList[index];
                    final isSelected = periode.periodeValue ==
                        periodeProvider.selectedPeriode?.periodeValue;

                    return ListTile(
                      title: Text(
                        periode.periodeLabel,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? primaryTeal : Colors.black87,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle,
                              color: primaryTeal, size: 20)
                          : null,
                      onTap: () {
                        periodeProvider.selectPeriode(periode);
                        Navigator.pop(sheetContext);
                        context
                            .read<AttendanceHistoryProvider>()
                            .fetchInitial(periode: periode.periodeValue);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}

class _AbsenCard extends StatelessWidget {
  final AttendanceHistoryModel attendance;

  const _AbsenCard({required this.attendance});

  @override
  Widget build(BuildContext context) {
    final statusInfo = _absenStatusInfo(attendance.status);

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  attendance.attendanceDate,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusInfo.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusInfo.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusInfo.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCF2E3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.face_outlined,
                  color: Color(0xFF4CAF7D),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      attendance.hasCheckedIn ? attendance.checkInTime! : '-',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Masuk',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const Text(
                '|',
                style: TextStyle(fontSize: 16, color: Colors.black26),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      attendance.hasCheckedOut ? attendance.checkOutTime! : '-',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Pulang',
                      style: TextStyle(
                        fontSize: 12,
                        color: attendance.hasCheckedOut
                            ? Colors.black54
                            : Colors.red[300],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AbsenStatusInfo {
  final String label;
  final Color color;

  const _AbsenStatusInfo(this.label, this.color);
}

_AbsenStatusInfo _absenStatusInfo(String? status) {
  switch (status) {
    case 'present':
      return const _AbsenStatusInfo('Hadir', Color(0xFF4CAF7D));
    case 'late':
      return const _AbsenStatusInfo('Terlambat', Color(0xFFC9A23B));
    case 'permission':
      return const _AbsenStatusInfo('Izin', Color(0xFF4A87C9));
    case 'leave':
      return const _AbsenStatusInfo('Cuti', Color(0xFF8E6FCE));
    case 'sick':
      return const _AbsenStatusInfo('Sakit', Color(0xFFE0637A));
    case 'absent':
      return const _AbsenStatusInfo('Tidak Hadir', Color(0xFFB0413E));
    default:
      return const _AbsenStatusInfo('-', Colors.black45);
  }
}
