import 'dart:convert';

import 'package:tcm/models/product.dart';

class OrderLine {
  int id;

  Product product;

  int quantity;

  OrderLine({
    required this.id,
    required this.product,
    required this.quantity,
  });

  factory OrderLine.fromJson(Map<String, dynamic> json) {
    return OrderLine(
      id: json['id'],
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'quantity': quantity,
    };
  }

  @override
  String toString() {
    return json.encode(toJson());
  }
}
