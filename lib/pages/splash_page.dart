import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tcm/core/blocs/contact/contact_cubit.dart';
import 'package:tcm/core/blocs/product/product_cubit.dart';
import 'package:tcm/providers/app_provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final appProvider = context.read<AppProvider>();

    // 获取联系人列表
    context.read<ContactCubit>().getContactList().then((contacts) {
      if (contacts != null) {
        appProvider.setContacts(contacts);
      }
    });

    // 获取产品列表
    context.read<ProductCubit>().getProductList().then((products) {
      if (products != null) {
        appProvider.setProducts(products);
      }
    });

    // 等待数据加载完成后跳转
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
