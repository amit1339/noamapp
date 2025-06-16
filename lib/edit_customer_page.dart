import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'customer.dart';

class EditCustomerPage extends StatefulWidget {
  final Customer customer;
  final String docId;
  final VoidCallback? onCustomerChanged; // <-- Add this line

  const EditCustomerPage({
    super.key,
    required this.customer,
    required this.docId,
    this.onCustomerChanged, // <-- Add this line
  });

  @override
  State<EditCustomerPage> createState() => _EditCustomerPageState();
}

class _EditCustomerPageState extends State<EditCustomerPage> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _remarkController; // <-- Add this line
  bool _sofa = false;
  bool _airConditioner = false;
  DateTime? _appointmentDate;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer.name);
    _phoneController = TextEditingController(text: widget.customer.phone);
    _addressController = TextEditingController(text: widget.customer.address);
    _remarkController = TextEditingController(text: widget.customer.remark ?? ''); // <-- Add this line
    _sofa = widget.customer.sofa;
    _airConditioner = widget.customer.airConditioner;
    _appointmentDate = widget.customer.appointmentDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _remarkController.dispose(); // <-- Add this line
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Customer')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty ? 'Phone number is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Address is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _remarkController,
                decoration: const InputDecoration(labelText: 'Remark', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              CheckboxListTile(
                title: const Text('Sofa'),
                value: _sofa,
                onChanged: (bool? value) {
                  setState(() {
                    _sofa = value ?? false;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Air Conditioner'),
                value: _airConditioner,
                onChanged: (bool? value) {
                  setState(() {
                    _airConditioner = value ?? false;
                  });
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(
                  _appointmentDate == null
                      ? 'Select Appointment Date & Time'
                      : 'Appointment: ${_appointmentDate!.toLocal()}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _appointmentDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate == null) return;
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_appointmentDate ?? DateTime.now()),
                    builder: (context, child) {
                      return MediaQuery(
                        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                        child: child!,
                      );
                    },
                  );
                  if (pickedTime == null) return;
                  setState(() {
                    _appointmentDate = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await FirebaseFirestore.instance
                        .collection('customers')
                        .doc(widget.docId)
                        .update({
                      'name': _nameController.text,
                      'phone': _phoneController.text,
                      'address': _addressController.text,
                      'sofa': _sofa,
                      'airConditioner': _airConditioner,
                      'appointmentDate': _appointmentDate?.toIso8601String(),
                      'remark': _remarkController.text, // <-- Add this line
                    });
                    if (widget.onCustomerChanged != null) {
                      widget.onCustomerChanged!(); // Call the callback
                    }
                    Navigator.of(context).pop(true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Customer updated!')),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}