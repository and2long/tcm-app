import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ytnavigator/flutter_ytnavigator.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:tcm/core/blocs/extension.dart';
import 'package:tcm/core/blocs/order/order_cubit.dart';
import 'package:tcm/core/blocs/order/order_state.dart';
import 'package:tcm/models/order.dart';
import 'package:tcm/pages/home.dart';
import 'package:tcm/utils/sp_util.dart';

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
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        FilledButton(
                          onPressed: _loadPendingOrders,
                          child: const Text(
                            '刷新',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        Text(
                          '点击刷新按钮检查是否有新订单',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        )
                      ],
                    ),
                  ),
                  Positioned(
                    left: 16,
                    bottom: 16,
                    child: IconButton(
                      onPressed: () {
                        SPUtil.saveIsDoctor(true);
                        NavigatorUtil.pushReplacement(
                            context, const HomePage());
                      },
                      icon: const Icon(
                        HugeIcons.strokeRoundedArrowTurnBackward,
                      ),
                    ),
                  ),
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
                          child: _buildOrderInfoWidget(),
                        ),
                        Expanded(
                          child: Scrollbar(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
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
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 16.0,
                                                    vertical: 13,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      SizedBox(
                                                        width: 32,
                                                        child: Text(
                                                          '${i + 1}.',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
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
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        '× ${_currentOrder!.orderLines[i].quantity}',
                                                        style: TextStyle(
                                                          color:
                                                              Colors.grey[700],
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
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
                        child: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            '完成这个订单',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  _buildOrderInfoWidget() {
    final items = [
      Text(
        _currentOrder?.contact?.name ?? '',
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        '订单号: #${_currentOrder?.id}',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
      const SizedBox(height: 4),
      Text(
        '${_currentOrder?.createdAt.formatStyle1()}',
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey[600],
          fontWeight: FontWeight.bold,
        ),
      ),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Platform.isIOS
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: items,
              )
            : Row(
                spacing: 20,
                children: items,
              ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 26,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            '👉 剩余订单: ${_orders.length}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }
}
