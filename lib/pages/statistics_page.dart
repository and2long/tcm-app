import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:tcm/core/blocs/order/order_cubit.dart';
import 'package:tcm/core/blocs/order/order_state.dart';
import 'package:tcm/models/order.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedMonth = DateTime.now();
  List<Order> _orders = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });

    final month = DateFormat('yyyy-MM').format(_selectedMonth);
    await context.read<OrderCubit>().getOrderList(month: month);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
    _loadOrders();
  }

  void _nextMonth() {
    final now = DateTime.now();
    if (_selectedMonth.year == now.year && _selectedMonth.month == now.month) {
      return;
    }
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
    _loadOrders();
  }

  Map<String, List<Order>> _getCustomerOrders(List<Order> orders) {
    final Map<String, List<Order>> customerOrders = {};

    for (var order in orders) {
      final customerName = order.contact?.name ?? '未知客户';
      customerOrders[customerName] = [
        ...(customerOrders[customerName] ?? []),
        order
      ];
    }

    // 转换为List并排序
    final sortedEntries = customerOrders.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));

    // 转换回Map保持排序
    return Map.fromEntries(sortedEntries);
  }

  Map<String, int> _getProductUsage(List<Order> orders) {
    final Map<String, int> productUsage = {};

    for (var order in orders) {
      for (var line in order.orderLines) {
        final productName = line.product?.name ?? '未知产品';
        productUsage[productName] =
            (productUsage[productName] ?? 0) + line.quantity;
      }
    }

    // 转换为List并排序
    final sortedEntries = productUsage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // 转换回Map保持排序
    return Map.fromEntries(sortedEntries);
  }

  String _formatWeight(int grams) {
    if (grams >= 1000) {
      return '${(grams / 1000).toStringAsFixed(1)}kg';
    }
    return '${grams}g';
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderCubit, OrderState>(
      listener: (context, state) {
        if (state is OrderListSuccessState) {
          setState(() {
            _orders = state.orders;
            _isLoading = false;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('数据统计'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: '客户订单'),
              Tab(text: '药品使用量'),
            ],
          ),
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _isLoading ? null : _previousMonth,
                    icon: const Icon(HugeIcons.strokeRoundedArrowLeft01),
                  ),
                  Text(
                    DateFormat('yyyy年MM月').format(_selectedMonth),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    onPressed: (_isLoading ||
                            (_selectedMonth.year == DateTime.now().year &&
                                _selectedMonth.month == DateTime.now().month))
                        ? null
                        : _nextMonth,
                    icon: const Icon(HugeIcons.strokeRoundedArrowRight01),
                  ),
                ],
              ),
            ),
            if (_isLoading)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '加载中...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // 客户订单统计
                    _orders.isEmpty
                        ? const Center(child: Text('暂无订单数据'))
                        : _buildCustomerOrdersTab(),
                    // 药品使用量统计
                    _orders.isEmpty
                        ? const Center(child: Text('暂无订单数据'))
                        : _buildProductUsageTab(),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerOrdersTab() {
    final customerOrders = _getCustomerOrders(_orders);
    final monthlyOrderCount =
        customerOrders.values.fold(0, (sum, orders) => sum + orders.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSummaryCard(
          title: '本月总订单数',
          value: '$monthlyOrderCount 单',
          valueColor: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: customerOrders.length,
            itemBuilder: (context, index) {
              final entry = customerOrders.entries.elementAt(index);
              return Card(
                child: ListTile(
                  title: Text(entry.key),
                  trailing: Text(
                    '${entry.value.length} 单',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => _OrderDetailDialog(
                        customerName: entry.key,
                        orders: entry.value,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductUsageTab() {
    final productUsage = _getProductUsage(_orders);
    final monthlyTotalUsage =
        productUsage.values.fold(0, (sum, usage) => sum + usage);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSummaryCard(
          title: '本月总用药量',
          value: _formatWeight(monthlyTotalUsage),
          valueColor: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: productUsage.length,
            itemBuilder: (context, index) {
              final entry = productUsage.entries.elementAt(index);
              return Card(
                child: ListTile(
                  title: Text(entry.key),
                  trailing: Text(
                    _formatWeight(entry.value),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _OrderDetailDialog extends StatelessWidget {
  final String customerName;
  final List<Order> orders;

  const _OrderDetailDialog({
    required this.customerName,
    required this.orders,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('$customerName的订单详情'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return ListTile(
              title: Text('#${order.id}'),
              subtitle:
                  Text(DateFormat('yyyy-MM-dd HH:mm').format(order.createdAt)),
              trailing: Text(
                order.isCompleted ? '已完成' : '未完成',
                style: TextStyle(
                  color: order.isCompleted ? Colors.green : Colors.grey,
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('关闭'),
        ),
      ],
    );
  }
}
