import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // For LatLng
import 'customer.dart';
import 'translations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Add this helper function to calculate distance between two coordinates (Haversine formula)
double calculateDistanceKm(LatLng a, LatLng b) {
  const earthRadius = 6371.0;
  final dLat = (b.latitude - a.latitude) * pi / 180.0;
  final dLon = (b.longitude - a.longitude) * pi / 180.0;
  final lat1 = a.latitude * pi / 180.0;
  final lat2 = b.latitude * pi / 180.0;

  final aVal = sin(dLat / 2) * sin(dLat / 2) +
      sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2);
  final c = 2 * atan2(sqrt(aVal), sqrt(1 - aVal));
  return earthRadius * c;
}

  Future<LatLng?> getLatLngFromAddress(String address) async {
    final apiKey = 'AIzaSyA2vg_g5qn1LccjhkjAtLFoF_E9uNo07T8'; // <-- your API key
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$apiKey',
    );
    final response = await http.get(url);
    final data = json.decode(response.body);
    if (data['status'] == 'OK') {
      final location = data['results'][0]['geometry']['location'];
      return LatLng(location['lat'], location['lng']);
    }
    return null;
  }

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

  String _proximityResult = '';
  bool _isCheckingProximity = false;

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
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: Translations.text('address'),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? '${Translations.text('addres')} ${Translations.text('is required')}' : null,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isCheckingProximity
                      ? null
                      : () async {
                          final address = _addressController.text.trim();
                          if (address.isEmpty) {
                            setState(() {
                              _proximityResult = '';
                            });
                            return;
                          }
                          setState(() {
                            _isCheckingProximity = true;
                            _proximityResult = '';
                          });

                          final LatLng? userLatLng = await getLatLngFromAddress(address);
                          if (userLatLng == null) {
                            setState(() {
                              _proximityResult = Translations.text('address_not_found');
                              _isCheckingProximity = false;
                            });
                            return;
                          }

                          final now = DateTime.now();
                          final todayDate = DateTime(now.year, now.month, now.day);
                          final tomorrow = todayDate.add(const Duration(days: 1));
                          final lastDay = todayDate.add(const Duration(days: 7));
                          DateTime? foundDate;

                          final customers = await FirebaseFirestore.instance.collection('customers').get();
                          for (var doc in customers.docs) {
                            final data = doc.data();
                            final otherAddress = data['address'] ?? '';
                            final appointmentTimestamp = data['appointmentDate'];
                            if (otherAddress.isEmpty || appointmentTimestamp == null) continue;

                            DateTime appointmentDate;
                            if (appointmentTimestamp is Timestamp) {
                              appointmentDate = appointmentTimestamp.toDate();
                            } else if (appointmentTimestamp is DateTime) {
                              appointmentDate = appointmentTimestamp;
                            } else if (appointmentTimestamp is String) {
                              try {
                                appointmentDate = DateTime.parse(appointmentTimestamp);
                              } catch (e) {
                                continue;
                              }
                            } else {
                              continue;
                            }
                            final appointmentDay = DateTime(appointmentDate.year, appointmentDate.month, appointmentDate.day);

                            // Only check for next 7 days (including tomorrow and up to 7 days ahead)
                            if (appointmentDay.isBefore(tomorrow) || appointmentDay.isAfter(lastDay)) continue;

                            final LatLng? otherLatLng = await getLatLngFromAddress(otherAddress);
                            if (otherLatLng == null) continue;

                            final distance = calculateDistanceKm(userLatLng, otherLatLng);
                            if (distance <= 20) {
                              foundDate = appointmentDay;
                              break;
                            }
                          }

                          setState(() {
                            if (foundDate != null) {
                              _proximityResult = DateFormat('yyyy-MM-dd').format(foundDate);
                            } else {
                              _proximityResult = Translations.text('available');
                            }
                            _isCheckingProximity = false;
                          });
                        },
                  child: Text(Translations.text('submit')),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: Translations.text('Nearby Appointment'),
                border: const OutlineInputBorder(),
              ),
              controller: TextEditingController(text: _proximityResult),
            ),
            const SizedBox(height: 20),
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