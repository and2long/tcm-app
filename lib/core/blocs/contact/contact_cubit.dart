import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:tcm/core/blocs/contact/contact_state.dart';
import 'package:tcm/core/blocs/extension.dart';
import 'package:tcm/core/blocs/handle_error.dart';
import 'package:tcm/core/repos/contact_repo.dart';
import 'package:tcm/models/contact.dart';

class ContactCubit extends Cubit<ContactState> {
  final ContactRepo _repo;

  ContactCubit(ContactRepo repo)
      : _repo = repo,
        super(ContactInitialState());

  Future<List<Contact>?> getContactList() async {
    try {
      SmartDialog.showLoading();
      Response res = await _repo.getContactList();
      List<Contact> contacts =
          (res.data as List).map((e) => Contact.fromJson(e)).toList();
      maybeEmit(ContactListSuccessState(contacts));
      return contacts;
    } catch (e, s) {
      handleError(e, stackTrace: s);
      return null;
    } finally {
      SmartDialog.dismiss();
    }
  }

  /// 获取联系人列表，无等待框
  Future<List<Contact>?> list() async {
    try {
      Response res = await _repo.getContactList();
      List<Contact> contacts =
          (res.data as List).map((e) => Contact.fromJson(e)).toList();
      return contacts;
    } catch (e, s) {
      handleError(e, stackTrace: s);
      return null;
    }
  }

  Future createContact(String name) async {
    try {
      SmartDialog.showLoading();
      Response res = await _repo.createContact(name);
      Contact contact = Contact.fromJson(res.data);
      maybeEmit(ContactCreateSuccessState(contact));
    } catch (e, s) {
      handleError(e, stackTrace: s);
    } finally {
      SmartDialog.dismiss();
    }
  }

  Future deleteContact(int id) async {
    try {
      SmartDialog.showLoading();
      await _repo.deleteContact(id);
      maybeEmit(ContactDeleteScuuessState(id));
    } catch (e, s) {
      handleError(e, stackTrace: s);
    } finally {
      SmartDialog.dismiss();
    }
  }

  Future updateContact(int id, String name) async {
    try {
      SmartDialog.showLoading();
      Response res = await _repo.updateContact(id, name);
      Contact contact = Contact.fromJson(res.data);
      maybeEmit(ContactUpdateSuccessState(contact));
    } catch (e, s) {
      handleError(e, stackTrace: s);
    } finally {
      SmartDialog.dismiss();
    }
  }
}
