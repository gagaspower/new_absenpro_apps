import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:absenpro/providers/leave_type/leave_type_provider.dart';
import 'package:absenpro/models/leave_type/leave_type_model.dart';
import 'package:absenpro/providers/leave_request/leave_request_provider.dart';
import 'package:absenpro/models/leave_request_model/leave_request_model.dart';
import 'package:absenpro/widgets/custom_alert_dialog.dart';

const Color _lightGray = Color(0xFFE0E0E0);
const Color _primaryTeal = Color(0xFF2FC7CF);
const Color _draftPink = Color(0xFFFF9B9B);

class FormCutiPage extends StatefulWidget {
  const FormCutiPage({super.key});

  @override
  State<FormCutiPage> createState() => _FormCutiPageState();
}

class _FormCutiPageState extends State<FormCutiPage> {
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _leaveTypeController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  File? _selectedDocument;
  String? _selectedDocumentName;
  String? _documentError;

  LeaveTypeModel? _selectedLeaveType;
  final formkey = GlobalKey<FormState>();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provLeaveType =
          Provider.of<LeaveTypeProvider>(context, listen: false);

      provLeaveType.fetchLeaveTypes(force: true);
    });

    _startDateController.addListener(_recalculateTotal);
    _endDateController.addListener(_recalculateTotal);
  }

  @override
  void dispose() {
    _startDateController.removeListener(_recalculateTotal);
    _endDateController.removeListener(_recalculateTotal);

    _reasonController.dispose();
    _leaveTypeController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _totalController.dispose();
    _addressController.dispose();
    _phoneController.dispose();

    super.dispose();
  }

  void _recalculateTotal() {
    if (_startDateController.text.isEmpty || _endDateController.text.isEmpty) {
      _totalController.text = '';
      return;
    }

    final startParts = _startDateController.text.split('/');
    final endParts = _endDateController.text.split('/');

    if (startParts.length != 3 || endParts.length != 3) {
      _totalController.text = '';
      return;
    }

    final startDate = DateTime(
      int.parse(startParts[2]),
      int.parse(startParts[1]),
      int.parse(startParts[0]),
    );

    final endDate = DateTime(
      int.parse(endParts[2]),
      int.parse(endParts[1]),
      int.parse(endParts[0]),
    );

    if (endDate.isBefore(startDate)) {
      _totalController.text = '';
      return;
    }

    int totalDays = 0;

    for (DateTime day = startDate;
        !day.isAfter(endDate);
        day = day.add(const Duration(days: 1))) {
      // Hari Minggu tidak dihitung.
      if (day.weekday != DateTime.sunday) {
        totalDays++;
      }
    }

    _totalController.text = totalDays > 0 ? totalDays.toString() : '';
  }

  void _onLeaveTypeSelected(LeaveTypeModel leaveType) {
    setState(() {
      _selectedLeaveType = leaveType;
      _leaveTypeController.text = leaveType.name;
      _documentError = null;
    });

    _recalculateTotal();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate == null) return;

    controller.text = '${pickedDate.day.toString().padLeft(2, '0')}/'
        '${pickedDate.month.toString().padLeft(2, '0')}/'
        '${pickedDate.year}';
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      allowMultiple: false,
    );

    if (result == null || result.files.single.path == null) return;

    final pickedFile = result.files.single;

    setState(() {
      _selectedDocument = File(pickedFile.path!);
      _selectedDocumentName = pickedFile.name;
      _documentError = null;
    });
  }

  void _removeDocument() {
    setState(() {
      _selectedDocument = null;
      _selectedDocumentName = null;
      _documentError = null;
    });
  }

  String _toApiDate(String ddMmYyyy) {
    final parts = ddMmYyyy.split('/');

    if (parts.length != 3) {
      return ddMmYyyy;
    }

    final day = parts[0].padLeft(2, '0');
    final month = parts[1].padLeft(2, '0');
    final year = parts[2];

    return '$year-$month-$day';
  }

  num _parseTotal(String text) {
    return num.tryParse(text) ?? 0;
  }

  Future<void> _showLoadingOverlay() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black45,
      useRootNavigator: true,
      builder: (_) => const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );
  }

  void _hideLoadingOverlay() {
    final navigator = Navigator.of(
      context,
      rootNavigator: true,
    );

    if (navigator.canPop()) {
      navigator.pop();
    }
  }

  Future<void> _submitForm({
    bool asDraft = false,
  }) async {
    final isFormValid = formkey.currentState?.validate() == true;

    final attachmentValid = asDraft ||
        _selectedLeaveType?.requireAttachment != 1 ||
        _selectedDocument != null;

    setState(() {
      _documentError = attachmentValid
          ? null
          : 'Dokumen pendukung wajib diupload untuk jenis cuti/izin ini.';
    });

    if (asDraft) {
      if (_selectedLeaveType == null) {
        return;
      }
    } else if (!isFormValid || !attachmentValid || _selectedLeaveType == null) {
      return;
    }

    final payload = LeaveRequestPayload(
      leaveTypeId: _selectedLeaveType!.id,
      startDate: _toApiDate(
        _startDateController.text,
      ),
      endDate: _toApiDate(
        _endDateController.text,
      ),
      totalDays: _parseTotal(
        _totalController.text,
      ),
      reason: _reasonController.text,
      addressDuringLeave: _addressController.text,
      phoneDuringLeave: _phoneController.text,
      status: asDraft ? 'draft' : 'pending',
    );

    final provLeaveRequest = Provider.of<LeaveRequestProvider>(
      context,
      listen: false,
    );

    setState(() {
      _isSubmitting = true;
    });

    unawaited(_showLoadingOverlay());

    final success = await provLeaveRequest.submitLeaveRequest(
      payload,
      attachment: _selectedDocument,
    );

    if (!mounted) {
      return;
    }

    _hideLoadingOverlay();

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      final result = provLeaveRequest.lastSubmittedRequest;

      final verb = asDraft ? 'disimpan sebagai draft' : 'berhasil dikirim';

      await showCustomAlert(
        context: context,
        title: 'Berhasil',
        message: result != null
            ? 'Pengajuan ${result.requestNumber} $verb.'
            : 'Pengajuan cuti/izin $verb.',
        assetPath: 'assets/images/alert/check-mark.png',
        accentColor: const Color(0xFF4CAF7D),
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(context, true);
    } else {
      await showCustomAlert(
        context: context,
        title: 'Gagal',
        message: provLeaveRequest.errorMessage ?? 'Gagal mengirim pengajuan.',
        assetPath: 'assets/images/alert/warning.png',
        accentColor: const Color(0xFFE0637A),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Form Cuti/Izin'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : () => _submitForm(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryTeal,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Ajukan',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : () => _submitForm(
                          asDraft: true,
                        ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _draftPink,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Draft',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Form(
          key: formkey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BorderedFormField(
            label: 'Alasan',
            controller: _reasonController,
            validator: (value) =>
                (value == null || value.isEmpty) ? 'Harap isi alasan' : null,
          ),
          const SizedBox(height: 16.0),
          _BorderedFormField(
            label: 'Jenis Cuti/Izin',
            controller: _leaveTypeController,
            readOnly: true,
            validator: (_) => _selectedLeaveType == null
                ? 'Harap pilih jenis cuti/izin'
                : null,
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => _showModalBottomSheet(context),
              );
            },
          ),
          const SizedBox(height: 16.0),
          _BorderedFormField(
            label: 'Tanggal Mulai',
            controller: _startDateController,
            readOnly: true,
            onTap: () => _pickDate(_startDateController),
            validator: (value) => (value == null || value.isEmpty)
                ? 'Harap pilih tanggal mulai'
                : null,
          ),
          const SizedBox(height: 16.0),
          _BorderedFormField(
            label: 'Tanggal Selesai',
            controller: _endDateController,
            readOnly: true,
            onTap: () => _pickDate(_endDateController),
            validator: (value) => (value == null || value.isEmpty)
                ? 'Harap pilih tanggal selesai'
                : null,
          ),
          const SizedBox(height: 16.0),
          _BorderedFormField(
            label: 'Total Hari',
            controller: _totalController,
            keyboardType: TextInputType.number,
            readOnly: true,
          ),
          const SizedBox(height: 16.0),
          _BorderedFormField(
            label: 'Alamat yang bisa dihubungi',
            controller: _addressController,
            multiline: true,
            validator: (value) => (value == null || value.isEmpty)
                ? 'Harap isi alamat yang bisa dihubungi'
                : null,
          ),
          const SizedBox(height: 16.0),
          _BorderedFormField(
            label: 'No. Telepon yang bisa dihubungi',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            validator: (value) => (value == null || value.isEmpty)
                ? 'Harap isi no. telepon yang bisa dihubungi'
                : null,
          ),
          const SizedBox(height: 16.0),
          _buildDocumentUploadField(),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }

  Widget _buildDocumentUploadField() {
    final bool isRequired = _selectedLeaveType?.requireAttachment == 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Dokumen Pendukung'),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8.0),
        InkWell(
          onTap: _pickDocument,
          borderRadius: BorderRadius.circular(5.0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 12.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(
                color: _documentError != null ? Colors.red : _lightGray,
              ),
            ),
            child: _selectedDocumentName == null
                ? const Row(
                    children: [
                      Icon(
                        Icons.upload_file,
                        color: _primaryTeal,
                      ),
                      SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          'Pilih dokumen (PDF, PNG, JPG, JPEG)',
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Icon(
                        _selectedDocumentName!.toLowerCase().endsWith('.pdf')
                            ? Icons.picture_as_pdf
                            : Icons.image,
                        color: _primaryTeal,
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          _selectedDocumentName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Hapus dokumen',
                        icon: const Icon(
                          Icons.close,
                          color: Colors.red,
                        ),
                        onPressed: _removeDocument,
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 4.0),
        if (_documentError != null)
          Text(
            _documentError!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12.0,
            ),
          )
        else
          const Text(
            'Format yang diperbolehkan: PDF, PNG, JPG, JPEG',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 12.0,
            ),
          ),
      ],
    );
  }

  Widget _showModalBottomSheet(
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.only(
        top: 12.0,
        bottom: 16.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pilih Jenis Cuti/Izin',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1.0),
          Consumer<LeaveTypeProvider>(
            builder: (context, provLeaveType, _) {
              if (provLeaveType.isLoading &&
                  provLeaveType.leaveTypeList.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 32.0,
                  ),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (provLeaveType.errorMessage != null &&
                  provLeaveType.leaveTypeList.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 24.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.redAccent,
                        size: 32.0,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        provLeaveType.errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      TextButton(
                        onPressed: () => provLeaveType.fetchLeaveTypes(
                          force: true,
                        ),
                        child: const Text('Coba lagi'),
                      ),
                    ],
                  ),
                );
              }

              if (provLeaveType.leaveTypeList.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 24.0,
                  ),
                  child: Center(
                    child: Text(
                      'Tidak ada jenis cuti/izin tersedia.',
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                ),
                itemCount: provLeaveType.leaveTypeList.length,
                itemBuilder: (context, index) {
                  final leaveType = provLeaveType.leaveTypeList[index];

                  final bool isSelected = _selectedLeaveType == leaveType;

                  return ListTile(
                    title: Text(
                      leaveType.name,
                      style: TextStyle(
                        color: isSelected ? Colors.green : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          )
                        : null,
                    onTap: () {
                      _onLeaveTypeSelected(
                        leaveType,
                      );
                      Navigator.pop(context);
                    },
                  );
                },
                separatorBuilder: (context, index) => const Divider(
                  height: 1.0,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BorderedFormField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final bool multiline;
  final FormFieldValidator<String>? validator;
  final bool readOnly;
  final bool enabled;

  const _BorderedFormField({
    required this.label,
    required this.controller,
    this.onTap,
    this.keyboardType,
    this.multiline = false,
    this.validator,
    this.readOnly = false,
    this.enabled = true,
  });

  @override
  State<_BorderedFormField> createState() => _BorderedFormFieldState();
}

class _BorderedFormFieldState extends State<_BorderedFormField> {
  final GlobalKey<FormFieldState<String>> _fieldKey =
      GlobalKey<FormFieldState<String>>();

  @override
  void initState() {
    super.initState();

    widget.controller.addListener(
      _handleControllerChanged,
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(
      _handleControllerChanged,
    );

    super.dispose();
  }

  void _handleControllerChanged() {
    _fieldKey.currentState?.didChange(
      widget.controller.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label),
        const SizedBox(height: 8.0),
        FormField<String>(
          key: _fieldKey,
          initialValue: widget.controller.text,
          validator: widget.enabled ? widget.validator : null,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          builder: (FormFieldState<String> state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: widget.enabled
                        ? Colors.white
                        : const Color(
                            0xFFF5F5F5,
                          ),
                    borderRadius: BorderRadius.circular(
                      5.0,
                    ),
                    border: Border.all(
                      color: state.hasError ? Colors.red : _lightGray,
                      width: 1.0,
                    ),
                  ),
                  child: TextField(
                    controller: widget.controller,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 8.0,
                      ),
                    ),
                    onTap: widget.enabled ? widget.onTap : null,
                    keyboardType: widget.keyboardType ?? TextInputType.text,
                    maxLines: widget.multiline ? null : 1,
                    readOnly: widget.readOnly || !widget.enabled,
                    enabled: widget.enabled,
                    onChanged: (value) => state.didChange(
                      value,
                    ),
                  ),
                ),
                if (state.hasError) ...[
                  const SizedBox(height: 4.0),
                  Text(
                    state.errorText ?? '',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}
