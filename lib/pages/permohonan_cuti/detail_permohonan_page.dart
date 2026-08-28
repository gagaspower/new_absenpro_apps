import 'package:absenpro/models/leave_request_model/leave_request_model.dart';
import 'package:absenpro/pages/histori_tabs/histori_models.dart';
import 'package:absenpro/pages/permohonan_cuti/status_permohonan_page.dart';
import 'package:flutter/material.dart';

/// Halaman detail permohonan cuti/izin — dibuka dari kartu histori.
class DetailPermohonanPage extends StatelessWidget {
  final LeaveRequestModel item;

  const DetailPermohonanPage({super.key, required this.item});

  static const Color _primaryTeal = Color(0xFF2FC7CF);
  static const Color _softBackground = Color(0xFFF4F5F7);
  static const Color _editButtonBorder = Color(0xFFF8D7DA);

  String _durasiLabel(num totalDays) {
    final isWhole = totalDays % 1 == 0;
    final text =
        isWhole ? totalDays.toStringAsFixed(0) : totalDays.toStringAsFixed(1);
    return '$text Hari';
  }

  /// Model lampiran belum tersedia di context, jadi diambil secara
  /// defensif lewat beberapa nama field yang umum. Setiap getter()
  /// dipanggil DI DALAM try/catch (bukan di collection-if), jadi aman
  /// walau field-nya tidak ada.
  String _attachmentLabel(dynamic attachment, int index) {
    for (final getter in [
      () => attachment.fileName,
      () => attachment.originalName,
      () => attachment.name,
      () => attachment.filename,
    ]) {
      try {
        final value = getter();
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString();
        }
      } catch (_) {
        // Field tidak ada di LeaveAttachmentModel -> coba kandidat lain.
      }
    }
    return 'Lampiran ${index + 1}';
  }

  @override
  Widget build(BuildContext context) {
    final style = historiStatusStyle(item.status);
    final isDraft = item.status.toLowerCase() == 'draft';

    return Scaffold(
      backgroundColor: _softBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black87,
        title: const Text(
          'Detail Permohonan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFEDEDED)),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status badge
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: style.bgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    style.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: style.labelColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Lihat status permohonan
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StatusPermohonanPage(item: item),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
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
                    children: const [
                      Text(
                        'Lihat Status Permohonan',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _primaryTeal,
                        ),
                      ),
                      Icon(Icons.arrow_forward, size: 16, color: _primaryTeal),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Detail card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _DetailRow(
                      label: 'Jenis Cuti/Izin',
                      value: item.leaveType?.name ?? '-',
                    ),
                    _DetailRow(label: 'Alasan', value: item.reason),
                    _DetailRow(label: 'Tanggal Mulai', value: item.startDate),
                    _DetailRow(
                      label: 'Tanggal Selesai',
                      value: item.endDate,
                    ),
                    _DetailRow(
                      label: 'Durasi',
                      value: _durasiLabel(item.totalDays),
                    ),
                    _DetailRow(
                      label: 'Alamat yang bisa dihubungi',
                      value: item.addressDuringLeave,
                    ),
                    _DetailRow(
                      label: 'No. Telp yang bisa dihubungi',
                      value: item.phoneDuringLeave,
                    ),
                    if (item.attachments.isEmpty)
                      const _DetailRow(
                        label: 'Lampiran',
                        value: '-',
                        isLast: true,
                      )
                    else
                      for (var i = 0; i < item.attachments.length; i++)
                        _AttachmentRow(
                          fileName: _attachmentLabel(item.attachments[i], i),
                          isLast: i == item.attachments.length - 1,
                        ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: isDraft ? _buildBottomActions(context) : null,
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFEDEDED))),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  // TODO: arahkan ke form edit permohonan, pra-isi dari item
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Color(0xFF721C24),
                  side: const BorderSide(color: _editButtonBorder),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Edit',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // TODO: submit/ajukan permohonan (item.id), status draft -> pending
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryTeal,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Ajukan',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1),
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black45),
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? '-' : value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentRow extends StatelessWidget {
  final String fileName;
  final bool isLast;

  const _AttachmentRow({required this.fileName, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1),
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lampiran',
            style: TextStyle(fontSize: 12, color: Colors.black45),
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: () {
              // TODO: buka/unduh file lampiran
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F2FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.description_outlined,
                    size: 16,
                    color: Color(0xFF2F80ED),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    fileName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2F80ED),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
