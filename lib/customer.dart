class Customer {
  String name;
  String phone;
  String address;
  bool sofa;
  bool airConditioner;
  DateTime? appointmentDate;
  String? remark;

  Customer({
    required this.name,
    required this.phone,
    required this.address,
    required this.sofa,
    required this.airConditioner,
    this.appointmentDate,
    this.remark
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'sofa': sofa,
      'airConditioner': airConditioner,
      'appointmentDate': appointmentDate?.toIso8601String(),
      'remark': remark,
    };
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      sofa: json['sofa'] ?? false,
      airConditioner: json['airConditioner'] ?? false,
      appointmentDate: json['appointmentDate'] != null
          ? DateTime.tryParse(json['appointmentDate'])
          : null,
      remark: json['remark'],
    );
  }
}