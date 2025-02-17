import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_ytnavigator/flutter_ytnavigator.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:pinyin/pinyin.dart';
import 'package:tcm/components/yt_search_field.dart';
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

  final _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    context.read<OrderCubit>().getOrderList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Order> _getFilteredOrders(List<Order> orders) {
    if (_searchText.isEmpty) return orders;
    return orders
        .where((order) =>
            (order.contact?.name ?? '')
                .toLowerCase()
                .contains(_searchText.toLowerCase()) ||
            PinyinHelper.getShortPinyin(order.contact?.name ?? '')
                .contains(_searchText.toLowerCase()))
        .toList();
  }

  Widget _buildSearchBar() {
    return YTSearchField(
      controller: _searchController,
      hintText: '搜索处方...',
      onChanged: (value) {
        setState(() {
          _searchText = value;
        });
      },
    );
  }

  Widget _buildDateHeader(String date, List<Order> orders) {
    // 计算当天的订单数量
    final count =
        orders.where((order) => order.createdAt.formatStyle3() == date).length;

    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            HugeIcons.strokeRoundedCalendar03,
            size: 20,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 8),
          Text(
            date,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final filteredOrders = _getFilteredOrders(_orders);

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
        if (state is OrderCompleteSuccessState) {
          final index = _orders.indexWhere((o) => o.id == state.id);
          if (index != -1) {
            _orders[index] =
                _orders[index].copyWith(isCompleted: state.isCompleted);
            setState(() {});
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('处方管理'),
          actions: [
            IconButton(
              icon: const Icon(HugeIcons.strokeRoundedTaskAdd02),
              onPressed: () {
                NavigatorUtil.push(context, const OrderCreatePage());
              },
            ),
          ],
        ),
        body: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () {
                  context.read<OrderCubit>().getOrderList();
                  return Future.value();
                },
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    final previousOrder =
                        index > 0 ? filteredOrders[index - 1] : null;
                    final showDateHeader = previousOrder == null ||
                        order.createdAt.formatStyle3() !=
                            previousOrder.createdAt.formatStyle3();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (showDateHeader)
                          _buildDateHeader(
                            order.createdAt.formatStyle3(),
                            filteredOrders,
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
                                icon: HugeIcons.strokeRoundedDelete02,
                              ),
                            ],
                          ),
                          child: YTTile(
                            title: '#${order.id} ${order.contact?.name}',
                            // showTopBorder: showDateHeader,
                            onTap: () {
                              NavigatorUtil.push(
                                context,
                                OrderDetailPage(orderId: order.id),
                              );
                            },
                            trailing: Icon(
                              order.isCompleted
                                  ? HugeIcons.strokeRoundedCheckmarkCircle01
                                  : null,
                              color: order.isCompleted
                                  ? Colors.green
                                  : Colors.grey.shade300,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  itemCount: filteredOrders.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
