import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tcm/components/custom_label.dart';
import 'package:tcm/components/search_select_field.dart';
import 'package:tcm/components/yt_network_image.dart';
import 'package:tcm/core/blocs/order/order_cubit.dart';
import 'package:tcm/core/blocs/order/order_state.dart';
import 'package:tcm/core/repos/upload_repo.dart';
import 'package:tcm/models/contact.dart';
import 'package:tcm/models/order.dart';
import 'package:tcm/models/product.dart';
import 'package:tcm/pages/image_gallery_page.dart';
import 'package:tcm/providers/app_provider.dart';
import 'package:tcm/utils/sp_util.dart';

class OrderCreatePage extends StatefulWidget {
  final Order? order;
  final bool isClone;

  const OrderCreatePage({
    super.key,
    this.order,
    this.isClone = false,
  });

  @override
  State<OrderCreatePage> createState() => _OrderCreatePageState();
}

class OrderLineItem {
  Product? product;
  int quantity = 1;

  OrderLineItem({
    this.product,
    this.quantity = 1,
  });
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
  bool _isDirty = false; // 标记表单是否被修改
  bool _isVip = false; // 是否为加急订单
  final TextEditingController _remarkController =
      TextEditingController(); // 备注控制器

  @override
  void initState() {
    super.initState();
    if (widget.isClone || widget.order != null) {
      _selectedContact = widget.order!.contact;
      _lineItems.clear();
      _lineItems.addAll(
        widget.order!.orderLines.map((line) => OrderLineItem(
              product: line.product,
              quantity: line.quantity,
            )),
      );
      _uploadedImages.addAll(widget.order!.images);
      _isVip = widget.order!.isVip; // 初始化加急状态
      _remarkController.text = widget.order!.remark ?? ''; // 初始化备注
    } else {
      _loadDraft(); // 加载草稿
    }
  }

  @override
  void dispose() {
    _remarkController.dispose(); // 释放控制器
    super.dispose();
  }

  void _loadDraft() {
    final draft = SPUtil.getOrderDraft();
    if (draft != null) {
      setState(() {
        _selectedContact = context.read<AppProvider>().contacts.firstWhere(
              (c) => c.id == draft['contact_id'],
              orElse: () => Contact(id: -1, name: ''),
            );
        _lineItems.clear();
        final products = context.read<AppProvider>().products;
        final List<dynamic> items = draft['items'];
        _lineItems.addAll(
          items.map((item) => OrderLineItem(
                product: products.firstWhere(
                  (p) => p.id == item['product_id'],
                  orElse: () => Product(id: -1, name: ''),
                ),
                quantity: item['quantity'],
              )),
        );
        _uploadedImages.addAll(List<String>.from(draft['images'] ?? []));
        _isVip = draft['is_vip'] ?? false; // 加载加急状态
        _remarkController.text = draft['remark'] ?? ''; // 加载备注

        // 加载本地图片
        final localImages = List<String>.from(draft['local_images'] ?? []);
        _images.addAll(
          localImages
              .map((path) => XFile(path))
              .where((file) => File(file.path).existsSync()),
        );
      });
    }
  }

  Map<String, dynamic> _getDraftData() {
    return {
      'contact_id': _selectedContact?.id,
      'items': _lineItems
          .where((item) => item.product != null)
          .map((item) => {
                'product_id': item.product!.id,
                'quantity': item.quantity,
              })
          .toList(),
      'images': _uploadedImages,
      'local_images': _images.map((image) => image.path).toList(), // 保存本地图片路径
      'is_vip': _isVip, // 保存加急状态
      'remark': _remarkController.text, // 保存备注
    };
  }

