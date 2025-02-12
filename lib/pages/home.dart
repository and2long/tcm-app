import 'package:flutter/material.dart';
import 'package:tcm/pages/contact_list_page.dart';
import 'package:tcm/pages/order_list_page.dart';
import 'package:tcm/pages/product_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  int _tabIndex = 0;
  final _pageController = PageController();

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _tabIndex = index;
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
        currentIndex: _tabIndex,
        onTap: (index) {
          _pageController.jumpToPage(index);
        },
      ),
    );
  }
}
