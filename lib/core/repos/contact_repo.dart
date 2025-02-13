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

  Future<Response> deleteContact(int id) async {
    return XHttp.instance.delete('${ConstantsHttp.contacts}/$id');
  }

  Future<Response> updateContact(int id, String name) async {
    return XHttp.instance
        .patch('${ConstantsHttp.contacts}/$id', data: {'name': name});
  }
}
