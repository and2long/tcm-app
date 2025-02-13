import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ytnavigator/flutter_ytnavigator.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:tcm/core/blocs/extension.dart';
import 'package:tcm/core/blocs/order/order_cubit.dart';
import 'package:tcm/core/blocs/order/order_state.dart';
import 'package:tcm/models/order.dart';
import 'package:tcm/pages/home.dart';

class OperatePage extends StatefulWidget {
  const OperatePage({super.key});

  @override
  State<OperatePage> createState() => _OperatePageState();
}

class _OperatePageState extends State<OperatePage> {
  Order? _currentOrder;
  List<Order> _orders = [];
  @override
  void initState() {
    super.initState();
    _loadPendingOrders();
  }

  Future<void> _loadPendingOrders() async {
    final orders = await context.read<OrderCubit>().getPendingOrders();
    if (orders != null && orders.isNotEmpty) {
      setState(() {
        _orders = orders;
        _currentOrder = orders.first;
      });
    }
    if (orders == null || orders.isEmpty) {
      setState(() {
        _orders = [];
        _currentOrder = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderCubit, OrderState>(
      listener: (context, state) {
        if (state is OrderCompleteSuccessState) {
          _loadPendingOrders();
        }
      },
      child: Scaffold(
        body: _currentOrder == null
            ? Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 20,
                      children: [
                        const Text(
                          '🎉 暂无待办订单',
                          style: TextStyle(fontSize: 26),
                        ),
                        FilledButton(
                            onPressed: _loadPendingOrders,
                            child: const Text(
                              '刷新',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            )),
                        Text(
                          '点击刷新按钮检查是否有新订单',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[600]),
                        )
                      ],
                    ),
                  ),
                  Positioned(
                      left: 16,
                      bottom: 16,
                      child: IconButton(
                          onPressed: () {
                            NavigatorUtil.pushReplacement(
                                context, const HomePage());
                          },
                          icon: const Icon(
                              HugeIcons.strokeRoundedArrowTurnBackward)))
                ],
              )
            : SafeArea(
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _currentOrder?.contact?.name ?? '',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '订单号: #${_currentOrder?.id}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '创建时间: ${_currentOrder?.createdAt.formatStyle1()}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      '待办: ${_orders.length}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (int columnIndex = 0;
                                      columnIndex <
                                          (_currentOrder!.orderLines.length /
                                                  10)
                                              .ceil();
                                      columnIndex++)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          for (int i = columnIndex * 10;
                                              i < (columnIndex + 1) * 10 &&
                                                  i <
                                                      _currentOrder!
                                                          .orderLines.length;
                                              i++)
                                            Card(
                                              margin: const EdgeInsets.only(
                                                  bottom: 8.0),
                                              child: Container(
                                                width: 280,
                                                padding:
                                                    const EdgeInsets.all(12.0),
                                                child: Row(
                                                  children: [
                                                    SizedBox(
                                                      width: 24,
                                                      child: Text(
                                                        '${i + 1}.',
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        _currentOrder!
                                                                .orderLines[i]
                                                                .product
                                                                ?.name ??
                                                            '',
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      '× ${_currentOrder!.orderLines[i].quantity}',
                                                      style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      left: 16,
                      bottom: 16,
                      child: IconButton(
                        onPressed: () {
                          NavigatorUtil.pushReplacement(
                              context, const HomePage());
                        },
                        icon: const Icon(
                            HugeIcons.strokeRoundedArrowTurnBackward),
                      ),
                    ),
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: FilledButton(
                        onPressed: () {
                          if (_currentOrder != null) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('确认'),
                                content: const Text('确定要完成该订单吗？'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('取消'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      context
                                          .read<OrderCubit>()
                                          .completeOrder(_currentOrder!.id);
                                    },
                                    child: const Text('确定'),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        child: const Text('确认完成'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
