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

  static const Color lightGray = Color(0xFFE0E0E0);

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
    super.dispose();
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
        body: SafeArea(child: _buildBody()));
  }

  Widget _buildBody() {
    return Padding(padding: const EdgeInsets.all(16.0), child: _buildForm());
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputField(
          label: 'Alasan Cuti',
          controller: _reasonController,
        ),
        const SizedBox(height: 16.0),
        const Text('Jenis Cuti/Izin'),
        const SizedBox(height: 8.0),
        Consumer<LeaveTypeProvider>(
          builder: (context, provLeaveType, _) {
            final selected = provLeaveType.selectedLeaveType;
            return SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: _showModalBottomSheet,
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 8.0),
                  shadowColor: Colors.transparent,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  side: const BorderSide(color: lightGray, width: 1.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selected?.name ?? 'Pilih',
                      style: TextStyle(
                        color: selected == null ? lightGray : Colors.black87,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16.0),
        _buildDatePickerField(
          label: 'Tanggal Mulai',
          controller: _startDateController,
        ),
        const SizedBox(height: 16.0),
        _buildDatePickerField(
          label: 'Tanggal Selesai',
          controller: _endDateController,
        ),
      ],
    );
  }

  Widget _buildInputField(
      {required String label, required TextEditingController controller}) {
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
          child: TextField(
            controller: controller,
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

  Widget _buildDatePickerField(
      {required String label, required TextEditingController controller}) {
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
          child: TextField(
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
    return SafeArea(child: Consumer<LeaveTypeProvider>(
      builder: (context, provLeaveType, _) {
        if (provLeaveType.isLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (provLeaveType.errorMessage != null) {
          return Center(child: Text(provLeaveType.errorMessage!));
        } else {
          final leaveTypes = provLeaveType.leaveTypeList;
          return ListView.builder(
            itemCount: leaveTypes.length,
            itemBuilder: (context, index) {
              final leaveType = leaveTypes[index];
              return ListTile(
                title: Text(leaveType.name),
                onTap: () {
                  provLeaveType.selectLeaveType(leaveType);
                  Navigator.pop(context);
                },
              );
            },
          );
        }
      },
    ));
  }
}
