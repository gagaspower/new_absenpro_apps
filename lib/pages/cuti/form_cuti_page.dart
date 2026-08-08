import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:absenpro/providers/leave_type/leave_type_provider.dart';

class FormCutiPage extends StatefulWidget {
  const FormCutiPage({super.key});

  @override
  State<FormCutiPage> createState() => _FormCutiPageState();
}

class _FormCutiPageState extends State<FormCutiPage> {
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _totalDaysController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  dynamic _selectedLeaveType; // simpan objek leave type yang dipilih

  static const Color lightGray = Color(0xFFE0E0E0);
  static const Color primaryTeal = Color(0xFF2FC7CF);
  final formkey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provLeaveType =
          Provider.of<LeaveTypeProvider>(context, listen: false);
      // Don't call reset() right after fetch — it wipes the list you just loaded.
      provLeaveType.fetchLeaveTypes();
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _totalDaysController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submitForm() {
    // Validasi input sebelum submit
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
            onPressed:
                formkey.currentState?.validate() == true ? _submitForm : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryTeal,
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
        body: SafeArea(child: _buildBody()));
  }

  Widget _buildBody() {
    return Padding(padding: const EdgeInsets.all(16.0), child: _buildForm());
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputField(
            label: 'Alasan',
            controller: _reasonController,
          ),
          const SizedBox(height: 16.0),
          _buildInputField(
            label: 'Jenis Cuti/Izin',
            controller:
                TextEditingController(text: _selectedLeaveType?.name ?? ''),
            validator: (String? value) {
              if (_selectedLeaveType == null) {
                return 'Harap pilih jenis cuti/izin';
              }
              return null;
            },
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => _showModalBottomSheet(context),
              );
            },
          ),
          const SizedBox(height: 16.0),
          _buildDatePickerField(
            label: 'Tanggal Mulai',
            controller: _startDateController,
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Harap pilih tanggal mulai';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          _buildDatePickerField(
            label: 'Tanggal Selesai',
            controller: _endDateController,
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Harap pilih tanggal selesai';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          _buildInputField(
            label: 'Jam Mulai',
            controller: _startTimeController,
            keyboardType: TextInputType.datetime,
            onTap: () async {
              TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );

              if (pickedTime != null) {
                setState(() {
                  _startTimeController.text =
                      "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
                });
              }
            },
          ),
          const SizedBox(height: 16.0),
          _buildInputField(
            label: 'Jam Selesai',
            controller: _endTimeController,
            keyboardType: TextInputType.datetime,
            onTap: () async {
              TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );

              if (pickedTime != null) {
                setState(() {
                  _endTimeController.text =
                      "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
                });
              }
            },
          ),
          const SizedBox(height: 16.0),
          _buildInputField(
            label: 'Total Hari',
            controller: _totalDaysController,
            keyboardType: TextInputType.number,
            readOnly:
                true, // Total hari dihitung otomatis dari tanggal mulai dan selesai
          ),
          const SizedBox(height: 16.0),
          _buildInputField(
            label: 'Alamat yang bisa dihubungi',
            controller: _addressController,
            multiline: true,
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Harap isi alamat yang bisa dihubungi';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          _buildInputField(
            label: 'No. Telepon yang bisa dihubungi',
            controller: _phoneController,
            multiline: true,
            keyboardType: TextInputType.phone,
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Harap isi no. telepon yang bisa dihubungi';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }

  Widget _buildInputField(
      {required String label,
      required TextEditingController controller,
      VoidCallback? onTap,
      TextInputType? keyboardType,
      bool multiline = false,
      FormFieldValidator<String>? validator,
      bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8.0),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(
              color: lightGray,
              width: 1.0,
            ),
          ),
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
            ),
            onTap: onTap,
            keyboardType: keyboardType ?? TextInputType.text,
            maxLines: multiline ? null : 1,
            readOnly: readOnly,
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerField(
      {required String label,
      required TextEditingController controller,
      FormFieldValidator<String>? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8.0),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(
              color: lightGray,
              width: 1.0,
            ),
          ),
          child: TextFormField(
            controller: controller,
            readOnly: true,
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );

              if (pickedDate != null) {
                setState(() {
                  controller.text =
                      "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                });
              }
            },
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
            ),
          ),
        ),
      ],
    );
  }

  Widget _showModalBottomSheet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 12.0, bottom: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
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

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
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

          // List
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
                      setState(() {
                        _selectedLeaveType = leaveType;
                      });
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
