import 'package:tcm/models/product.dart';

abstract class ProductState {}

class ProductInitialState extends ProductState {}

class ProductListSuccessState extends ProductState {
  final List<Product> products;
  ProductListSuccessState(this.products);
}
