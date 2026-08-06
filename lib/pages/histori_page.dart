import 'package:absenpro/pages/histori_tabs/histori_absen_tab.dart';
import 'package:absenpro/pages/histori_tabs/histori_cuti_tab.dart';
import 'package:absenpro/pages/histori_tabs/histori_izin_tab.dart';
import 'package:absenpro/pages/histori_tabs/histori_models.dart';
import 'package:absenpro/providers/attendance/attendance_history_provider.dart';
import 'package:absenpro/providers/periode/periode_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  final List<HistoriItem> _dataCuti = const [
    HistoriItem(
      title: 'Cuti Tahunan',
      status: HistoriStatus.menunggu,
      tanggal: '2 Januari 2026 - 3 Januari 2026',
    ),
    HistoriItem(
      title: 'Cuti Tahunan',
      status: HistoriStatus.disetujui,
      tanggal: '2 Januari 2026 - 3 Januari 2026',
    ),
    HistoriItem(
      title: 'Cuti Tahunan',
      status: HistoriStatus.ditolak,
      tanggal: '2 Januari 2026 - 3 Januari 2026',
    ),
  ];

  final List<HistoriItem> _dataIzin = const [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Muat periode dulu (untuk dapat default periode berjalan), baru
    // muat histori absen sesuai periode default tersebut.
    // Ditunda ke frame berikutnya supaya provider tidak memicu rebuild
    // saat widget masih berada dalam fase build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<PeriodeProvider>().fetchPeriode().then((_) {
        if (!mounted) return;
        final periode = context.read<PeriodeProvider>().selectedPeriode;
        context
            .read<AttendanceHistoryProvider>()
            .fetchInitial(periode: periode?.periodeValue);
      });
    });
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
                  HistoriCutiTab(items: _dataCuti),
                  HistoriIzinTab(items: _dataIzin),
                  const HistoriAbsenTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
