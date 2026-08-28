import 'package:absenpro/models/leave_request_model/leave_request_model.dart';
import 'package:flutter/material.dart';

class StatusPermohonanPage extends StatelessWidget {
  final LeaveRequestModel item;

  const StatusPermohonanPage({
    super.key,
    required this.item,
  });

  static const Color primaryTeal = Color(0xFF2FC7CF);
  static const Color softBackground = Color(0xFFF4F5F7);

  String _formatDateTime(String? value) {
    if (value == null || value.isEmpty) {
      return '';
    }

    try {
      final date = DateTime.parse(value).toLocal();

      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];

      return '${date.day} ${months[date.month - 1]} ${date.year}, '
          '${date.hour.toString().padLeft(2, '0')}:'
          '${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return value;
    }
  }

  String _formatDateRange() {
    final start = item.startDate;
    final end = item.endDate;

    final days = item.totalDays % 1 == 0
        ? item.totalDays.toStringAsFixed(0)
        : item.totalDays.toStringAsFixed(1);

    if (start == end) {
      return '$start ($days Hari)';
    }

    return '$start - $end ($days Hari)';
  }

  PermohonanStepStatus _mapStatus(String status) {
    switch (status.toLowerCase().trim()) {
      case 'completed':
        return PermohonanStepStatus.done;

      case 'current':
        return PermohonanStepStatus.current;

      case 'rejected':
        return PermohonanStepStatus.rejected;

      case 'pending':
      default:
        return PermohonanStepStatus.pending;
    }
  }

  List<PermohonanStep> _buildSteps() {
    return item.timeline.map((timeline) {
      final status = _mapStatus(timeline.status);

      String? time;

      if (timeline.actedAt != null && timeline.actedAt!.trim().isNotEmpty) {
        time = _formatDateTime(timeline.actedAt);
      }

      return PermohonanStep(
        title: timeline.title,
        subtitle: timeline.description,
        time: time,
        status: status,
      );
    }).toList();
  }

  String _statusLabel() {
    switch (item.status.toLowerCase().trim()) {
      case 'approved':
        return 'Disetujui';

      case 'rejected':
        return 'Ditolak';

      case 'cancelled':
        return 'Dibatalkan';

      case 'draft':
        return 'Draft';

      case 'pending':
        return 'Dalam Proses';

      default:
        return item.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = _buildSteps();

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
                    _SummaryCard(
                      requestNumber: item.requestNumber,
                      statusLabel: _statusLabel(),
                      jenisCuti: item.leaveType?.name ?? '-',
                      tanggal: _formatDateRange(),
                    ),
                    const SizedBox(height: 16),
                    _TimelineCard(steps: steps),
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
// Timeline
// ============================================================================

enum PermohonanStepStatus {
  done,
  current,
  pending,
  rejected,
}

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

// ============================================================================
// Summary
// ============================================================================

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.requestNumber,
    required this.statusLabel,
    required this.jenisCuti,
    required this.tanggal,
  });

  final String requestNumber;
  final String statusLabel;
  final String jenisCuti;
  final String tanggal;

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
                requestNumber.isEmpty ? 'Permohonan' : requestNumber,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
              _StatusBadge(label: statusLabel),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            jenisCuti,
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
              const Icon(
                Icons.calendar_month_outlined,
                size: 16,
                color: Colors.black45,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  tanggal,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
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
  const _StatusBadge({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFE7F1FF),
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
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
// Timeline Card
// ============================================================================

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({
    required this.steps,
  });

  final List<PermohonanStep> steps;

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          'Belum ada riwayat status permohonan.',
          style: TextStyle(
            fontSize: 13,
            color: Colors.black54,
          ),
        ),
      );
    }

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
        children: List.generate(
          steps.length,
          (index) {
            return _TimelineRow(
              step: steps[index],
              isLast: index == steps.length - 1,
            );
          },
        ),
      ),
    );
  }
}

// ============================================================================
// Timeline Row
// ============================================================================

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.step,
    required this.isLast,
  });

  final PermohonanStep step;
  final bool isLast;

  static const Color _green = Color(0xFF2FB380);
  static const Color _blue = Color(0xFF2F6FE0);
  static const Color _red = Color(0xFFD9534F);
  static const Color _greyFill = Color(0xFFE7E8EA);
  static const Color _greyDot = Color(0xFFC7C9CC);

  static const double _nodeSize = 26;

  @override
  Widget build(BuildContext context) {
    final isDone = step.status == PermohonanStepStatus.done;
    final isCurrent = step.status == PermohonanStepStatus.current;
    final isRejected = step.status == PermohonanStepStatus.rejected;

    final nodeColor = isRejected ? _red : null;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              _buildNode(
                isDone: isDone,
                isCurrent: isCurrent,
                isRejected: isRejected,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    color: isDone
                        ? _green
                        : isRejected
                            ? _red
                            : _greyFill,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 16 : 26,
              ),
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
                            color: (isDone || isCurrent || isRejected)
                                ? Colors.black87
                                : Colors.black45,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      if (step.time != null && step.time!.isNotEmpty) ...[
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
                      fontWeight: isCurrent || isRejected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isRejected
                          ? _red
                          : isCurrent
                              ? _blue
                              : isDone
                                  ? Colors.black54
                                  : Colors.black38,
                    ),
                  ),
                  if (step.status == PermohonanStepStatus.rejected &&
                      step.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNode({
    required bool isDone,
    required bool isCurrent,
    required bool isRejected,
  }) {
    if (isRejected) {
      return Container(
        width: _nodeSize,
        height: _nodeSize,
        decoration: const BoxDecoration(
          color: _red,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.close,
          size: 15,
          color: Colors.white,
        ),
      );
    }

    if (isDone) {
      return Container(
        width: _nodeSize,
        height: _nodeSize,
        decoration: const BoxDecoration(
          color: _green,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.check,
          size: 15,
          color: Colors.white,
        ),
      );
    }

    if (isCurrent) {
      return Container(
        width: _nodeSize,
        height: _nodeSize,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: _blue,
            width: 2,
          ),
        ),
        alignment: Alignment.center,
        child: Container(
          width: 9,
          height: 9,
          decoration: const BoxDecoration(
            color: _blue,
            shape: BoxShape.circle,
          ),
        ),
      );
    }

    return Container(
      width: _nodeSize,
      height: _nodeSize,
      decoration: const BoxDecoration(
        color: _greyFill,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Container(
        width: 7,
        height: 7,
        decoration: const BoxDecoration(
          color: _greyDot,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ============================================================================
// Bottom Button
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
