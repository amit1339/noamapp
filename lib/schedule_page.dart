import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'customer.dart';
import 'customer_dialog.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Customer>> _appointments = {};
  CalendarFormat _calendarFormat = CalendarFormat.week; // Default to daily view

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    final snapshot = await FirebaseFirestore.instance.collection('customers').get();
    final Map<DateTime, List<Customer>> appointments = {};

    for (var doc in snapshot.docs) {
      final customer = Customer.fromJson(doc.data());
      if (customer.appointmentDate != null) {
        final date = DateTime(
          customer.appointmentDate!.year,
          customer.appointmentDate!.month,
          customer.appointmentDate!.day,
        );
        appointments.putIfAbsent(date, () => []).add(customer);
      }
    }

    setState(() {
      _appointments = appointments;
    });
  }

  List<Customer> _getAppointmentsForDay(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    return _appointments[date] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar<Customer>(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2100, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          eventLoader: _getAppointmentsForDay,
          calendarFormat: _calendarFormat,
          availableCalendarFormats: const {
            CalendarFormat.week: 'Week',
            CalendarFormat.month: 'Month',
          },
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          calendarStyle: const CalendarStyle(
            markerDecoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Builder(
            builder: (context) {
              final appointments = _getAppointmentsForDay(_selectedDay ?? _focusedDay);
              if (appointments.isEmpty) {
                return const Center(child: Text('No appointments for this day.'));
              }
              // Sort appointments by time
              appointments.sort((a, b) {
                if (a.appointmentDate == null) return 1;
                if (b.appointmentDate == null) return -1;
                return a.appointmentDate!.compareTo(b.appointmentDate!);
              });
              return ListView.builder(
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final customer = appointments[index];
                  Color tileColor = Colors.white;
                  if (customer.sofa) {
                    tileColor = Colors.blue.shade100;
                  } else if (customer.airConditioner) {
                    tileColor = Colors.orange.shade100;
                  }
                  return Card(
                    child: Container(
                      decoration: (customer.sofa && customer.airConditioner)
                          ? BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.orange.shade100, Colors.blue.shade100],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                stops: const [0.5, 0.5],
                              ),
                            )
                          : BoxDecoration(
                              color: customer.sofa
                                  ? Colors.blue.shade100
                                  : customer.airConditioner
                                      ? const Color.fromARGB(255, 228, 88, 8)
                                      : Colors.white,
                            ),
                      child: ListTile(
                        title: Text(customer.name),
                        subtitle: Text(
                          'Time: ${customer.appointmentDate != null ? TimeOfDay.fromDateTime(customer.appointmentDate!).format(context) : ''}',
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => CustomerDialog(
                              customer: customer,
                              docId: '',
                              showSetAppointment: false,
                              showBitButton: true, // Show Bit button only here
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}