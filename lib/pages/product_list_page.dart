import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:pinyin/pinyin.dart';
import 'package:tcm/components/yt_tile.dart';
import 'package:tcm/core/blocs/product/product_cubit.dart';
import 'package:tcm/core/blocs/product/product_state.dart';
import 'package:tcm/models/product.dart';
import 'package:tcm/pages/product_edit_page.dart';
import 'package:tcm/providers/app_provider.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final products = context.watch<AppProvider>().products;

    return BlocListener<ProductCubit, ProductState>(
      listener: (context, state) {
        if (state is ProductCreateSuccessState) {
          List<Product> items = context.read<AppProvider>().products;
          items.add(state.product);
          items.sort((a, b) => PinyinHelper.getShortPinyin(a.name)
              .compareTo(PinyinHelper.getShortPinyin(b.name)));
          context.read<AppProvider>().setProducts(items);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('创建成功')),
          );
        }
        if (state is ProductDeleteSuccessState) {
          context.read<AppProvider>().removeProduct(state.id);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('删除成功')),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('药品管理'),
          actions: [
            IconButton(
              icon: const Icon(HugeIcons.strokeRoundedAddSquare),
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
          onRefresh: () async {
            final cubit = context.read<ProductCubit>();
            final provider = context.read<AppProvider>();
            final products = await cubit.getProductList();
            if (!mounted) return;
            if (products != null) {
              provider.setProducts(products);
            }
          },
          child: ListView.builder(
            itemBuilder: (context, index) {
              final product = products[index];
              return Slidable(
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (c) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductEditPage(
                              product: product,
                            ),
                          ),
                        );
                      },
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      icon: HugeIcons.strokeRoundedEdit02,
                    ),
                    SlidableAction(
                      onPressed: (c) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('确认删除'),
                            content: Text('确定要删除 ${product.name} 吗？'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('取消'),
                              ),
                              TextButton(
                                onPressed: () {
                                  context
                                      .read<ProductCubit>()
                                      .deleteProduct(product.id);
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
                child: YTTile(title: product.name),
              );
            },
            itemCount: products.length,
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
          autocorrect: false,
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
