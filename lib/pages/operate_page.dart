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
        _currentOrder ??= orders.first;
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
      listener: (BuildContext context, OrderState state) {
        if (state is OrderCompleteSuccessState) {
          _currentOrder = null;
          _loadPendingOrders();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              if (_currentOrder == null)
                _buildEmptyContent()
              else
                RefreshIndicator(
                  onRefresh: _loadPendingOrders,
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _buildOrderInfoWidget(),
                        ),
                      ),
                      _buildOrderLines(),
                    ],
                  ),
                ),
              _buildBackHomeButton(),
              if (_currentOrder != null) _buildCompleteButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyContent() {
    return Center(
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
          _buildRefreshButton(),
          Text(
            '点击刷新按钮检查是否有新订单',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRefreshButton() {
    return FilledButton(
      onPressed: _loadPendingOrders,
      child: const Text(
        '刷新',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _buildCompleteButton() {
    return Positioned(
      right: 16,
      bottom: 16,
      child: FilledButton(
        style: FilledButton.styleFrom(backgroundColor: Colors.blue),
        onPressed: _showCompleteConfirmDialog,
        child: const Padding(
          padding: EdgeInsets.all(10.0),
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
    );
  }

  void _showCompleteConfirmDialog() {
    if (_currentOrder == null) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认'),
        content: const Text('确定要完成该订单吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context
                  .read<OrderCubit>()
                  .toggleOrderStatus(_currentOrder!.id, true);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Widget _buildBackHomeButton() {
    return Positioned(
      left: 16,
      bottom: 16,
      child: IconButton(
        onPressed: _showBackHomeConfirmDialog,
        icon: const Icon(
          HugeIcons.strokeRoundedArrowTurnBackward,
        ),
      ),
    );
  }

  void _showBackHomeConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('返回主页'),
        content: const Text('确定要返回主页吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              SPUtil.saveIsDoctor(true);
              NavigatorUtil.pushReplacement(context, const HomePage());
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  _buildOrderInfoWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Platform.isIOS ? _buildOrderInfo() : _buildOrderInfoRow(),
        _buildRemainingOrdersButton(),
      ],
    );
  }

  Widget _buildOrderInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _buildOrderInfoItems(),
    );
  }

  Widget _buildOrderInfoRow() {
    return Row(
      spacing: 20,
      children: _buildOrderInfoItems(),
    );
  }

  List<Widget> _buildOrderInfoItems() {
    return [
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
  }

  Widget _buildRemainingOrdersButton() {
    return GestureDetector(
      onTap: _showPendingOrdersList,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 26,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: Colors.yellow.shade700,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '剩余订单: ${_orders.length}',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderLines() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int columnIndex = 0;
                  columnIndex < (_currentOrder!.orderLines.length / 10).ceil();
                  columnIndex++)
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = columnIndex * 10;
                          i < (columnIndex + 1) * 10 &&
                              i < _currentOrder!.orderLines.length;
                          i++)
                        Card(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          child: Container(
                            width: 280,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 13,
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 32,
                                  child: Text(
                                    '${i + 1}.',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    _currentOrder!
                                            .orderLines[i].product?.name ??
                                        '',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '× ${_currentOrder!.orderLines[i].quantity}',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
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
    );
  }

  void _showPendingOrdersList() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('待处理订单'),
            IconButton(
              icon: const Icon(
                HugeIcons.strokeRoundedCancelCircle,
                size: 30,
              ),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _orders.length,
            itemBuilder: (context, index) {
              final order = _orders[index];
              final isCurrentOrder = order.id == _currentOrder?.id;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: isCurrentOrder
                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                    : null,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 订单头部信息
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '#${order.id} ${order.contact?.name}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isCurrentOrder
                                    ? Theme.of(context).primaryColor
                                    : null,
                              ),
                            ),
                          ),
                          if (isCurrentOrder)
                            Icon(
                              Icons.check_circle,
                              color: Theme.of(context).primaryColor,
                            ),
                        ],
                      ),
                      Text(
                        order.createdAt.formatStyle1(),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const Divider(),
                      // 订单行信息
                      Wrap(
                        spacing: 16, // 水平间距
                        runSpacing: 8, // 垂直间距
                        children: order.orderLines
                            .map((line) => Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        line.product?.name ?? '',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '× ${line.quantity}',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                      // 点击切换按钮
                      if (!isCurrentOrder)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _currentOrder = order;
                              });
                              Navigator.pop(context);
                            },
                            child: const Text('切换到此订单'),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
