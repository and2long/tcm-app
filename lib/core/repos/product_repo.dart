import 'package:dio/dio.dart';
import 'package:tcm/constants.dart';
import 'package:tcm/core/network/http.dart';

class ProductRepo {
  Future<Response> getProductList() async {
    return XHttp.instance.get(ConstantsHttp.products);
  }
}
