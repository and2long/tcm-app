import 'package:dio/dio.dart';
import 'package:tcm/constants.dart';
import 'package:tcm/core/network/http.dart';

class ProductRepo {
  Future<Response> getProductList() async {
    return XHttp.instance.get(ConstantsHttp.products);
  }

  Future<Response> createProduct(String name) async {
    return XHttp.instance.post(ConstantsHttp.products, data: {'name': name});
  }

  Future<Response> deleteProduct(int id) async {
    return XHttp.instance.delete('${ConstantsHttp.products}/$id');
  }
}
