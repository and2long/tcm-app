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

class OrderDetailSuccessState extends OrderState {
  final Order order;
  OrderDetailSuccessState(this.order);
}

class OrderDeleteSuccessState extends OrderState {
  final int id;
  OrderDeleteSuccessState(this.id);
}

class OrderUpdateSuccessState extends OrderState {
  final Order order;
  OrderUpdateSuccessState(this.order);
}

class PendingOrdersSuccessState extends OrderState {
  final List<Order> orders;
  PendingOrdersSuccessState(this.orders);
}

class OrderCompleteSuccessState extends OrderState {
  final int id;
  final bool isCompleted;
  OrderCompleteSuccessState(this.id, this.isCompleted);
}
