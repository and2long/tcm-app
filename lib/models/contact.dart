import 'dart:convert';

class Contact {
  int id;
  String name;

  Contact({required this.id, required this.name});

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  String toString() {
    return json.encode(toJson());
  }
}
