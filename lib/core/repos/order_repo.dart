import 'package:dio/dio.dart';
import 'package:tcm/constants.dart';
import 'package:tcm/core/network/http.dart';

class OrderRepo {
  Future<Response> getOrderList() async {
    return XHttp.instance.get(ConstantsHttp.orders);
  }
}
