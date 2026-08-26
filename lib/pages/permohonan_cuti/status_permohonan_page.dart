import 'package:flutter/material.dart';

/// Halaman "Status Permohonan" — dibuka dari tombol/aksi "Lihat Status
/// Permohonan" pada halaman detail permohonan cuti/izin.
///
/// Halaman ini masih berdiri sendiri (belum ada provider/model terkait),
/// jadi seluruh datanya di-hardcode sesuai mockup. Saat backend untuk
/// status permohonan sudah tersedia, tinggal ganti `_steps` dan data
/// ringkasan (`_SummaryData`) dengan data asli dari provider, misalnya
/// dengan menerima `LeaveRequestModel` lewat constructor.
class StatusPermohonanPage extends StatelessWidget {
  const StatusPermohonanPage({super.key});

  static const Color primaryTeal = Color(0xFF2FC7CF);
  static const Color softBackground = Color(0xFFF4F5F7);

  // --- Dummy data, sesuai mockup ---------------------------------------
  static const _summary = _SummaryData(
    idPermohonan: '#10924',
    statusLabel: 'Dalam Proses',
    jenisCuti: 'Cuti Tahunan',
    tanggal: '25 - 28 Agustus 2026 (4 Hari)',
  );

  static const List<PermohonanStep> _steps = [
    PermohonanStep(
      title: 'Permohonan Dibuat',
      subtitle: 'Draft tersimpan di sistem',
      time: '20 Agt 2026, 09:00',
      status: PermohonanStepStatus.done,
    ),
    PermohonanStep(
      title: 'Diajukan ke Atasan',
      subtitle: 'Menunggu tanggapan Manager',
      time: '20 Agt 2026, 09:15',
      status: PermohonanStepStatus.done,
    ),
    PermohonanStep(
      title: 'Review oleh Atasan Langsung',
      subtitle: 'Sedang ditinjau oleh Budi Santoso (Manager)',
      time: '21 Agt 2026',
      status: PermohonanStepStatus.current,
    ),
    PermohonanStep(
      title: 'Persetujuan HR',
      subtitle: 'Proses verifikasi oleh Tim HR',
      status: PermohonanStepStatus.pending,
    ),
    PermohonanStep(
      title: 'Selesai / Disetujui',
      subtitle: 'Cuti terdaftar resmi di sistem',
      status: PermohonanStepStatus.pending,
    ),
  ];
  // -----------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black87,
        title: const Text(
          'Status Permohonan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SummaryCard(data: _summary),
                    const SizedBox(height: 16),
                    _TimelineCard(steps: _steps),
                  ],
                ),
              ),
            ),
            _BottomButton(
              label: 'Kembali ke Detail',
              color: primaryTeal,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Data models
// ============================================================================

enum PermohonanStepStatus { done, current, pending }

class PermohonanStep {
  final String title;
  final String subtitle;
  final String? time;
  final PermohonanStepStatus status;

  const PermohonanStep({
    required this.title,
    required this.subtitle,
    this.time,
    required this.status,
  });
}

class _SummaryData {
  final String idPermohonan;
  final String statusLabel;
  final String jenisCuti;
  final String tanggal;

  const _SummaryData({
    required this.idPermohonan,
    required this.statusLabel,
    required this.jenisCuti,
    required this.tanggal,
  });
}

// ============================================================================
// Summary card (ID, status badge, jenis cuti, tanggal)
// ============================================================================

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.data});

  final _SummaryData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ID Permohonan: ${data.idPermohonan}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
              _StatusBadge(label: data.statusLabel),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            data.jenisCuti,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_month_outlined,
                  size: 16, color: Colors.black45),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  data.tanggal,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F1FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF2F6FE0),
        ),
      ),
    );
  }
}

// ============================================================================
// Timeline card
// ============================================================================

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.steps});

  final List<PermohonanStep> steps;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 4),
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
        children: List.generate(steps.length, (index) {
          return _TimelineRow(
            step: steps[index],
            isLast: index == steps.length - 1,
          );
        }),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.step, required this.isLast});

  final PermohonanStep step;
  final bool isLast;

  static const Color _green = Color(0xFF2FB380);
  static const Color _blue = Color(0xFF2F6FE0);
  static const Color _greyFill = Color(0xFFE7E8EA);
  static const Color _greyDot = Color(0xFFC7C9CC);
  static const double _nodeSize = 26;

  @override
  Widget build(BuildContext context) {
    final isDone = step.status == PermohonanStepStatus.done;
    final isCurrent = step.status == PermohonanStepStatus.current;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              _buildNode(isDone: isDone, isCurrent: isCurrent),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    color: isDone ? _green : _greyFill,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 16 : 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          step.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: (isDone || isCurrent)
                                ? Colors.black87
                                : Colors.black45,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      if (step.time != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          step.time!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black38,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    step.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                      color: isCurrent
                          ? _blue
                          : (isDone ? Colors.black54 : Colors.black38),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNode({required bool isDone, required bool isCurrent}) {
    if (isDone) {
      return Container(
        width: _nodeSize,
        height: _nodeSize,
        decoration: const BoxDecoration(color: _green, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: const Icon(Icons.check, size: 15, color: Colors.white),
      );
    }
    if (isCurrent) {
      return Container(
        width: _nodeSize,
        height: _nodeSize,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: _blue, width: 2),
        ),
        alignment: Alignment.center,
        child: Container(
          width: 9,
          height: 9,
          decoration: const BoxDecoration(color: _blue, shape: BoxShape.circle),
        ),
      );
    }
    return Container(
      width: _nodeSize,
      height: _nodeSize,
      decoration: const BoxDecoration(color: _greyFill, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Container(
        width: 7,
        height: 7,
        decoration:
            const BoxDecoration(color: _greyDot, shape: BoxShape.circle),
      ),
    );
  }
}

// ============================================================================
// Bottom action button
// ============================================================================

class _BottomButton extends StatelessWidget {
  const _BottomButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }
}
