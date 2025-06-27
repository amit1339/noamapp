import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'customer_dialog.dart';
import 'customer.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  LatLng _initialCameraPosition = const LatLng(32.0853, 34.7818); // Default: Tel Aviv
  bool _dialogOpen = false; // Add this

  @override
  void initState() {
    super.initState();
    _loadCustomerMarkers();
  }

  Future<void> _loadCustomerMarkers() async {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final customers = await FirebaseFirestore.instance.collection('customers').get();
    for (var doc in customers.docs) {
      final data = doc.data();
      final address = data['address'] ?? '';
      final appointmentTimestamp = data['appointmentDate'];
      if (address.isNotEmpty && appointmentTimestamp != null) {
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
        if (appointmentDay != todayDate) continue;

        try {
          LatLng? latLng = await getLatLngFromAddress(address);
          if (latLng != null) {
            setState(() {
              _markers.add(
                Marker(
                  markerId: MarkerId(doc.id),
                  position: LatLng(latLng.latitude, latLng.longitude),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                  onTap: () async {
                    setState(() {
                      _dialogOpen = true;
                    });
                    final result = await showDialog(
                      context: context,
                      builder: (context) {
                        final customer = Customer.fromJson(data);
                        return CustomerDialog(
                          customer: customer,
                          docId: doc.id,
                        );
                      },
                    );
                    setState(() {
                      _dialogOpen = false;
                    });
                    if (result == true) {
                      // Data was changed, reload markers
                      _markers.clear();
                      await _loadCustomerMarkers();
                    }
                  },
                ),
              );
            });
            // Optionally, move camera to first customer
            if (_markers.length == 1) {
              _initialCameraPosition = LatLng(latLng.latitude, latLng.longitude);
              _mapController?.moveCamera(CameraUpdate.newLatLng(_initialCameraPosition));
            }
          }
        } catch (e) {
          print('Geocoding failed for $address: $e');
        }
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _initialCameraPosition,
        zoom: 10,
      ),
      markers: _markers,
      onMapCreated: (controller) {
        _mapController = controller;
      },
      zoomGesturesEnabled: !_dialogOpen,
      scrollGesturesEnabled: !_dialogOpen,
      rotateGesturesEnabled: !_dialogOpen,
      tiltGesturesEnabled: !_dialogOpen,
      myLocationEnabled: !_dialogOpen,
      myLocationButtonEnabled: !_dialogOpen,
    );
  }
}