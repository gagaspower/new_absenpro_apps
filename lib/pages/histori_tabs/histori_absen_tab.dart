import 'package:absenpro/models/attendance_history/attendance_history_model.dart';
import 'package:absenpro/models/periode/periode_model.dart';
import 'package:absenpro/providers/attendance/attendance_history_provider.dart';
import 'package:absenpro/providers/periode/periode_provider.dart';
import 'package:absenpro/widgets/empty_state_widget.dart';
import 'package:absenpro/widgets/periode_filter_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HistoriAbsenTab extends StatefulWidget {
  const HistoriAbsenTab({super.key});

  @override
  State<HistoriAbsenTab> createState() => _HistoriAbsenTabState();
}

class _HistoriAbsenTabState extends State<HistoriAbsenTab> {
  final ScrollController _absenScrollController = ScrollController();

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

  void _onPeriodeChanged(PeriodeModel periode) {
    context.read<AttendanceHistoryProvider>().fetchInitial(
          periode: periode.periodeValue,
        );
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
        PeriodeFilterWidget(
          onPeriodeSelected: _onPeriodeChanged,
          onRefreshTap: _onPeriodeChanged,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Consumer<AttendanceHistoryProvider>(
            builder: (context, historyProvider, _) {
              if (historyProvider.isLoading && historyProvider.items.isEmpty) {
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: 4,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, __) => const _AbsenSkeletonCard(),
                );
              }

              if (historyProvider.errorMessage != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      historyProvider.errorMessage!,
                      textAlign: TextAlign.center,
                      style:
                          const TextStyle(color: Colors.black45, fontSize: 13),
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
                itemCount: historyProvider.items.length +
                    (historyProvider.hasMore ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index >= historyProvider.items.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: _AbsenSkeletonCard(),
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
}

class _AbsenSkeletonCard extends StatelessWidget {
  const _AbsenSkeletonCard();

  @override
  Widget build(BuildContext context) {
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
            children: [
              Expanded(
                child: _SkeletonBox(
                  height: 13,
                  width: 120,
                  borderRadius: 6,
                ),
              ),
              const SizedBox(width: 12),
              _SkeletonBox(
                height: 24,
                width: 72,
                borderRadius: 8,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _SkeletonBox(
                height: 44,
                width: 44,
                borderRadius: 12,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SkeletonBox(height: 13, width: 90, borderRadius: 6),
                    const SizedBox(height: 8),
                    _SkeletonBox(height: 12, width: 60, borderRadius: 6),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _SkeletonBox(height: 13, width: 90, borderRadius: 6),
                    const SizedBox(height: 8),
                    _SkeletonBox(height: 12, width: 60, borderRadius: 6),
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

class _SkeletonBox extends StatelessWidget {
  final double height;
  final double width;
  final double borderRadius;

  const _SkeletonBox({
    required this.height,
    required this.width,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return _SkeletonShimmer(
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class _SkeletonShimmer extends StatefulWidget {
  final Widget child;

  const _SkeletonShimmer({required this.child});

  @override
  State<_SkeletonShimmer> createState() => _SkeletonShimmerState();
}

class _SkeletonShimmerState extends State<_SkeletonShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1.0 + (_controller.value * 2.0), 0),
              end: Alignment(0.0 + (_controller.value * 2.0), 0),
              colors: [
                Colors.transparent,
                Colors.white.withOpacity(0.55),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
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
    final offDayInfo = _absenOffDayInfo(attendance);
    final bool isMuted = attendance.isMuted;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isMuted ? const Color(0xFFF6F6F8) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border:
            isMuted ? Border.all(color: Colors.black.withOpacity(0.06)) : null,
        boxShadow: isMuted
            ? const []
            : [
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
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isMuted ? Colors.black45 : Colors.black87,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusInfo.color.withOpacity(isMuted ? 0.08 : 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusInfo.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isMuted
                        ? statusInfo.color.withOpacity(0.7)
                        : statusInfo.color,
                  ),
                ),
              ),
            ],
          ),
          if (offDayInfo != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: offDayInfo.color.withOpacity(0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(offDayInfo.icon, size: 14, color: offDayInfo.color),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      offDayInfo.label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: offDayInfo.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          Opacity(
            opacity: isMuted ? 0.55 : 1,
            child: Row(
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
                        attendance.hasCheckedOut
                            ? attendance.checkOutTime!
                            : '-',
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
                              : (isMuted ? Colors.black38 : Colors.red[300]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OffDayInfo {
  final String label;
  final Color color;
  final IconData icon;

  const _OffDayInfo(this.label, this.color, this.icon);
}

/// Nentuin info "kenapa hari ini pudar/tidak aktif": prioritas cuti/izin
/// (paling spesifik & actionable) > hari libur > bukan hari kerja lain
/// (mis. weekend tanpa data holiday). Return null kalau hari kerja normal.
_OffDayInfo? _absenOffDayInfo(AttendanceHistoryModel attendance) {
  final leave = attendance.leave;
  if (leave != null) {
    final isCuti = leave.isCuti;
    final isIzin = leave.isIzin;
    final categoryLabel = isCuti ? 'Cuti' : (isIzin ? 'Izin' : 'Cuti/Izin');
    final typeName = leave.leaveType?.name;
    final label = (typeName != null && typeName.isNotEmpty)
        ? '$categoryLabel • $typeName'
        : categoryLabel;
    final color = isCuti ? const Color(0xFF8E6FCE) : const Color(0xFF4A87C9);
    return _OffDayInfo(label, color, Icons.event_busy_rounded);
  }

  if (attendance.isHoliday) {
    final holidayName = attendance.holiday?.name;
    final label = (holidayName != null && holidayName.isNotEmpty)
        ? holidayName
        : 'Hari Libur';
    return _OffDayInfo(
        label, const Color(0xFFE0A039), Icons.celebration_outlined);
  }

  if (!attendance.isWorkingDay) {
    final label = attendance.isWeekend ? 'Akhir Pekan' : 'Bukan Hari Kerja';
    return _OffDayInfo(label, Colors.black45, Icons.event_outlined);
  }

  return null;
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
