import 'package:absenpro/models/attendance_history/attendance_history_model.dart';
import 'package:absenpro/providers/periode/periode_provider.dart';
import 'package:absenpro/providers/attendance/attendance_history_provider.dart';
import 'package:absenpro/providers/periode/periode_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class HistoriPage extends StatefulWidget {
  const HistoriPage({super.key});

  @override
  State<HistoriPage> createState() => _HistoriPageState();
}

class _HistoriPageState extends State<HistoriPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final ScrollController _absenScrollController = ScrollController();

  static const Color primaryTeal = Color(0xFF2FC7CF);

  // TODO: ganti dengan data asli dari API Laravel
  final List<_HistoriItem> _dataCuti = const [
    _HistoriItem(
      title: 'Cuti Tahunan',
      status: HistoriStatus.menunggu,
      tanggal: '2 Januari 2026 - 3 Januari 2026',
    ),
    _HistoriItem(
      title: 'Cuti Tahunan',
      status: HistoriStatus.disetujui,
      tanggal: '2 Januari 2026 - 3 Januari 2026',
    ),
    _HistoriItem(
      title: 'Cuti Tahunan',
      status: HistoriStatus.ditolak,
      tanggal: '2 Januari 2026 - 3 Januari 2026',
    ),
  ];

  final List<_HistoriItem> _dataIzin = const [];

  // TODO: fetch dari API endpoint histori absensi (format bisa berubah sesuai
  // response backend). Sample data di bawah adalah placeholder.
  final List<AttendanceHistoryModel> _dataAbsen = const [
    // Contoh: hari ini sudah absen masuk (08:00) tapi belum pulang
    _SampleAttendance(
      id: 'att-001',
      date: '5 Agustus 2026',
      checkInTime: '08:00',
      checkOutTime: null,
    ),
    // Contoh: kemarin absen masuk (08:00) dan pulang (17:00)
    _SampleAttendance(
      id: 'att-002',
      date: '4 Agustus 2026',
      checkInTime: '08:00',
      checkOutTime: '17:00',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _absenScrollController.addListener(_onAbsenScroll);

    // Muat periode dulu (untuk dapat default periode berjalan), baru
    // muat histori absen sesuai periode default tersebut.
    context.read<PeriodeProvider>().fetchPeriode().then((_) {
      if (!mounted) return;
      final periode = context.read<PeriodeProvider>().selectedPeriode;
      context
          .read<AttendanceHistoryProvider>()
          .fetchInitial(periode: periode?.periodeValue);
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
    _tabController.dispose();
    _absenScrollController.removeListener(_onAbsenScroll);
    _absenScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histori Absensi'),
        automaticallyImplyLeading: false, // tidak ada tombol back
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Tab segmented (Cuti / Izin / Absen)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDEDED),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: primaryTeal,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: const EdgeInsets.all(4),
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black54,
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: const TextStyle(fontSize: 13),
                  tabs: const [
                    Tab(text: 'Cuti'),
                    Tab(text: 'Izin'),
                    Tab(text: 'Absen'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildList(_dataCuti, 'cuti'),
                  _buildList(_dataIzin, 'izin'),
                  _buildAbsenList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<_HistoriItem> items, String jenis) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          'Belum ada histori $jenis',
          style: const TextStyle(color: Colors.black38, fontSize: 13),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _HistoriCard(item: items[index]),
    );
  }

  Widget _buildAbsenList() {
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
                      style:
                          const TextStyle(color: Colors.black45, fontSize: 13),
                    ),
                  ),
                );
              }

              if (historyProvider.items.isEmpty) {
                return const Center(
                  child: Text(
                    'Tidak ada data',
                    style: TextStyle(color: Colors.black38, fontSize: 13),
                  ),
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
                    // Loader tambahan di bawah list saat sedang load more.
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

                  return _AbsenCard(
                    attendance: historyProvider.items[index],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  /// Tombol filter periode: putih tanpa border, suffix ikon panah bawah.
  /// Ketika ditekan, menampilkan bottom sheet berisi daftar periode.
  Widget _buildPeriodeFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Consumer<PeriodeProvider>(
        builder: (context, periodeProvider, _) {
          final selected = periodeProvider.selectedPeriode;

          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              periodeProvider.selectPeriode(periode);
              Navigator.pop(sheetContext);
              context
                  .read<AttendanceHistoryProvider>()
                  .fetchInitial(periode: periode.value);
            },
            child: Container(
              width: double.infinity,
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
                  Text(
                    periodeProvider.isLoading
                        ? 'Memuat periode...'
                        : (selected?.periodeLabel ?? 'Pilih Periode'),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down,
                      size: 20, color: Colors.black45),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Bottom sheet daftar periode, dipilih lewat tap item.
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
                        // TODO: refetch data absen berdasarkan periode yang baru dipilih
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

enum HistoriStatus { menunggu, disetujui, ditolak }

class _HistoriItem {
  final String title;
  final HistoriStatus status;
  final String tanggal;

  const _HistoriItem({
    required this.title,
    required this.status,
    required this.tanggal,
  });
}

class _HistoriCard extends StatelessWidget {
  final _HistoriItem item;

  const _HistoriCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final style = _statusStyle(item.status);

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // TODO: arahkan ke halaman detail histori
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'Detail',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black45,
                            ),
                          ),
                          SizedBox(width: 2),
                          Icon(Icons.arrow_forward,
                              size: 12, color: Colors.black45),
                        ],
                      ),
                    ),
                  ],
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

  _StatusStyle _statusStyle(HistoriStatus status) {
    switch (status) {
      case HistoriStatus.menunggu:
        return _StatusStyle(
          label: 'Menunggu persetujuan',
          labelColor: const Color(0xFFC9A23B),
          bgColor: const Color(0xFFFBF0D2),
          iconColor: const Color(0xFFC9A23B),
          icon: Icons.access_time,
        );
      case HistoriStatus.disetujui:
        return _StatusStyle(
          label: 'Disetujui',
          labelColor: const Color(0xFF4CAF7D),
          bgColor: const Color(0xFFDCF2E3),
          iconColor: const Color(0xFF4CAF7D),
          icon: Icons.check_circle_outline,
        );
      case HistoriStatus.ditolak:
        return _StatusStyle(
          label: 'Ditolak',
          labelColor: const Color(0xFFE0637A),
          bgColor: const Color(0xFFFBE0E4),
          iconColor: const Color(0xFFE0637A),
          icon: Icons.info_outline,
        );
    }
  }
}

class _StatusStyle {
  final String label;
  final Color labelColor;
  final Color bgColor;
  final Color iconColor;
  final IconData icon;

  _StatusStyle({
    required this.label,
    required this.labelColor,
    required this.bgColor,
    required this.iconColor,
    required this.icon,
  });
}

/// Widget card untuk tampilkan 1 hari absensi (jam masuk | jam pulang).
/// Widget card untuk tampilkan 1 hari absensi (tanggal + status,
/// lalu jam masuk | jam pulang).
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
          // Baris tanggal (kiri) + status (kanan) dalam 1 baris.
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

/// Placeholder implementation AttendanceHistoryModel untuk sample data.
class _SampleAttendance extends AttendanceHistoryModel {
  const _SampleAttendance({
    required String id,
    required String date,
    required String? checkInTime,
    required String? checkOutTime,
  }) : super(
          id: id,
          attendanceDate: date,
          checkInTime: checkInTime,
          checkOutTime: checkOutTime,
        );
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
