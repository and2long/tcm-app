import 'dart:convert';

import 'package:tcm/core/blocs/extension.dart';
import 'package:tcm/models/contact.dart';
import 'package:tcm/models/order_line.dart';

class Order {
  int id;
  bool isCompleted;
  Contact? contact;
  List<OrderLine> orderLines;
  List<String> images;
  DateTime createdAt;

  Order({
    required this.id,
    required this.contact,
    required this.images,
    required this.isCompleted,
    required this.createdAt,
    required this.orderLines,
  });

  factory Order.fromJson(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      images: (map['images'] as List).map((e) => e.toString()).toList(),
      contact: map['contact'] != null ? Contact.fromJson(map['contact']) : null,
      createdAt: map['created_at'].toString().toDateTime(),
      isCompleted: map['is_completed'],
      orderLines: List<OrderLine>.from(
          map['order_lines'].map((x) => OrderLine.fromJson(x)) ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'images': images,
      'contact': contact?.toJson(),
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
