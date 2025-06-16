import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'customer.dart';

class EditCustomerPage extends StatefulWidget {
  final Customer customer;
  final String docId;

  const EditCustomerPage({super.key, required this.customer, required this.docId});

  @override
  State<EditCustomerPage> createState() => _EditCustomerPageState();
}

class _EditCustomerPageState extends State<EditCustomerPage> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  bool _sofa = false;
  bool _airConditioner = false;
  bool _car = false;
  DateTime? _appointmentDate;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer.name);
    _phoneController = TextEditingController(text: widget.customer.phone);
    _emailController = TextEditingController(text: widget.customer.email);
    _addressController = TextEditingController(text: widget.customer.address);
    _sofa = widget.customer.sofa;
    _airConditioner = widget.customer.airConditioner;
    _car = widget.customer.car;
    _appointmentDate = widget.customer.appointmentDate;
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
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value == null || value.isEmpty ? 'Email is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Address is required' : null,
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
              CheckboxListTile(
                title: const Text('Car'),
                value: _car,
                onChanged: (bool? value) {
                  setState(() {
                    _car = value ?? false;
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
                      'email': _emailController.text,
                      'address': _addressController.text,
                      'sofa': _sofa,
                      'airConditioner': _airConditioner,
                      'car': _car,
                      'appointmentDate': _appointmentDate?.toIso8601String(),
                    });
                    Navigator.of(context).pop(true); // Return true to indicate change
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