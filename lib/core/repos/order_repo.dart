import 'package:dio/dio.dart';
import 'package:tcm/constants.dart';
import 'package:tcm/core/network/http.dart';

class OrderRepo {
  Future<Response> getOrderList() async {
    return XHttp.instance.get(ConstantsHttp.orders);
  }

  Future<Response> createOrder({
    required int contactId,
    required List<Map<String, int>> items,
  }) async {
    return XHttp.instance.post(
      ConstantsHttp.orders,
      data: {
        'contact_id': contactId,
        'order_lines': items,
      },
    );
  }
}
