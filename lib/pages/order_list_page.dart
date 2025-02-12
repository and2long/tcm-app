import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ytnavigator/flutter_ytnavigator.dart';
import 'package:tcm/components/yt_tile.dart';
import 'package:tcm/core/blocs/extension.dart';
import 'package:tcm/core/blocs/order/order_cubit.dart';
import 'package:tcm/core/blocs/order/order_state.dart';
import 'package:tcm/models/order.dart';
import 'package:tcm/pages/order_create_page.dart';
import 'package:tcm/pages/order_detail_page.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final List<Order> _orders = [];

  @override
  void initState() {
    super.initState();
    context.read<OrderCubit>().getOrderList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocListener<OrderCubit, OrderState>(
      listener: (BuildContext context, OrderState state) {
        if (state is OrderListSuccessState) {
          setState(() {
            _orders.clear();
            _orders.addAll(state.orders);
          });
        }
        if (state is OrderCreateSuccessState) {
          _orders.insert(0, state.order);
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('创建成功')),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('处方管理'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                NavigatorUtil.push(context, const OrderCreatePage());
              },
            ),
          ],
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
              final previousOrder = index > 0 ? _orders[index - 1] : null;
              final showDateHeader = previousOrder == null ||
                  order.createdAt.formatStyle3() !=
                      previousOrder.createdAt.formatStyle3();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showDateHeader)
                    Container(
                      color: Colors.grey[200],
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        order.createdAt.formatStyle3(),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  YTTile(
                    title: '${order.name} / ${order.contact?.name}',
                    onTap: () {
                      NavigatorUtil.push(
                        context,
                        OrderDetailPage(orderId: order.id),
                      );
                    },
                    trailing: Icon(
                      order.isCompleted
                          ? Icons.check_circle_outline
                          : Icons.circle_outlined,
                      color: order.isCompleted
                          ? Colors.green
                          : Colors.grey.shade300,
                    ),
                  ),
                ],
              );
            },
            itemCount: _orders.length,
          ),
        ),
      ),
    );
  }
}
