import 'package:tcm/models/order.dart';

abstract class OrderState {}

class OrderInitialState extends OrderState {}

class OrderListSuccessState extends OrderState {
  final List<Order> orders;
  OrderListSuccessState(this.orders);
}

class OrderCreateSuccessState extends OrderState {
  final Order order;
  OrderCreateSuccessState(this.order);
}
