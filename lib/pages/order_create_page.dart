import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tcm/components/search_select_field.dart';
import 'package:tcm/core/blocs/contact/contact_cubit.dart';
import 'package:tcm/core/blocs/contact/contact_state.dart';
import 'package:tcm/core/blocs/product/product_cubit.dart';
import 'package:tcm/core/blocs/product/product_state.dart';
import 'package:tcm/models/contact.dart';
import 'package:tcm/models/product.dart';

class OrderCreatePage extends StatefulWidget {
  const OrderCreatePage({super.key});

  @override
  State<OrderCreatePage> createState() => _OrderCreatePageState();
}

class _OrderCreatePageState extends State<OrderCreatePage> {
  final _formKey = GlobalKey<FormState>();
  Contact? _selectedContact;
  Product? _selectedProduct;
  final List<Contact> _contacts = [];
  final List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    context.read<ContactCubit>().getContactList();
    context.read<ProductCubit>().getProductList();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ContactCubit, ContactState>(
          listener: (context, state) {
            if (state is ContactListSuccessState) {
              setState(() {
                _contacts.clear();
                _contacts.addAll(state.contacts);
              });
            }
          },
        ),
        BlocListener<ProductCubit, ProductState>(
          listener: (context, state) {
            if (state is ProductListSuccessState) {
              setState(() {
                _products.clear();
                _products.addAll(state.products);
              });
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('创建订单'),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              SearchSelectField<Contact>(
                label: '联系人',
                hint: '请选择或输入联系人',
                items: _contacts,
                value: _selectedContact,
                getLabel: (contact) => contact.name,
                onChanged: (contact) {
                  setState(() {
                    _selectedContact = contact;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return '请选择联系人';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SearchSelectField<Product>(
                label: '产品',
                hint: '请选择或输入产品',
                items: _products,
                value: _selectedProduct,
                getLabel: (product) => product.name,
                onChanged: (product) {
                  setState(() {
                    _selectedProduct = product;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return '请选择产品';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // TODO: 创建订单
                  }
                },
                child: const Text('创建订单'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
