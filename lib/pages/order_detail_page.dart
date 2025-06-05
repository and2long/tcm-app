import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ytnavigator/flutter_ytnavigator.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:tcm/components/custom_label.dart';
import 'package:tcm/components/yt_network_image.dart';
import 'package:tcm/core/blocs/extension.dart';
import 'package:tcm/core/blocs/order/order_cubit.dart';
import 'package:tcm/core/blocs/order/order_state.dart';
import 'package:tcm/models/order.dart';
import 'package:tcm/pages/contact_detail_page.dart';
import 'package:tcm/pages/order_create_page.dart';

class OrderDetailPage extends StatefulWidget {
  final int orderId;

  const OrderDetailPage({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  Order? _order;

  @override
  void initState() {
    super.initState();
    context.read<OrderCubit>().getOrderDetail(widget.orderId);
  }

  void _showImageGallery(int initialIndex) {
    showDialog(
      context: context,
      builder: (context) => _ImageGalleryDialog(
        images: _order!.images,
        initialIndex: initialIndex,
      ),
    );
  }

  Widget _buildOrderLines() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        CustomLabel(
          title: '处方明细',
          value: '总重量：${_order!.getQuantity()}g',
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
            childAspectRatio: (MediaQuery.of(context).size.width - 40) / 2 / 45,
          ),
          itemCount: _order!.orderLines.length,
          itemBuilder: (context, index) {
            final line = _order!.orderLines[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      child: Text(
                        '${index + 1}.',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        line.product?.name ?? 'Unknown',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('× ${line.quantity}'),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // 复制文本到剪贴板
  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已复制$label到剪贴板'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // 构建客户详细信息popup
  Widget _buildCustomerInfoPopup() {
    final contact = _order?.contact;
    if (contact == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        _showCustomerInfoDialog(context, contact);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              '${contact.name} ${_order?.isVip == true ? '🚀' : ''}',
              style: Theme.of(context).appBarTheme.titleTextStyle ??
                  Theme.of(context).textTheme.titleLarge,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.keyboard_arrow_down,
            size: 16,
          ),
        ],
      ),
    );
  }

  // 显示居中的客户信息弹窗
  void _showCustomerInfoDialog(BuildContext context, contact) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '客户信息',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        NavigatorUtil.push(
                          context,
                          ContactDetailPage(contact: contact),
                        );
                      },
                      label: Text('详情'),
                      icon: Icon(HugeIcons.strokeRoundedArrowRight01),
                      iconAlignment: IconAlignment.end,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 客户信息列表
                _buildInfoRow(
                  context,
                  icon: HugeIcons.strokeRoundedUser,
                  label: '姓名',
                  value: contact.name,
                ),
                const SizedBox(height: 12),

                _buildInfoRow(
                  context,
                  icon: HugeIcons.strokeRoundedNeutral,
                  label: '性别',
                  value: contact.gender?.isNotEmpty == true
                      ? contact.gender!
                      : '未设置',
                ),
                const SizedBox(height: 12),

                _buildInfoRow(
                  context,
                  icon: HugeIcons.strokeRoundedCall,
                  label: '手机',
                  value: contact.phone?.isNotEmpty == true
                      ? contact.phone!
                      : '未设置',
                  showCopy: contact.phone?.isNotEmpty == true,
                  onCopy: contact.phone?.isNotEmpty == true
                      ? () => _copyToClipboard(context, contact.phone!, '手机号')
                      : null,
                ),
                const SizedBox(height: 12),

                _buildInfoRow(
                  context,
                  icon: HugeIcons.strokeRoundedLocation01,
                  label: '地址1',
                  value: contact.address1?.isNotEmpty == true
                      ? contact.address1!
                      : '未设置',
                  showCopy: contact.address1?.isNotEmpty == true,
                  onCopy: contact.address1?.isNotEmpty == true
                      ? () =>
                          _copyToClipboard(context, contact.address1!, '地址1')
                      : null,
                ),
                const SizedBox(height: 12),

                _buildInfoRow(
                  context,
                  icon: HugeIcons.strokeRoundedLocation01,
                  label: '地址2',
                  value: contact.address2?.isNotEmpty == true
                      ? contact.address2!
                      : '未设置',
                  showCopy: contact.address2?.isNotEmpty == true,
                  onCopy: contact.address2?.isNotEmpty == true
                      ? () =>
                          _copyToClipboard(context, contact.address2!, '地址2')
                      : null,
                ),
                const SizedBox(height: 20),

                // 按钮区域
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      '关闭',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 修改原来的_buildInfoRow方法，使其在dialog中使用新样式
  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool showCopy = false,
    VoidCallback? onCopy,
  }) {
    final isEmptyValue = value == '未设置';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: isEmptyValue
                    ? Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(alpha: 0.6)
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: isEmptyValue ? FontWeight.normal : FontWeight.w500,
              ),
            ),
          ),
          if (showCopy && onCopy != null)
            InkWell(
              onTap: onCopy,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  HugeIcons.strokeRoundedCopy01,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderCubit, OrderState>(
      listener: (context, state) {
        if (state is OrderDetailSuccessState) {
          setState(() {
            _order = state.order;
          });
        }
        if (state is OrderUpdateSuccessState) {
          setState(() {
            _order = state.order;
          });
        }
        if (state is OrderCompleteSuccessState) {
          setState(() {
            if (_order?.id == state.id) {
              _order = _order?.copyWith(isCompleted: state.isCompleted);
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.isCompleted
                    ? '#${_order?.id} 订单已完成'
                    : '#${_order?.id} 订单已标记为未完成',
              ),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: _order == null ? Text('') : _buildCustomerInfoPopup(),
          actions: [
            if (_order != null)
              IconButton(
                icon: const Icon(HugeIcons.strokeRoundedCopy01),
                tooltip: '复制处方',
                onPressed: () {
                  NavigatorUtil.pushReplacement(
                    context,
                    OrderCreatePage(
                      order: _order!.copyWith(isVip: false),
                      isClone: true,
                    ),
                  );
                },
              ),
            if (_order != null && !_order!.isCompleted)
              IconButton(
                tooltip: '编辑处方',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {
                  NavigatorUtil.push(
                    context,
                    OrderCreatePage(order: _order),
                  );
                },
              ),
          ],
        ),
        body: _order == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.only(
                    left: 16.0, top: 16, right: 16, bottom: 100),
                children: [
                  // 订单信息
                  const CustomLabel(title: '订单信息'),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('创建时间：${_order!.createdAt.formatStyle1()}'),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('状态：${_order!.isCompleted ? "已完成" : "未完成"}'),
                              TextButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(
                                        _order!.isCompleted ? '取消完成' : '确认完成',
                                      ),
                                      content: Text(
                                        _order!.isCompleted
                                            ? '确定要将订单标记为未完成吗？'
                                            : '确定要将订单标记为已完成吗？',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('取消'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            context
                                                .read<OrderCubit>()
                                                .toggleOrderStatus(
                                                  _order!.id,
                                                  !_order!.isCompleted,
                                                );
                                            Navigator.pop(context);
                                          },
                                          child: const Text('确定'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: Text(
                                  _order!.isCompleted ? '标记为未完成' : '标记为已完成',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 显示备注信息
                  if (_order!.remark != null && _order!.remark!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const CustomLabel(title: '备注'),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(_order!.remark!),
                      ),
                    ),
                  ],
                  // 图片
                  const SizedBox(height: 24),
                  if (_order!.images.isNotEmpty) ...[
                    const CustomLabel(title: '图片'),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _order!.images.length,
                        itemBuilder: (context, index) {
                          final image = _order!.images[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Hero(
                              tag: index,
                              child: GestureDetector(
                                onTap: () => _showImageGallery(index),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: YTNetworkImage(
                                    imageUrl: image,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  _buildOrderLines(),
                ],
              ),
      ),
    );
  }
}

class _ImageGalleryDialog extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _ImageGalleryDialog({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_ImageGalleryDialog> createState() => _ImageGalleryDialogState();
}

class _ImageGalleryDialogState extends State<_ImageGalleryDialog> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            builder: (BuildContext context, int index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: CachedNetworkImageProvider(widget.images[index]),
                initialScale: PhotoViewComputedScale.contained,
                heroAttributes: PhotoViewHeroAttributes(tag: index),
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(
                    Icons.error,
                    size: 48,
                    color: Colors.white54,
                  ),
                ),
              );
            },
            itemCount: widget.images.length,
            loadingBuilder: (context, event) => const Center(
              child: CircularProgressIndicator(),
            ),
            pageController: PageController(initialPage: widget.initialIndex),
            backgroundDecoration: const BoxDecoration(
              color: Colors.black,
            ),
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
          ),
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon: const Icon(
                HugeIcons.strokeRoundedCancelCircle,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Positioned(
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < widget.images.length; i++)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == currentIndex
                            ? Colors.white
                            : Colors.grey.shade800,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
