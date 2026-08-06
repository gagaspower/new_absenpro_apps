import 'package:absenpro/models/periode/periode_model.dart';
import 'package:absenpro/services/periode/periode_service.dart';
import 'package:flutter/material.dart';

class PeriodeProvider extends ChangeNotifier {
  final PeriodeService _periodeService = PeriodeService();

  bool isLoading = false;
  String? errorMessage;
  List<PeriodeModel> periodeList = [];
  PeriodeModel? selectedPeriode;

  /// Ambil daftar periode dari backend.
  /// [force] = true untuk memaksa fetch ulang walau data sudah ada
  /// (misal untuk pull-to-refresh). Default false supaya tidak fetch
  /// berulang kali kalau sudah pernah dipanggil di menu lain, karena
  /// data periode ini jarang berubah dalam satu sesi pemakaian app.
  Future<void> fetchPeriode({bool force = false}) async {
    if (!force && periodeList.isNotEmpty) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _periodeService.getPeriode();
      periodeList = result;

      // Set default pilihan ke periode pertama (biasanya bulan berjalan)
      // kalau belum ada yang dipilih sebelumnya.
      selectedPeriode ??= periodeList.isNotEmpty ? periodeList.first : null;

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      isLoading = false;
      notifyListeners();
    }
  }

  /// Dipanggil saat user memilih periode dari dropdown di suatu menu.
  void selectPeriode(PeriodeModel periode) {
    selectedPeriode = periode;
    notifyListeners();
  }

  /// Reset state, misal dipanggil saat logout supaya data periode tidak
  /// nyangkut ke sesi user berikutnya.
  void reset() {
    isLoading = false;
    errorMessage = null;
    periodeList = [];
    selectedPeriode = null;
    notifyListeners();
  }
}
