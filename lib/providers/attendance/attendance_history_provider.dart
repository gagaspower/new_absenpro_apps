import 'package:absenpro/models/attendance_history/attendance_history_model.dart';
import 'package:absenpro/services/attendance/attendance_history_service.dart';
import 'package:flutter/material.dart';

class AttendanceHistoryProvider extends ChangeNotifier {
  final AttendanceHistoryService _service = AttendanceHistoryService();
  static const int _limit = 10;

  List<AttendanceHistoryModel> items = [];
  bool isLoading = false; // loading awal (ganti periode / pertama buka)
  bool isLoadingMore = false; // loading tambahan (infinite scroll)
  bool hasMore = true;
  String? errorMessage;
  String? _currentPeriode;
  int _requestVersion = 0;

  /// Muat ulang dari awal (offset 0), dipanggil saat pertama buka tab
  /// Absen atau saat user ganti periode dari bottom sheet.
  Future<void> fetchInitial({String? periode}) async {
    final requestVersion = ++_requestVersion;
    _currentPeriode = periode;
    final previousItems = List<AttendanceHistoryModel>.from(items);

    isLoading = true;
    errorMessage = null;
    items = [];
    hasMore = true;
    notifyListeners();

    try {
      final page = await _service.getHistory(
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
      errorMessage = null;
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
}
