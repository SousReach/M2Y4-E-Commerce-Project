class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final Address address;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    Address? address,
  }) : address = address ?? Address();

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] != null
          ? Address.fromJson(json['address'])
          : Address(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address.toJson(),
    };
  }
}

class Address {
  final String street;
  final String city;
  final String country;

  Address({this.street = '', this.city = '', this.country = ''});

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'street': street, 'city': city, 'country': country};
  }
}
