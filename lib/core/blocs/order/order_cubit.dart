import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:tcm/core/blocs/extension.dart';
import 'package:tcm/core/blocs/handle_error.dart';
import 'package:tcm/core/blocs/order/order_state.dart';
import 'package:tcm/core/repos/order_repo.dart';
import 'package:tcm/models/order.dart';

class OrderCubit extends Cubit<OrderState> {
  final OrderRepo _repo;

  OrderCubit(OrderRepo repo)
      : _repo = repo,
        super(OrderInitialState());

  Future getOrderList({int? page, String? month, String? keyword}) async {
    try {
      maybeEmit(OrderListLoadingState());
      Response res =
          await _repo.getOrderList(page: page, month: month, keyword: keyword);
      List<Order> orders =
          (res.data as List).map((e) => Order.fromJson(e)).toList();
      maybeEmit(OrderListSuccessState(orders));
    } catch (e, s) {
      handleError(e, stackTrace: s);
    } finally {
      maybeEmit(OrderListLoadFinishState());
    }
  }

  Future createOrder({
    required int contactId,
    required List<Map<String, int>> items,
    required List<String>? images,
    bool isVip = false,
    String? remark,
  }) async {
    try {
      SmartDialog.showLoading();
      Response res = await _repo.createOrder(
        contactId: contactId,
        items: items,
        images: images,
        isVip: isVip,
        remark: remark,
      );
      Order order = Order.fromJson(res.data);
      maybeEmit(OrderCreateSuccessState(order));
    } catch (e, s) {
      handleError(e, stackTrace: s);
    } finally {
      SmartDialog.dismiss();
    }
  }

  Future getOrderDetail(int id) async {
    try {
      SmartDialog.showLoading();
      Response res = await _repo.getOrderDetail(id);
      Order order = Order.fromJson(res.data);
      maybeEmit(OrderDetailSuccessState(order));
    } catch (e, s) {
      handleError(e, stackTrace: s);
    } finally {
      SmartDialog.dismiss();
    }
  }

  Future deleteOrder(int id) async {
    try {
      SmartDialog.showLoading();
      await _repo.deleteOrder(id);
      maybeEmit(OrderDeleteSuccessState(id));
    } catch (e, s) {
      handleError(e, stackTrace: s);
    } finally {
      SmartDialog.dismiss();
    }
  }

  Future updateOrder({
    required int id,
    required int contactId,
    required List<Map<String, int>> items,
    List<String>? images,
    bool isVip = false,
    String? remark,
  }) async {
    try {
      SmartDialog.showLoading();
      Response res = await _repo.updateOrder(
        id: id,
        contactId: contactId,
        items: items,
        images: images,
        isVip: isVip,
        remark: remark,
      );
      Order order = Order.fromJson(res.data);
      maybeEmit(OrderUpdateSuccessState(order));
    } catch (e, s) {
      handleError(e, stackTrace: s);
    } finally {
      SmartDialog.dismiss();
    }
  }

  Future<List<Order>?> getPendingOrders() async {
    try {
      SmartDialog.showLoading();
      Response res = await _repo.getPendingOrders();
      List<Order> orders =
          (res.data as List).map((e) => Order.fromJson(e)).toList();

      // 按照加急状态排序，加急订单排在前面
      orders.sort((a, b) {
        if (a.isVip == b.isVip) return 0;
        return a.isVip ? -1 : 1;
      });

      maybeEmit(PendingOrdersSuccessState(orders));
      return orders;
    } catch (e, s) {
      handleError(e, stackTrace: s);
      return null;
    } finally {
      SmartDialog.dismiss();
    }
  }

  Future toggleOrderStatus(int id, bool isCompleted) async {
    try {
      SmartDialog.showLoading();
      await _repo.updateOrderStatus(id, isCompleted);
      maybeEmit(OrderCompleteSuccessState(id, isCompleted));
    } catch (e, s) {
      handleError(e, stackTrace: s);
    } finally {
      SmartDialog.dismiss();
    }
  }
}
