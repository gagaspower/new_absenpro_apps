import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:absenpro/providers/leave_type/leave_type_provider.dart';
import 'package:absenpro/models/leave_type/leave_type_model.dart';

const Color _lightGray = Color(0xFFE0E0E0);
const Color _primaryTeal = Color(0xFF2FC7CF);

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
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  LeaveTypeModel? _selectedLeaveType;
  final formkey = GlobalKey<FormState>();

  bool get _isHourUnit => _selectedLeaveType?.unit == 'hour';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provLeaveType =
          Provider.of<LeaveTypeProvider>(context, listen: false);
      provLeaveType.fetchLeaveTypes();
    });

    // These fire on ANY controller text change — typed or programmatic
    // (e.g. from a date/time picker) — so the total updates immediately.
    _startDateController.addListener(_recalculateTotal);
    _endDateController.addListener(_recalculateTotal);
    _startTimeController.addListener(_recalculateTotal);
    _endTimeController.addListener(_recalculateTotal);
  }

  @override
  void dispose() {
    _startDateController.removeListener(_recalculateTotal);
    _endDateController.removeListener(_recalculateTotal);
    _startTimeController.removeListener(_recalculateTotal);
    _endTimeController.removeListener(_recalculateTotal);

    _reasonController.dispose();
    _leaveTypeController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _totalController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _recalculateTotal() {
    // Setting a controller's .text updates that TextField immediately —
    // no setState needed here, it's not driving any other widget's layout.
    if (_isHourUnit) {
      if (_startTimeController.text.isEmpty ||
          _endTimeController.text.isEmpty) {
        _totalController.text = '';
        return;
      }

      final startParts = _startTimeController.text.split(':');
      final endParts = _endTimeController.text.split(':');

      if (startParts.length != 2 || endParts.length != 2) {
        _totalController.text = '';
        return;
      }

      final startMinutes =
          int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
      final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
      final diffMinutes = endMinutes - startMinutes;

      if (diffMinutes <= 0) {
        _totalController.text = '';
        return;
      }

      final totalHours = diffMinutes / 60;
      _totalController.text = totalHours % 1 == 0
          ? totalHours.toStringAsFixed(0)
          : totalHours.toStringAsFixed(2);
    } else {
      if (_startDateController.text.isEmpty ||
          _endDateController.text.isEmpty) {
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

      final difference = endDate.difference(startDate).inDays + 1;
      _totalController.text = difference > 0 ? difference.toString() : '';
    }
  }

  void _onLeaveTypeSelected(LeaveTypeModel leaveType) {
    setState(() {
      _selectedLeaveType = leaveType;
      _leaveTypeController.text = leaveType.name;

      if (_isHourUnit) {
        if (_startDateController.text.isNotEmpty) {
          _endDateController.text = _startDateController.text;
        }
      } else {
        _startTimeController.text = '';
        _endTimeController.text = '';
      }

      _recalculateTotal();
    });
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate == null) return;

    controller.text =
        "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";

    if (controller == _startDateController && _isHourUnit) {
      _endDateController.text = _startDateController.text;
    }
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null) return;

    controller.text =
        "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
  }

  void _submitForm() {
    if (formkey.currentState?.validate() != true) {
      return;
    }
    // TODO: proses submit data cuti/izin
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
        child: ElevatedButton(
          onPressed: _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryTeal,
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: const Text(
            'Kirim',
            style: TextStyle(fontSize: 16.0, color: Colors.white),
          ),
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
    final bool isHourUnit = _isHourUnit;

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
            enabled: !isHourUnit,
            onTap: () => _pickDate(_endDateController),
            validator: (value) => (value == null || value.isEmpty)
                ? 'Harap pilih tanggal selesai'
                : null,
          ),
          const SizedBox(height: 16.0),
          _BorderedFormField(
            label: 'Jam Mulai',
            controller: _startTimeController,
            readOnly: true,
            enabled: isHourUnit,
            onTap: () => _pickTime(_startTimeController),
            validator: isHourUnit
                ? (value) => (value == null || value.isEmpty)
                    ? 'Harap pilih jam mulai'
                    : null
                : null,
          ),
          const SizedBox(height: 16.0),
          _BorderedFormField(
            label: 'Jam Selesai',
            controller: _endTimeController,
            readOnly: true,
            enabled: isHourUnit,
            onTap: () => _pickTime(_endTimeController),
            validator: isHourUnit
                ? (value) => (value == null || value.isEmpty)
                    ? 'Harap pilih jam selesai'
                    : null
                : null,
          ),
          const SizedBox(height: 16.0),
          _BorderedFormField(
            label: isHourUnit ? 'Total Jam' : 'Total Hari',
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
        ],
      ),
    );
  }

  Widget _showModalBottomSheet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 12.0, bottom: 16.0),
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pilih Jenis Cuti/Izin',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
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
              if (provLeaveType.leaveTypeList.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                    onTap: () {
                      _onLeaveTypeSelected(leaveType);
                      Navigator.pop(context);
                    },
                  );
                },
                separatorBuilder: (context, index) =>
                    const Divider(height: 1.0),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// A bordered input box that hooks into the ancestor [Form] for validation,
/// but keeps the error message as a separate line BELOW the box instead of
/// inside the same decorator (which is what made the box look like it grew
/// into a multiline field).
///
/// Listens directly to [controller] so validation/error state stays in sync
/// whether the text changes from typing OR from code (date/time pickers).
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
    widget.controller.addListener(_handleControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChanged);
    super.dispose();
  }

  void _handleControllerChanged() {
    _fieldKey.currentState?.didChange(widget.controller.text);
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
                    color:
                        widget.enabled ? Colors.white : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(5.0),
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
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                    ),
                    onTap: widget.enabled ? widget.onTap : null,
                    keyboardType: widget.keyboardType ?? TextInputType.text,
                    maxLines: widget.multiline ? null : 1,
                    readOnly: widget.readOnly || !widget.enabled,
                    enabled: widget.enabled,
                    onChanged: (value) => state.didChange(value),
                  ),
                ),
                if (state.hasError) ...[
                  const SizedBox(height: 4.0),
                  Text(
                    state.errorText ?? '',
                    style: const TextStyle(color: Colors.red, fontSize: 12.0),
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
