import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
        if (state is OrderDeleteSuccessState) {
          _orders.removeWhere((order) => order.id == state.id);
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('删除成功')),
          );
        }
        if (state is OrderUpdateSuccessState) {
          final index = _orders.indexWhere((o) => o.id == state.order.id);
          if (index != -1) {
            _orders[index] = state.order;
            setState(() {});
          }
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
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        order.createdAt.formatStyle3(),
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  Slidable(
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (c) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('确认删除'),
                                content: const Text('确定要删除这个处方吗？'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('取消'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      context
                                          .read<OrderCubit>()
                                          .deleteOrder(order.id);
                                      Navigator.pop(context, true);
                                    },
                                    child: const Text('确定'),
                                  ),
                                ],
                              ),
                            );
                          },
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                        ),
                      ],
                    ),
                    child: YTTile(
                      title: '#${order.id} ${order.contact?.name}',
                      showTopBorder: showDateHeader,
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
