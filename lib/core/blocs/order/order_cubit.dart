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

  Future getOrderList() async {
    try {
      SmartDialog.showLoading();
      Response res = await _repo.getOrderList();
      List<Order> orders =
          (res.data as List).map((e) => Order.fromJson(e)).toList();
      maybeEmit(OrderListSuccessState(orders));
    } catch (e, s) {
      handleError(e, stackTrace: s);
    } finally {
      SmartDialog.dismiss();
    }
  }
}
