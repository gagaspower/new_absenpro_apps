import 'dart:io';

import 'package:absenpro/models/leave_request_model/leave_request_model.dart';
import 'package:absenpro/services/leave_request_service/leave_request_service.dart';
import 'package:flutter/material.dart';

class LeaveRequestProvider extends ChangeNotifier {
  final LeaveRequestService _leaveRequestService = LeaveRequestService();

  bool isSubmitting = false;
  String? errorMessage;
  LeaveRequestModel? lastSubmittedRequest;

  /// Return true kalau sukses. Error tersimpan di [errorMessage].
  Future<bool> submitLeaveRequest(
    LeaveRequestPayload payload, {
    File? attachment,
  }) async {
    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _leaveRequestService.submitLeaveRequest(
        payload,
        attachment: attachment,
      );
      lastSubmittedRequest = result;
      isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  void reset() {
    isSubmitting = false;
    errorMessage = null;
    lastSubmittedRequest = null;
    notifyListeners();
  }
}
