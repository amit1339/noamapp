import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'customer.dart';
import 'translations.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomerForm();
  }
}

class CustomerForm extends StatefulWidget {
  final Customer? customer;
  final String? docId;
  final VoidCallback? onCustomerChanged;

  const CustomerForm({
    super.key,
    this.customer,
    this.docId,
    this.onCustomerChanged,
  });

  @override
  State<CustomerForm> createState() => _CustomerFormState();
}

class _CustomerFormState extends State<CustomerForm> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _remarkController;

  final _formKey = GlobalKey<FormState>();

  bool _sofa = false;
  bool _airConditioner = false;
  DateTime? _appointmentDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer?.name ?? '');
    _phoneController = TextEditingController(text: widget.customer?.phone ?? '');
    _addressController = TextEditingController(text: widget.customer?.address ?? '');
    _remarkController = TextEditingController(text: widget.customer?.remark ?? '');
    _sofa = widget.customer?.sofa ?? false;
    _airConditioner = widget.customer?.airConditioner ?? false;
    _appointmentDate = widget.customer?.appointmentDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  Future<void> _saveCustomer() async {
    if (_formKey.currentState!.validate()) {
      final customer = Customer(
        name: _nameController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        sofa: _sofa,
        airConditioner: _airConditioner,
        appointmentDate: _appointmentDate,
        remark: _remarkController.text.isNotEmpty ? _remarkController.text : null,
      );
      if (widget.customer == null) {
        // Add new customer
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
          _appointmentDate = null;
        });
      } else {
        // Update existing customer
        await FirebaseFirestore.instance
            .collection('customers')
            .doc(widget.docId)
            .update(customer.toJson());
        if (widget.onCustomerChanged != null) {
          widget.onCustomerChanged!();
        }
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Customer updated!')),
        );
      }
    }
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
                border: const OutlineInputBorder(),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? '${Translations.text('name')} ${Translations.text('is required')}' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: Translations.text('phone'),
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) =>
                  value == null || value.isEmpty ? '${Translations.text('phone')} ${Translations.text('is required')}' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: Translations.text('address'),
                border: const OutlineInputBorder(),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? '${Translations.text('addres')} ${Translations.text('is required')}' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _remarkController,
              decoration: InputDecoration(
                labelText: Translations.text('remark'),
                border: const OutlineInputBorder(),
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
                    : '${Translations.text('appointment')}: ${DateFormat('yyyy-MM-dd HH:mm').format(_appointmentDate!)}',
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
              onPressed: _saveCustomer,
              child: Text(widget.customer == null
                  ? Translations.text('add_customer')
                  : Translations.text('save')),
            ),
          ],
        ),
      ),
    );
  }
}