import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'customer.dart';
import 'home_page.dart';
import 'translations.dart';

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
          Text('${Translations.text('phone')}: ${widget.customer.phone}'),
          Text('${Translations.text('address')}: ${widget.customer.address}'),
          Text('${Translations.text('sofa')}: ${widget.customer.sofa ? Translations.text('yes') : Translations.text('no')}'),
          Text('${Translations.text('air_conditioner')}: ${widget.customer.airConditioner ? Translations.text('yes') : Translations.text('no')}'),
          if (widget.customer.remark != null && widget.customer.remark!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text('${Translations.text('remark')}: ${widget.customer.remark!}'),
            ),
          const SizedBox(height: 16),
          Text(
            _selectedDateTime == null
                ? Translations.text('no_appointment')
                : '${Translations.text('appointment')}: ${DateFormat('yyyy-MM-dd').format(_selectedDateTime!)}  ${DateFormat('HH:mm').format(_selectedDateTime!)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        if (widget.showBitButton)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final phone = widget.customer.phone;
                  final message = '${Translations.text('payment_in_bit')}:\nhttps://www.bitpay.co.il/app/me/6E31EE93-B3D8-9650-99EC-F4641AC5DA0A7797';
                  final url = Uri.parse('sms:$phone?body=${Uri.encodeComponent(message)}');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(Translations.text('Could_not_launch_SMS_app'))),
                    );
                  }
                },
                child: const Text('Bit'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  final phone = widget.customer.phone;
                  final dateTimeStr = _selectedDateTime != null
                      ? '${DateFormat('yyyy-MM-dd').format(_selectedDateTime!)} ${DateFormat('HH:mm').format(_selectedDateTime!)}'
                      : '';
                  final List<String> services = [];
                  if (widget.customer.sofa) services.add(Translations.text('sofa'));
                  if (widget.customer.airConditioner) services.add(Translations.text('air_conditioner'));
                  final message =
                      '${Translations.text('reminder_message')} $dateTimeStr. ${Translations.text('services_included')}: ${services.join(', ')}.';

                  final url = Uri.parse('sms:$phone?body=${Uri.encodeComponent(message)}');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(Translations.text('Could_not_launch_SMS_app'))),
                    );
                  }
                },
                child: Text(Translations.text('send_reminders')),
              ),
            ],
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
                            appBar: AppBar(title: Text(Translations.text('edit_customer'))),
                            body: CustomerForm(
                              customer: widget.customer,
                              docId: widget.docId,
                              onCustomerChanged: widget.onCustomerChanged,
                            ),
                          ),
                        ),
                      );
                    },
                    child: Text(Translations.text('edit')),
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
                        SnackBar(content: Text(Translations.text('customer_deleted'))),
                      );
                    },
                    child: Text(Translations.text('delete')),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(Translations.text('close')),
                ),
              ),
            ],
          ),
      ],
    );
  }
}