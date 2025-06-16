import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'customer.dart';
import 'edit_customer_page.dart';

class CustomerDialog extends StatefulWidget {
  final Customer customer;
  final String docId;
  final bool showSetAppointment;
  final bool showBitButton; // Add this

  const CustomerDialog({
    super.key,
    required this.customer,
    required this.docId,
    this.showSetAppointment = true,
    this.showBitButton = false, // default false
  });

  @override
  State<CustomerDialog> createState() => _CustomerDialogState();
}

class _CustomerDialogState extends State<CustomerDialog> {
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = widget.customer.appointmentDate;
  }

  Future<void> _pickDateTime() async {
    // Pick date
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null) return;

    // Pick time in 24-hour format
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedDateTime != null
          ? TimeOfDay(hour: _selectedDateTime!.hour, minute: _selectedDateTime!.minute)
          : TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (pickedTime == null) return;

    final combined = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      _selectedDateTime = combined;
    });

    // Update in Firestore
    await FirebaseFirestore.instance
        .collection('customers')
        .doc(widget.docId)
        .update({'appointmentDate': combined.toIso8601String()});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.customer.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Phone: ${widget.customer.phone}'),
          Text('Email: ${widget.customer.email}'),
          Text('Address: ${widget.customer.address}'),
          Text('Sofa: ${widget.customer.sofa ? "Yes" : "No"}'),
          Text('Air Conditioner: ${widget.customer.airConditioner ? "Yes" : "No"}'),
          Text('Car: ${widget.customer.car ? "Yes" : "No"}'),
          const SizedBox(height: 16),
          Text(
            _selectedDateTime == null
                ? 'No appointment set'
                : 'Appointment: ${DateFormat('yyyy-MM-dd').format(_selectedDateTime!)}  ${DateFormat('HH:mm').format(_selectedDateTime!)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        if (widget.showBitButton)
          ElevatedButton(
            onPressed: () async {
              final phone = widget.customer.phone;
              final url = Uri.parse('sms:$phone?body=${Uri.encodeComponent('Check this out: https://www.google.com/')}');
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Could not launch SMS app')),
                );
              }
            },
            child: const Text('Bit'),
          ),
        const SizedBox(height: 8),
        if (widget.showSetAppointment)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EditCustomerPage(
                            customer: widget.customer,
                            docId: widget.docId,
                          ),
                        ),
                      );
                    },
                    child: const Text('Edit'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('customers')
                          .doc(widget.docId)
                          .delete();
                      Navigator.of(context).pop(true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Customer deleted!')),
                      );
                    },
                    child: const Text('Delete'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
      ],
    );
  }
}