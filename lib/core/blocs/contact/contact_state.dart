import 'package:tcm/models/contact.dart';

abstract class ContactState {}

class ContactInitialState extends ContactState {}

class ContactListSuccessState extends ContactState {
  final List<Contact> contacts;
  ContactListSuccessState(this.contacts);
}

class ContactCreateSuccessState extends ContactState {
  final Contact contact;
  ContactCreateSuccessState(this.contact);
}
