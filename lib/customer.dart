class Customer {
  String name;
  String phone;
  String email;
  String address;
  bool sofa;
  bool airConditioner;
  bool car;
  DateTime? appointmentDate;

  Customer({
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.sofa,
    required this.airConditioner,
    required this.car,
    this.appointmentDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'sofa': sofa,
      'airConditioner': airConditioner,
      'car': car,
      'appointmentDate': appointmentDate?.toIso8601String(),
    };
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      sofa: json['sofa'] ?? false,
      airConditioner: json['airConditioner'] ?? false,
      car: json['car'] ?? false,
      appointmentDate: json['appointmentDate'] != null
          ? DateTime.tryParse(json['appointmentDate'])
          : null,
    );
  }
}