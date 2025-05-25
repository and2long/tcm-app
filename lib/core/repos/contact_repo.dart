import 'package:dio/dio.dart';
import 'package:tcm/constants.dart';
import 'package:tcm/core/network/http.dart';
import 'package:tcm/models/contact.dart';

class ContactRepo {
  Future<Response> getContactList() async {
    return XHttp.instance.get(ConstantsHttp.contacts);
  }

  Future<Response> createContact(ContactPayload payload) async {
    return XHttp.instance.post(ConstantsHttp.contacts, data: payload.toJson());
  }

  Future<Response> deleteContact(int id) async {
    return XHttp.instance.delete('${ConstantsHttp.contacts}/$id');
  }

  Future<Response> updateContact(int id, ContactPayload payload) async {
    return XHttp.instance
        .patch('${ConstantsHttp.contacts}/$id', data: payload.toJson());
  }
}
