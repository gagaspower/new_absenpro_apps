import 'package:absenpro/models/leave_type/leave_type_model.dart';
import 'package:absenpro/services/leave_type/leave_type_service.dart';
import 'package:flutter/material.dart';

class LeaveTypeProvider extends ChangeNotifier {
  final LeaveTypeService _leaveTypeService = LeaveTypeService();

  bool isLoading = false;
  String? errorMessage;
  List<LeaveTypeModel> leaveTypeList = [];
  LeaveTypeModel? selectedLeaveType;

  Future<void> fetchLeaveTypes({bool force = false}) async {
    if (!force && leaveTypeList.isNotEmpty) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _leaveTypeService.getLeaveTypes();
      leaveTypeList = result;

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');

      isLoading = false;
      notifyListeners();
    }
  }

  void selectLeaveType(LeaveTypeModel leaveType) {
    selectedLeaveType = leaveType;
    notifyListeners();
  }

  void reset() {
    isLoading = false;
    errorMessage = null;
    leaveTypeList = [];
    selectedLeaveType = null;
    notifyListeners();
  }
}
