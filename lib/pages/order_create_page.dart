import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tcm/components/search_select_field.dart';
import 'package:tcm/core/blocs/contact/contact_cubit.dart';
import 'package:tcm/core/blocs/contact/contact_state.dart';
import 'package:tcm/core/blocs/order/order_cubit.dart';
import 'package:tcm/core/blocs/order/order_state.dart';
import 'package:tcm/core/blocs/product/product_cubit.dart';
import 'package:tcm/core/blocs/product/product_state.dart';
import 'package:tcm/models/contact.dart';
import 'package:tcm/models/product.dart';

class OrderCreatePage extends StatefulWidget {
  const OrderCreatePage({super.key});

  @override
  State<OrderCreatePage> createState() => _OrderCreatePageState();
}

class OrderLineItem {
  Product? product;
  int quantity = 1;
}

class _OrderCreatePageState extends State<OrderCreatePage> {
  final _formKey = GlobalKey<FormState>();
  Contact? _selectedContact;
  final List<Contact> _contacts = [];
  final List<Product> _products = [];
  final List<OrderLineItem> _lineItems = [OrderLineItem()];

  @override
  void initState() {
    super.initState();
    context.read<ContactCubit>().getContactList();
    context.read<ProductCubit>().getProductList();
  }

  void _addLineItem() {
    setState(() {
      _lineItems.add(OrderLineItem());
    });
  }

  void _removeLineItem(int index) {
    setState(() {
      _lineItems.removeAt(index);
    });
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
        BlocListener<OrderCubit, OrderState>(
          listener: (context, state) {
            if (state is OrderCreateSuccessState) {
              Navigator.pop(context);
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('创建处方'),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              SearchSelectField<Contact>(
                label: '客户',
                hint: '输入客户姓名关键字进行筛选',
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
              const SizedBox(height: 24),
              const Text(
                '处方明细',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ..._lineItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 32,
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 3,
                          child: SearchSelectField<Product>(
                            label: '药品名称',
                            hint: '请选择或输入药品',
                            items: _products,
                            value: item.product,
                            getLabel: (product) => product.name,
                            onChanged: (product) {
                              setState(() {
                                item.product = product;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return '请选择产品';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: '数量',
                              hintText: '请输入数量',
                            ),
                            keyboardType: TextInputType.number,
                            initialValue: item.quantity.toString(),
                            onChanged: (value) {
                              item.quantity = int.tryParse(value) ?? 1;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '请输入数量';
                              }
                              final number = int.tryParse(value);
                              if (number == null || number < 1) {
                                return '请输入有效数量';
                              }
                              return null;
                            },
                          ),
                        ),
                        if (_lineItems.length > 1) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _removeLineItem(index),
                            color: Colors.red,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _addLineItem,
                icon: const Icon(Icons.add),
                label: const Text('添加行'),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final items = _lineItems
                        .map((item) => {
                              'product_id': item.product!.id,
                              'quantity': item.quantity,
                            })
                        .toList();

                    context.read<OrderCubit>().createOrder(
                          contactId: _selectedContact!.id,
                          items: items,
                        );
                  }
                },
                child: const Text('创建'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
