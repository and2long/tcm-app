import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tcm/components/search_select_field.dart';
import 'package:tcm/core/blocs/order/order_cubit.dart';
import 'package:tcm/core/blocs/order/order_state.dart';
import 'package:tcm/core/repos/upload_repo.dart';
import 'package:tcm/models/contact.dart';
import 'package:tcm/models/order.dart';
import 'package:tcm/models/product.dart';
import 'package:tcm/providers/app_provider.dart';

class OrderCreatePage extends StatefulWidget {
  final Order? order;

  const OrderCreatePage({
    super.key,
    this.order,
  });

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
  final List<OrderLineItem> _lineItems = [OrderLineItem()];
  final List<XFile> _images = [];
  final _picker = ImagePicker();
  final List<String> _uploadedImages = [];
  // 最大图片数量
  final int _maxImageCount = 3;

  @override
  void initState() {
    super.initState();
    if (widget.order != null) {
      _selectedContact = widget.order!.contact;
      _lineItems.clear();
      _lineItems.addAll(
        widget.order!.orderLines.map(
          (line) => OrderLineItem()
            ..product = line.product
            ..quantity = line.quantity,
        ),
      );
      _uploadedImages.addAll(widget.order!.images);
    }
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

  Future<void> _pickImage() async {
    if ((_images.length + _uploadedImages.length) == _maxImageCount - 1) {
      XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _images.add(image);
        });
      }
    } else {
      final List<XFile> images = await _picker.pickMultiImage(
          limit: _maxImageCount - (_images.length + _uploadedImages.length));
      if (images.isNotEmpty) {
        setState(() {
          _images.addAll(images);
        });
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    SmartDialog.showLoading();
    final items = _lineItems
        .map((item) => {
              'product_id': item.product!.id,
              'quantity': item.quantity,
            })
        .toList();

    List<String> allImages = [..._uploadedImages]; // 先保存已有的图片

    // 只有当有新选择的图片时才进行上传
    if (_images.isNotEmpty) {
      final newImages = await Future.wait(
        _images.map((image) async {
          try {
            final res = await context.read<UploadRepo>().uploadImage(
                  image.path,
                  type: 'medical',
                  username: _selectedContact!.name,
                );
            return res.data['key'] as String;
          } catch (e) {
            return null;
          }
        }),
      );
      allImages.addAll(newImages.where((item) => item != null).cast<String>());
    }

    if (widget.order == null) {
      context.read<OrderCubit>().createOrder(
            contactId: _selectedContact!.id,
            items: items,
            images: allImages,
          );
    } else {
      context.read<OrderCubit>().updateOrder(
            id: widget.order!.id,
            contactId: _selectedContact!.id,
            items: items,
            images: allImages,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();

    return MultiBlocListener(
      listeners: [
        BlocListener<OrderCubit, OrderState>(
          listener: (context, state) {
            if (state is OrderCreateSuccessState) {
              Navigator.pop(context);
            }
            if (state is OrderUpdateSuccessState) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('修改成功')),
              );
              Navigator.pop(context);
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title:
              Text(widget.order == null ? '创建处方' : '修改处方 #${widget.order!.id}'),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.only(
                left: 16.0, top: 16, right: 16, bottom: 200),
            children: [
              SearchSelectField<Contact>(
                label: '客户',
                hint: '输入客户姓名关键字进行筛选',
                items: appProvider.contacts,
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
              Row(
                children: [
                  const Text(
                    '图片',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${_images.length + _uploadedImages.length}/$_maxImageCount)',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ..._uploadedImages.asMap().entries.map(
                      (entry) {
                        final index = entry.key;
                        final imageUrl = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  imageUrl,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                right: 4,
                                top: 4,
                                child: GestureDetector(
                                  onTap: () => setState(() {
                                    _uploadedImages.removeAt(index);
                                  }),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    ..._images.asMap().entries.map(
                      (entry) {
                        final index = entry.key;
                        final image = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(image.path),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                right: 4,
                                top: 4,
                                child: GestureDetector(
                                  onTap: () => _removeImage(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    if (_images.length + _uploadedImages.length <
                        _maxImageCount)
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 32,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                  ],
                ),
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
                            label: '产品名称',
                            hint: '请选择或输入产品',
                            items: appProvider.products,
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
                            autocorrect: false,
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
                onPressed: _handleSubmit,
                child: Text(widget.order == null ? '创建' : '保存'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
