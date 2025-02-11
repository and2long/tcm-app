import 'package:dio/dio.dart';
import 'package:tcm/constants.dart';
import 'package:tcm/core/network/http.dart';

class ContactRepo {
  Future<Response> getContactList() async {
    return XHttp.instance.get(ConstantsHttp.contacts);
  }

  Future<Response> createContact(String name) async {
    return XHttp.instance.post(ConstantsHttp.contacts, data: {'name': name});
  }
}
