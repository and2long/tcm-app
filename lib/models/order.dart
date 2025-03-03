import 'dart:convert';

import 'package:tcm/core/blocs/extension.dart';
import 'package:tcm/models/contact.dart';
import 'package:tcm/models/order_line.dart';

class Order {
  int id;
  bool isCompleted;
  bool isVip;
  Contact? contact;
  List<OrderLine> orderLines;
  List<String> images;
  DateTime createdAt;
  String? remark;

  Order({
    required this.id,
    required this.contact,
    required this.images,
    required this.isCompleted,
    required this.isVip,
    required this.createdAt,
    required this.orderLines,
    this.remark,
  });

  factory Order.fromJson(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      isVip: map['is_vip'] ?? false,
      images: (map['images'] as List).map((e) => e.toString()).toList(),
      contact: map['contact'] != null ? Contact.fromJson(map['contact']) : null,
      createdAt: map['created_at'].toString().toDateTime(),
      isCompleted: map['is_completed'],
      orderLines: List<OrderLine>.from(
          map['order_lines'].map((x) => OrderLine.fromJson(x)) ?? []),
      remark: map['remark'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'images': images,
      'contact': contact?.toJson(),
      'is_completed': isCompleted,
      'is_vip': isVip,
      'order_lines': orderLines.map((x) => x.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'remark': remark,
    };
  }

  @override
  String toString() {
    return json.encode(toJson());
  }

  Order copyWith({
    int? id,
    bool? isCompleted,
    bool? isVip,
    Contact? contact,
    List<OrderLine>? orderLines,
    List<String>? images,
    DateTime? createdAt,
    String? remark,
  }) {
    return Order(
      id: id ?? this.id,
      isCompleted: isCompleted ?? this.isCompleted,
      isVip: isVip ?? this.isVip,
      contact: contact ?? this.contact,
      orderLines: orderLines ?? this.orderLines,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      remark: remark ?? this.remark,
    );
  }
}
