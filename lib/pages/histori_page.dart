import 'package:absenpro/models/attendance_history/attendance_history_model.dart';
import 'package:flutter/material.dart';

class HistoriPage extends StatefulWidget {
  const HistoriPage({super.key});

  @override
  State<HistoriPage> createState() => _HistoriPageState();
}

class _HistoriPageState extends State<HistoriPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

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
  }

  @override
  void dispose() {
    _tabController.dispose();
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
    if (_dataAbsen.isEmpty) {
      return Center(
        child: const Text(
          'Belum ada histori absensi',
          style: TextStyle(color: Colors.black38, fontSize: 13),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _dataAbsen.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _AbsenCard(
        attendance: _dataAbsen[index],
      ),
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
class _AbsenCard extends StatelessWidget {
  final AttendanceHistoryModel attendance;

  const _AbsenCard({required this.attendance});

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
          Text(
            attendance.attendanceDate,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Ikon wajah (absensi dengan wajah)
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
              // Jam masuk
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      attendance.checkInTime ?? '-',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Masuk',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              // Pemisah garis
              const Text(
                '|',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black26,
                ),
              ),
              // Jam pulang
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      attendance.checkOutTime ?? '-',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      attendance.checkOutTime != null ? 'Pulang' : 'Pulang',
                      style: TextStyle(
                        fontSize: 12,
                        color: attendance.checkOutTime != null
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
