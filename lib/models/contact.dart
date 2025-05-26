import 'dart:convert';

import 'package:tcm/utils/gender_utils.dart';

class Contact {
  int id;
  String name;
  String? gender; // 性别：男/女
  String? phone; // 手机号
  String? address1; // 地址1
  String? address2; // 地址2

  Contact({
    required this.id,
    required this.name,
    this.gender,
    this.phone,
    this.address1,
    this.address2,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      name: json['name'],
      gender: GenderUtils.englishToChinese(json['gender']), // 将API返回的英文转换为中文显示
      phone: json['phone'],
      address1: json['address1'],
      address2: json['address2'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'phone': phone,
      'address1': address1,
      'address2': address2,
    };
  }

  @override
  String toString() {
    return json.encode(toJson());
  }
}

class ContactPayload {
  String name;
  String? gender;
  String? phone;
  String? address1;
  String? address2;

  ContactPayload({
    required this.name,
    this.gender,
    this.phone,
    this.address1,
    this.address2,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'gender': GenderUtils.chineseToEnglish(gender), // 将中文转换为英文发送给API
      'phone': phone,
      'address1': address1,
      'address2': address2,
    };
  }

  @override
  String toString() {
    return json.encode(toJson());
  }
}
