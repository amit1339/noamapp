import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'customer.dart'; // Import the Customer class

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _sofa = false;
  bool _airConditioner = false;
  bool _car = false;
  DateTime? _appointmentDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Address',
              border: OutlineInputBorder(),
            ),
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
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              // Use the Customer class
              final customer = Customer(
                name: _nameController.text,
                phone: _phoneController.text,
                email: _emailController.text,
                address: _addressController.text,
                sofa: _sofa,
                airConditioner: _airConditioner,
                car: _car,
                appointmentDate: _appointmentDate,
              );

              await FirebaseFirestore.instance
                  .collection('customers')
                  .add(customer.toJson());

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Customer added!')),
              );

              _nameController.clear();
              _phoneController.clear();
              _emailController.clear();
              _addressController.clear();
              setState(() {
                _sofa = false;
                _airConditioner = false;
                _car = false;
                _appointmentDate = null;
              });
            },
            child: const Text('Add Customer'),
          ),
        ],
      ),
    );
  }
}