import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tcm/core/blocs/contact/contact_cubit.dart';
import 'package:tcm/core/blocs/product/product_cubit.dart';
import 'package:tcm/pages/contact_list_page.dart';
import 'package:tcm/pages/order_list_page.dart';
import 'package:tcm/pages/product_list_page.dart';
import 'package:tcm/providers/app_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    if (!mounted) return;
    final appProvider = context.read<AppProvider>();

    // 获取联系人列表
    final contacts = await context.read<ContactCubit>().getContactList();
    if (!mounted) return;
    if (contacts != null) {
      appProvider.setContacts(contacts);
    }

    // 获取产品列表
    final products = await context.read<ProductCubit>().getProductList();
    if (!mounted) return;
    if (products != null) {
      appProvider.setProducts(products);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: const [
          OrderListPage(),
          ContactListPage(),
          ProductListPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '处方',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '客户',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services_rounded),
            label: '药品',
          ),
        ],
        currentIndex: _currentIndex,
        onTap: (index) {
          _pageController.jumpToPage(index);
        },
      ),
    );
  }
}
