import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'customer.dart';
import 'customer_dialog.dart';
import 'translations.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Customer> _futureCustomers = [];
  List<Customer> _archiveCustomers = [];
  Map<String, String> _customerDocIds = {}; 
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchCustomers();
  }

  Future<void> _fetchCustomers() async {
    setState(() => _loading = true);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final snapshot = await FirebaseFirestore.instance.collection('customers').get();
    List<Customer> future = [];
    List<Customer> archive = [];
    Map<String, String> docIds = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      DateTime? appointmentDate;
      final appointmentTimestamp = data['appointmentDate'];
      if (appointmentTimestamp == null) continue;
      if (appointmentTimestamp is Timestamp) {
        appointmentDate = appointmentTimestamp.toDate();
      } else if (appointmentTimestamp is DateTime) {
        appointmentDate = appointmentTimestamp;
      } else if (appointmentTimestamp is String) {
        try {
          appointmentDate = DateTime.parse(appointmentTimestamp);
        } catch (_) {
          continue;
        }
      }
      if (appointmentDate == null) continue;

      final customer = Customer.fromJson(data);
      docIds[customer.name] = doc.id; 

      final appointmentDay = DateTime(appointmentDate.year, appointmentDate.month, appointmentDate.day);
      if (appointmentDay.isBefore(today)) {
        archive.add(customer);
      } else {
        future.add(customer);
      }
    }

    archive.sort((a, b) => b.appointmentDate!.compareTo(a.appointmentDate!));
    if (archive.length > 200) {
      archive = archive.take(200).toList();
    }
    future.sort((a, b) => a.appointmentDate!.compareTo(b.appointmentDate!));

    setState(() {
      _futureCustomers = future;
      _archiveCustomers = archive;
      _customerDocIds = docIds;
      _loading = false;
    });
  }

  Widget _buildCustomerList(List<Customer> customers) {
    if (customers.isEmpty) {
      return Center(child: Text(Translations.text('no_customers')));
    }
    return ListView.builder(
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index];
        final docId = _customerDocIds[customer.name] ?? '';
        return ListTile(
          title: Text(customer.name),
          subtitle: Text('${Translations.text('date')}: ${customer.appointmentDate}'),
          onTap: () async {
            final result = await showDialog(
              context: context,
              builder: (context) => CustomerDialog(
                customer: customer,
                docId: docId,
                showSetAppointment: true,
                showBitButton: false,
                onCustomerChanged: () {
                  _fetchCustomers(); // Reload customers when changed
                },
              ),
            );
            if (result == true) {
              // Data was changed, reload customers
              _fetchCustomers();
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.text('customers')),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: Translations.text('future_customers')),
            Tab(text: Translations.text('archive')),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCustomerList(_futureCustomers),
                _buildCustomerList(_archiveCustomers),
              ],
            ),
    );
  }
}