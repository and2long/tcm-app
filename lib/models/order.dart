import 'dart:convert';

import 'package:tcm/models/contact.dart';
import 'package:tcm/models/order_line.dart';

class Order {
  String name;
  bool isCompleted;
  Contact? contact;
  List<OrderLine> orderLines;
  DateTime createdAt;

  Order({
    required this.name,
    required this.contact,
    required this.isCompleted,
    required this.createdAt,
    required this.orderLines,
  });

  factory Order.fromJson(Map<String, dynamic> map) {
    return Order(
      name: map['name'],
      contact: map['contact'] != null ? Contact.fromJson(map['contact']) : null,
      createdAt: DateTime.parse(map['created_at']),
      isCompleted: map['is_completed'],
      orderLines: List<OrderLine>.from(
          map['order_lines'].map((x) => OrderLine.fromJson(x)) ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'is_completed': isCompleted,
      'order_lines': orderLines.map((x) => x.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return json.encode(toJson());
  }
}
