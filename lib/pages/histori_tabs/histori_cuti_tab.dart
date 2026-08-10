import 'package:absenpro/models/periode/periode_model.dart';
import 'package:absenpro/providers/leave_request/leave_request_history_provider.dart';
import 'package:absenpro/widgets/empty_state_widget.dart';
import 'package:absenpro/widgets/periode_filter_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'histori_models.dart';

class HistoriCutiTab extends StatefulWidget {
  const HistoriCutiTab({super.key});

  @override
  State<HistoriCutiTab> createState() => _HistoriCutiTabState();
}

class _HistoriCutiTabState extends State<HistoriCutiTab> {
  final ScrollController _scrollController = ScrollController();
  String? _activePeriode;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchInitial());
  }

  void _fetchInitial({PeriodeModel? periode}) {
    _activePeriode = periode?.periodeValue ?? _activePeriode;
    context.read<LeaveRequestHistoryProvider>().fetchInitial(
          periode: _activePeriode,
          leaveTypeCategory: 'cuti',
        );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<LeaveRequestHistoryProvider>().loadMore();
    }
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
        PeriodeFilterWidget(
          onPeriodeSelected: (p) => _fetchInitial(periode: p),
          onRefreshTap: (p) => _fetchInitial(periode: p),
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
  final dynamic item; // LeaveRequestModel

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
