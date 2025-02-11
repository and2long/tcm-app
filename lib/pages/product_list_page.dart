import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tcm/components/yt_tile.dart';
import 'package:tcm/core/blocs/product/product_cubit.dart';
import 'package:tcm/core/blocs/product/product_state.dart';
import 'package:tcm/models/product.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    context.read<ProductCubit>().getProductList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductCubit, ProductState>(
      listener: (BuildContext context, ProductState state) {
        if (state is ProductListSuccessState) {
          setState(() {
            _products.clear();
            _products.addAll(state.products);
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('产品管理'),
        ),
        body: RefreshIndicator(
          onRefresh: () {
            context.read<ProductCubit>().getProductList();
            return Future.value();
          },
          child: ListView.builder(
            itemBuilder: (context, index) {
              final product = _products[index];
              return YTTile(
                title: product.name,
              );
            },
            itemCount: _products.length,
          ),
        ),
      ),
    );
  }
}
