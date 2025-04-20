class Address {
  final String id;
  final String title; // <--- Add this
  final String addressLine;
  final String city;
  final String pincode;

  Address({
    required this.id,
    required this.title,
    required this.addressLine,
    required this.city,
    required this.pincode,
  });

  factory Address.fromMap(Map<String, dynamic> data, String documentId) {
    return Address(
      id: documentId,
      title: data['title'] ?? '', // <--- Make sure it's in your Firestore too
      addressLine: data['addressLine'] ?? '',
      city: data['city'] ?? '',
      pincode: data['pincode'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'addressLine': addressLine,
      'city': city,
      'pincode': pincode,
    };
  }
}
