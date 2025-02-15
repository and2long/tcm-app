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
    List<String>? images,
  }) async {
    return XHttp.instance.post(
      ConstantsHttp.orders,
      data: {
        'contact_id': contactId,
        'order_lines': items,
        'images': images ?? [],
      },
    );
  }

  Future<Response> getOrderDetail(int id) async {
    return XHttp.instance.get('${ConstantsHttp.orders}/$id');
  }

  Future<Response> deleteOrder(int id) async {
    return XHttp.instance.delete('${ConstantsHttp.orders}/$id');
  }

  Future<Response> updateOrder({
    required int id,
    required int contactId,
    required List<Map<String, int>> items,
    List<String>? images,
  }) async {
    return XHttp.instance.patch(
      '${ConstantsHttp.orders}/$id',
      data: {
        'contact_id': contactId,
        'order_lines': items,
        'images': images ?? [],
      },
    );
  }

  Future<Response> getPendingOrders() async {
    return XHttp.instance.get(ConstantsHttp.pendingOrders);
  }

  Future<Response> completeOrder(int id) async {
    return XHttp.instance
        .patch('${ConstantsHttp.orders}/$id', data: {'is_completed': true});
  }

  Future<Response> updateOrderStatus(int id, bool isCompleted) async {
    return XHttp.instance.patch(
      '${ConstantsHttp.orders}/$id',
      data: {'is_completed': isCompleted},
    );
  }
}
