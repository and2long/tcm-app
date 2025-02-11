import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tcm/components/yt_tile.dart';
import 'package:tcm/core/blocs/order/order_cubit.dart';
import 'package:tcm/core/blocs/order/order_state.dart';
import 'package:tcm/models/order.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  final List<Order> _orders = [];

  @override
  void initState() {
    super.initState();
    context.read<OrderCubit>().getOrderList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderCubit, OrderState>(
      listener: (BuildContext context, OrderState state) {
        if (state is OrderListSuccessState) {
          setState(() {
            _orders.clear();
            _orders.addAll(state.orders);
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('处方管理'),
        ),
        body: RefreshIndicator(
          onRefresh: () {
            // 刷新订单列表
            context.read<OrderCubit>().getOrderList();
            return Future.value();
          },
          child: ListView.builder(
            itemBuilder: (context, index) {
              final order = _orders[index];
              return YTTile(
                title: order.name,
                subtitle: order.isCompleted ? '已完成' : '未完成',
              );
            },
            itemCount: _orders.length,
          ),
        ),
      ),
    );
  }
}
