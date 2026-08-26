import 'package:absenpro/models/periode/periode_model.dart';
import 'package:absenpro/providers/periode/periode_provider.dart';
import 'package:absenpro/providers/leave_request/leave_request_history_provider.dart';
import 'package:absenpro/widgets/empty_state_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'histori_models.dart';

const Color _kPrimaryColor = Color(0xFF2FC7CF);

/// Opsi status filter histori. `value == null` -> "Semua" (default).
const Map<String?, String> _kStatusOptions = {
  null: 'Semua',
  'draft': 'Draft',
  'pending': 'Menunggu Persetujuan',
  'approved': 'Disetujui',
  'rejected': 'Ditolak',
  'cancelled': 'Dibatalkan',
};

class HistoriCutiTab extends StatefulWidget {
  const HistoriCutiTab({super.key});

  @override
  State<HistoriCutiTab> createState() => _HistoriCutiTabState();
}

class _HistoriCutiTabState extends State<HistoriCutiTab> {
  final ScrollController _scrollController = ScrollController();
  String? _activePeriode;
  String? _activeStatus; // null = Semua

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchInitial());
  }

  PeriodeModel? _findCurrentPeriode(List<PeriodeModel> periodeList) {
    if (periodeList.isEmpty) return null;
    final now = DateTime.now();
    final target = '${now.month} - ${now.year}';

    for (final p in periodeList) {
      if (p.periodeValue == target) return p;
    }
    return periodeList.first;
  }

  void _fetchInitial({PeriodeModel? periode, String? status}) {
    _activePeriode = periode?.periodeValue ?? _activePeriode;

    // `null` adalah nilai valid untuk status "Semua".
    // Jangan gunakan `status ?? _activeStatus`, karena itu membuat
    // Reset/Terapkan "Semua" tetap mempertahankan status sebelumnya.
    _activeStatus = status;

    context.read<LeaveRequestHistoryProvider>().fetchInitial(
          periode: _activePeriode,
          status: _activeStatus,
          leaveTypeCategory: 'cuti',
        );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<LeaveRequestHistoryProvider>().loadMore();
    }
  }

  void _openFilterBottomSheet() {
    final periodeProvider = context.read<PeriodeProvider>();
    final currentPeriode = periodeProvider.selectedPeriode;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        PeriodeModel? tempPeriode = currentPeriode;
        for (final p in periodeProvider.periodeList) {
          if (p.periodeValue == _activePeriode) {
            tempPeriode = p;
            break;
          }
        }
        String? tempStatus = _activeStatus;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Filter Histori',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Periode',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: periodeProvider.periodeList.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final periode = periodeProvider.periodeList[index];
                          final isSelected =
                              periode.periodeValue == tempPeriode?.periodeValue;
                          return _FilterChip(
                            label: periode.periodeLabel,
                            isSelected: isSelected,
                            onTap: () => setSheetState(() {
                              tempPeriode = periode;
                            }),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _kStatusOptions.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final entry =
                              _kStatusOptions.entries.elementAt(index);
                          final isSelected = entry.key == tempStatus;
                          return _FilterChip(
                            label: entry.value,
                            isSelected: isSelected,
                            onTap: () => setSheetState(() {
                              tempStatus = entry.key;
                            }),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                final resetPeriode = _findCurrentPeriode(
                                  periodeProvider.periodeList,
                                );

                                if (resetPeriode != null) {
                                  periodeProvider.selectPeriode(resetPeriode);
                                }

                                Navigator.pop(sheetContext);
                                _fetchInitial(
                                  periode: resetPeriode,
                                  status: null,
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF6C757D),
                                side: const BorderSide(
                                  color: Color(0xFF6C757D),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Reset',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (tempPeriode != null) {
                                  periodeProvider.selectPeriode(tempPeriode!);
                                }
                                Navigator.pop(sheetContext);
                                _fetchInitial(
                                  periode: tempPeriode,
                                  status: tempStatus,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _kPrimaryColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Terapkan',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: _openFilterBottomSheet,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
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
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Filter',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.tune, color: Colors.black54, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  final activePeriode =
                      context.read<PeriodeProvider>().selectedPeriode;
                  if (activePeriode != null) {
                    _fetchInitial(
                      periode: activePeriode,
                      status: _activeStatus,
                    );
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _kPrimaryColor,
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
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Consumer<LeaveRequestHistoryProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return _SkeletonList();
              }

              if (provider.items.isEmpty) {
                return const EmptyStateWidget(
                  assetPath: 'assets/images/oversight.svg',
                  title: 'Belum ada histori cuti',
                );
              }

              return ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount:
                    provider.items.length + (provider.isLoadingMore ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index >= provider.items.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  }
                  return _HistoriCard(item: provider.items[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD4EDDA) : Colors.white,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color:
                isSelected ? const Color(0xFFC3E6CB) : const Color(0xFFD6D8DB),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color:
                isSelected ? const Color(0xFF155724) : const Color(0xFF6C757D),
          ),
        ),
      ),
    );
  }
}

class _SkeletonList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => const _SkeletonCard(),
    );
  }
}

class _SkeletonCard extends StatefulWidget {
  const _SkeletonCard();

  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..repeat(reverse: true);
  late final Animation<double> _opacity =
      Tween<double>(begin: 0.4, end: 1.0).animate(_controller);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _bar({double width = double.infinity, double height = 12}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bar(width: 140, height: 14),
                  const SizedBox(height: 8),
                  _bar(width: 80, height: 10),
                  const SizedBox(height: 6),
                  _bar(width: 100, height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoriCard extends StatelessWidget {
  final dynamic item;

  const _HistoriCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final style = historiStatusStyle(item.status);
    final title = item.leaveType?.name ?? '-';
    final tanggal = item.startDate == item.endDate
        ? item.startDate
        : '${item.startDate} - ${item.endDate}';

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
                        title,
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
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
                  tanggal,
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
