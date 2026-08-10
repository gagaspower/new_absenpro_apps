import 'package:absenpro/models/leave_request_model/leave_request_model.dart';
import 'package:absenpro/services/leave_request_service/leave_request_service.dart';
import 'package:flutter/material.dart';

class LeaveRequestHistoryProvider extends ChangeNotifier {
  final LeaveRequestService _service = LeaveRequestService();
  static const int _limit = 10;

  List<LeaveRequestModel> items = [];
  bool isLoading = false; // loading awal (ganti filter / pertama buka)
  bool isLoadingMore = false; // loading tambahan (infinite scroll)
  bool hasMore = true;
  String? errorMessage;
  String? _currentStatus;
  String? _currentPeriode;
  int _requestVersion = 0;

  /// Muat ulang dari awal (offset 0), dipanggil saat pertama buka tab
  /// Riwayat Cuti/Izin atau saat user ganti filter status/periode.
  Future<void> fetchInitial({String? status, String? periode}) async {
    final requestVersion = ++_requestVersion;
    _currentStatus = status;
    _currentPeriode = periode;
    final previousItems = List<LeaveRequestModel>.from(items);

    isLoading = true;
    errorMessage = null;
    items = [];
    hasMore = true;
    notifyListeners();

    try {
      final page = await _service.getHistory(
        status: status,
        periode: periode,
        limit: _limit,
        offset: 0,
      );

      if (requestVersion != _requestVersion) return;

      items = page.rows;
      hasMore = items.length < page.total;
      isLoading = false;
      notifyListeners();
    } catch (e) {
      if (requestVersion != _requestVersion) return;

      items = previousItems;
      hasMore = false;
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      isLoading = false;
      notifyListeners();
    }
  }

  /// Muat halaman berikutnya (offset = jumlah item yang sudah ada),
  /// dipanggil saat user scroll mendekati bawah list.
  Future<void> loadMore() async {
    if (isLoadingMore || isLoading || !hasMore) return;

    isLoadingMore = true;
    notifyListeners();

    try {
      final page = await _service.getHistory(
        status: _currentStatus,
        periode: _currentPeriode,
        limit: _limit,
        offset: items.length,
      );
      items = [...items, ...page.rows];
      hasMore = items.length < page.total;
    } catch (_) {
      // Gagal load more (mis. koneksi putus sesaat) — hasMore tetap true
      // supaya user bisa scroll lagi untuk retry, tanpa perlu reset state.
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  void reset() {
    isLoading = false;
    isLoadingMore = false;
    hasMore = true;
    errorMessage = null;
    items = [];
    _currentStatus = null;
    _currentPeriode = null;
    notifyListeners();
  }
}
