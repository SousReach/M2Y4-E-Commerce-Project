class SavedAddress {
  final String id;
  final String label;
  final String street;
  final String city;
  final String country;
  final String phone;
  final bool isDefault;

  SavedAddress({
    required this.id,
    required this.label,
    required this.street,
    required this.city,
    required this.country,
    this.phone = '',
    this.isDefault = false,
  });

  factory SavedAddress.fromJson(Map<String, dynamic> json) {
    return SavedAddress(
      id: json['_id'] ?? '',
      label: json['label'] ?? 'Home',
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      phone: json['phone'] ?? '',
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'street': street,
      'city': city,
      'country': country,
      'phone': phone,
      'isDefault': isDefault,
    };
  }
}
