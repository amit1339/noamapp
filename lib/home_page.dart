import 'package:flutter/material.dart';

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
            onPressed: () {
              // Add your logic to handle adding a customer here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Customer added!')),
              );
            },
            child: const Text('Add Customer'),
          ),
        ],
      ),
    );
  }
}