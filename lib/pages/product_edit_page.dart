import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tcm/core/blocs/product/product_cubit.dart';
import 'package:tcm/core/blocs/product/product_state.dart';
import 'package:tcm/models/product.dart';
import 'package:tcm/providers/app_provider.dart';

class ProductEditPage extends StatefulWidget {
  final Product product;

  const ProductEditPage({
    super.key,
    required this.product,
  });

  @override
  State<ProductEditPage> createState() => _ProductEditPageState();
}

class _ProductEditPageState extends State<ProductEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.product.name;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductCubit, ProductState>(
      listener: (context, state) {
        if (state is ProductUpdateSuccessState) {
          context.read<AppProvider>().updateProduct(state.product);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('修改成功')),
          );
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('编辑药品'),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '药品名',
                  hintText: '请输入药品名',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入药品名';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    context.read<ProductCubit>().updateProduct(
                          widget.product.id,
                          _nameController.text.trim(),
                        );
                  }
                },
                child: const Text('保存'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
