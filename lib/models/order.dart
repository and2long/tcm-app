import 'dart:convert';

import 'package:tcm/models/order_line.dart';

class Order {
  String name;
  bool isCompleted;
  List<OrderLine> orderLines;

  Order(
      {required this.name,
      required this.isCompleted,
      required this.orderLines});

  factory Order.fromJson(Map<String, dynamic> map) {
    return Order(
      name: map['name'],
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
    };
  }

  @override
  String toString() {
    return json.encode(toJson());
  }
}
