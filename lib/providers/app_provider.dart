import 'package:flutter/material.dart';
import 'package:tcm/models/contact.dart';
import 'package:tcm/models/product.dart';

class AppProvider extends ChangeNotifier {
  List<Contact> _contacts = [];
  List<Product> _products = [];

  List<Contact> get contacts => _contacts;
  List<Product> get products => _products;

  void setContacts(List<Contact> contacts) {
    _contacts = contacts;
    notifyListeners();
  }

  void setProducts(List<Product> products) {
    _products = products;
    notifyListeners();
  }

  void addContact(Contact contact) {
    _contacts.add(contact);
    _contacts.sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }

  void removeContact(int id) {
    _contacts.removeWhere((contact) => contact.id == id);
    notifyListeners();
  }

  void updateContact(Contact contact) {
    final index = _contacts.indexWhere((c) => c.id == contact.id);
    if (index != -1) {
      _contacts[index] = contact;
      _contacts.sort((a, b) => a.name.compareTo(b.name));
      notifyListeners();
    }
  }

  void addProduct(Product product) {
    _products.add(product);
    _products.sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }

  void removeProduct(int id) {
    _products.removeWhere((product) => product.id == id);
    notifyListeners();
  }

  void updateProduct(Product product) {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      _products.sort((a, b) => a.name.compareTo(b.name));
      notifyListeners();
    }
  }
}