  Future<bool> _onWillPop() async {
    if (!_isDirty) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('保存草稿'),
        content: const Text('是否保存当前编辑的内容？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('不保存'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('保存'),
          ),
        ],
      ),
    );

    if (result == true) {
      await SPUtil.saveOrderDraft(_getDraftData());
    } else {
      await SPUtil.clearOrderDraft();
    }
    return true;
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
          _isDirty = true;
        });
      }
    } else {
      final List<XFile> images = await _picker.pickMultiImage(
          limit: _maxImageCount - (_images.length + _uploadedImages.length));
      if (images.isNotEmpty) {
        setState(() {
          _images.addAll(images);
          _isDirty = true;
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

    if (mounted) {
      if (widget.order == null || widget.isClone) {
        context.read<OrderCubit>().createOrder(
              contactId: _selectedContact!.id,
              items: items,
              images: allImages,
              isVip: _isVip, // 添加加急状态
              remark: _remarkController.text, // 添加备注
            );
      } else {
        context.read<OrderCubit>().updateOrder(
              id: widget.order!.id,
              contactId: _selectedContact!.id,
              items: items,
              images: allImages,
              isVip: _isVip, // 添加加急状态
              remark: _remarkController.text, // 添加备注
            );
      }
    }
  }

  void _showImageGallery(int initialIndex) {
    // 合并所有图片，先是已上传的，再是本地选择的
    List<dynamic> allImages = [..._uploadedImages, ..._images];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageGalleryPage(
          images: allImages,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        final bool shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: MultiBlocListener(
        listeners: [
          BlocListener<OrderCubit, OrderState>(
            listener: (context, state) {
              if (state is OrderCreateSuccessState) {
                SPUtil.clearOrderDraft(); // 创建成功后清除草稿
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
            title: Text((widget.order == null || widget.isClone)
                ? '创建处方'
                : '修改处方 #${widget.order!.id}${widget.order!.isVip ? ' 🚀' : ''}'),
          ),
          body: Form(
            key: _formKey,
            onChanged: () {
              _isDirty = true;
            },
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
                // 加急订单开关
                Row(
                  children: [
                    const CustomLabel(title: '加急订单'),
                    const Spacer(),
                    Switch(
                      value: _isVip,
                      onChanged: (value) {
                        setState(() {
                          _isVip = value;
                          _isDirty = true;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 备注输入框
                const CustomLabel(title: '备注'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _remarkController,
                  decoration: const InputDecoration(
                    hintText: '请输入备注信息（选填）',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  onChanged: (_) {
                    _isDirty = true;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const CustomLabel(title: '图片'),
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
                            child: GestureDetector(
                              onTap: () => _showImageGallery(index),
                              child: Stack(
                                children: [
                                  Hero(
                                    tag: index,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: YTNetworkImage(
                                        imageUrl: imageUrl,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
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
                            child: GestureDetector(
                              onTap: () => _showImageGallery(
                                  _uploadedImages.length + index),
                              child: Stack(
                                children: [
                                  Hero(
                                    tag: _uploadedImages.length + index,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(image.path),
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
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
                const CustomLabel(title: '处方明细'),
                const SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio:
                        (MediaQuery.of(context).size.width - 40) / 2 / 70,
                    crossAxisSpacing: 0,
                    mainAxisSpacing: 0,
                  ),
                  itemCount: _lineItems.length,
                  itemBuilder: (context, index) {
                    final item = _lineItems[index];
                    return Dismissible(
                      key: ValueKey(item),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        _removeLineItem(index);
                      },
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(
                          HugeIcons.strokeRoundedDelete02,
                          color: Colors.white,
                        ),
                      ),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Container(
                                constraints: const BoxConstraints(minWidth: 24),
                                child: Text('${index + 1}'),
                              ),
                              Expanded(
                                flex: 3,
                                child: SearchSelectField<Product>(
                                  label: '药品',
                                  hint: '请选择或输入药品名',
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
                                      return '请选择药品';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  autocorrect: false,
                                  decoration: const InputDecoration(
                                    label: Text('数量'),
                                    hintText: '请输入数量',
                                    isDense: true,
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
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _addLineItem,
                  icon: const Icon(Icons.add),
                  label: const Text('添加行'),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _handleSubmit,
                  child: Text(
                      (widget.order == null || widget.isClone) ? '创建' : '保存'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
