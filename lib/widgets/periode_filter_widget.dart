import 'package:absenpro/models/periode/periode_model.dart';
import 'package:absenpro/providers/periode/periode_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Widget filter periode (bulan-tahun) yang reusable.
/// Dipakai di beberapa tab histori (absen, izin, cuti) untuk memilih
/// & memuat ulang data berdasarkan periode yang aktif di [PeriodeProvider].
///
/// Widget ini hanya mengurus UI pemilihan periode; logic fetch data
/// diserahkan ke caller lewat [onPeriodeSelected] dan [onRefreshTap].
class PeriodeFilterWidget extends StatelessWidget {
  /// Dipanggil saat user memilih periode baru dari bottom sheet.
  final ValueChanged<PeriodeModel> onPeriodeSelected;

  /// Dipanggil saat tombol refresh ditekan, dengan periode yang
  /// sedang aktif.
  final ValueChanged<PeriodeModel> onRefreshTap;

  final Color primaryColor;

  const PeriodeFilterWidget({
    super.key,
    required this.onPeriodeSelected,
    required this.onRefreshTap,
    this.primaryColor = const Color(0xFF2FC7CF),
  });

  void _showPeriodeBottomSheet(
    BuildContext context,
    PeriodeProvider periodeProvider,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Pilih Periode',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: periodeProvider.periodeList.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    thickness: 1,
                    indent: 20,
                    endIndent: 20,
                    color: Color(0xFFF0F0F0),
                  ),
                  itemBuilder: (context, index) {
                    final periode = periodeProvider.periodeList[index];
                    final isSelected = periode.periodeValue ==
                        periodeProvider.selectedPeriode?.periodeValue;

                    return ListTile(
                      title: Text(
                        periode.periodeLabel,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? primaryColor : Colors.black87,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_circle,
                              color: primaryColor, size: 20)
                          : null,
                      onTap: () {
                        periodeProvider.selectPeriode(periode);
                        Navigator.pop(sheetContext);
                        onPeriodeSelected(periode);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Consumer<PeriodeProvider>(
        builder: (context, periodeProvider, _) {
          final selected = periodeProvider.selectedPeriode;

          return Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () =>
                      _showPeriodeBottomSheet(context, periodeProvider),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            periodeProvider.isLoading
                                ? 'Memuat periode...'
                                : (selected?.periodeLabel ?? 'Pilih Periode'),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down,
                            size: 20, color: Colors.black45),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  final activePeriode = periodeProvider.selectedPeriode;
                  if (activePeriode != null) {
                    onRefreshTap(activePeriode);
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: primaryColor,
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
          );
        },
      ),
    );
  }
}
