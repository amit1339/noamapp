import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import intl package for DateFormat
import 'customer.dart'; // Import the Customer class
import 'translations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _sofa = false;
  bool _airConditioner = false;
  bool _car = false;
  DateTime? _appointmentDate;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: Translations.text('name'),
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: Translations.text('phone'),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) =>
                  value == null || value.isEmpty ? 'Phone number is required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: Translations.text('address'),
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Address is required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _remarkController,
              decoration: InputDecoration(
                labelText: Translations.text('remark'),
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            CheckboxListTile(
              title: Text(Translations.text('sofa')),
              value: _sofa,
              onChanged: (bool? value) {
                setState(() {
                  _sofa = value ?? false;
                });
              },
            ),
            CheckboxListTile(
              title: Text(Translations.text('air_conditioner')),
              value: _airConditioner,
              onChanged: (bool? value) {
                setState(() {
                  _airConditioner = value ?? false;
                });
              },
            ),
            const SizedBox(height: 20),
            ListTile(
              title: Text(
                _appointmentDate == null
                    ? (Translations.text('Select_Appointment_Date&Time'))
                    : 'Appointment: ${DateFormat('yyyy-MM-dd HH:mm').format(_appointmentDate!)}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                // Pick date
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _appointmentDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (pickedDate == null) return;

                // Pick time
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
                  // All fields are valid, proceed to add customer
                  final customer = Customer(
                    name: _nameController.text,
                    phone: _phoneController.text,
                    address: _addressController.text,
                    sofa: _sofa,
                    airConditioner: _airConditioner,
                    appointmentDate: _appointmentDate,
                    remark: _remarkController.text.isNotEmpty ? _remarkController.text : null,
                  );
                  await FirebaseFirestore.instance
                      .collection('customers')
                      .add(customer.toJson());

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Customer added!')),
                  );

                  _nameController.clear();
                  _phoneController.clear();
                  _addressController.clear();
                  _remarkController.clear();
                  setState(() {
                    _sofa = false;
                    _airConditioner = false;
                    _car = false;
                    _appointmentDate = null;
                  });
                }
              },
              child: Text(Translations.text('add_customer')),
            ),
          ],
        ),
      ),
    );
  }
}