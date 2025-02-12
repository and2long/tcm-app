import 'package:tcm/models/product.dart';

abstract class ProductState {}

class ProductInitialState extends ProductState {}

class ProductDeleteSuccessState extends ProductState {
  final int id;
  ProductDeleteSuccessState(this.id);
}

class ProductListSuccessState extends ProductState {
  final List<Product> products;
  ProductListSuccessState(this.products);
}

class ProductCreateSuccessState extends ProductState {
  final Product product;
  ProductCreateSuccessState(this.product);
}
