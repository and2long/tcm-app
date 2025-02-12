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
        if (state is ProductDeleteSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('删除成功')),
          );
        }
        if (state is ProductCreateSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('创建成功')),
          );
          context.read<ProductCubit>().getProductList();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('产品管理'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => _CreateProductDialog(),
                );
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () {
            context.read<ProductCubit>().getProductList();
            return Future.value();
          },
          child: ListView.builder(
            itemBuilder: (context, index) {
              final product = _products[index];
              return Dismissible(
                key: Key(product.id.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('确认删除'),
                        content: Text('确认删除 ${product.name} 吗？'),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('取消'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text('确认'),
                            onPressed: () {
                              context
                                  .read<ProductCubit>()
                                  .deleteProduct(product.id);
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                  return null;
                },
                child: YTTile(title: product.name),
              );
            },
            itemCount: _products.length,
          ),
        ),
      ),
    );
  }
}

class _CreateProductDialog extends StatefulWidget {
  @override
  State<_CreateProductDialog> createState() => _CreateProductDialogState();
}

class _CreateProductDialogState extends State<_CreateProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('创建产品'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: '产品名称',
            hintText: '请输入产品名称',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '请输入产品名称';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              context
                  .read<ProductCubit>()
                  .createProduct(_nameController.text.trim());
              Navigator.pop(context);
            }
          },
          child: const Text('确定'),
        ),
      ],
    );
  }
}
