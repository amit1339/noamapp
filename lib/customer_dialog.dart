import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'customer.dart';
import 'home_page.dart'; // <-- Use the unified form

class CustomerDialog extends StatefulWidget {
  final Customer customer;
  final String docId;
  final bool showSetAppointment;
  final bool showBitButton;
  final VoidCallback? onCustomerChanged;

  const CustomerDialog({
    super.key,
    required this.customer,
    required this.docId,
    this.showSetAppointment = true,
    this.showBitButton = false,
    this.onCustomerChanged,
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.customer.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Phone: ${widget.customer.phone}'),
          Text('Address: ${widget.customer.address}'),
          Text('Sofa: ${widget.customer.sofa ? "Yes" : "No"}'),
          Text('Air Conditioner: ${widget.customer.airConditioner ? "Yes" : "No"}'),
          if (widget.customer.remark != null && widget.customer.remark!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text('Remark: ${widget.customer.remark!}'),
            ),
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
                          builder: (context) => Scaffold(
                            appBar: AppBar(title: const Text('Edit Customer')),
                            body: CustomerForm(
                              customer: widget.customer,
                              docId: widget.docId,
                              onCustomerChanged: widget.onCustomerChanged,
                            ),
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
                      if (widget.onCustomerChanged != null) {
                        widget.onCustomerChanged!();
                      }
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