import 'package:absenpro/models/leave_request_model/leave_request_model.dart';
import 'package:absenpro/services/leave_request_service/leave_request_service.dart';
import 'package:flutter/material.dart';

class LeaveRequestHistoryProvider extends ChangeNotifier {
  final LeaveRequestService _service = LeaveRequestService();
  static const int _limit = 10;

  List<LeaveRequestModel> items = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasMore = true;
  String? errorMessage;
  String? _currentStatus;
  String? _currentPeriode;
  String? _currentLeaveTypeCategory;
  int _requestVersion = 0;

  Future<void> fetchInitial({
    String? status,
    String? periode,
    String? leaveTypeCategory,
  }) async {
    final requestVersion = ++_requestVersion;
    _currentStatus = status;
    _currentPeriode = periode;
    _currentLeaveTypeCategory = leaveTypeCategory;
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
        leaveTypeCategory: leaveTypeCategory,
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

  Future<void> loadMore() async {
    if (isLoadingMore || isLoading || !hasMore) return;

    isLoadingMore = true;
    notifyListeners();

    try {
      final page = await _service.getHistory(
        status: _currentStatus,
        periode: _currentPeriode,
        leaveTypeCategory: _currentLeaveTypeCategory,
        limit: _limit,
        offset: items.length,
      );
      items = [...items, ...page.rows];
      hasMore = items.length < page.total;
    } catch (_) {
      // gagal load more, hasMore tetap true biar bisa retry scroll
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
    _currentLeaveTypeCategory = null;
    notifyListeners();
  }
}
