import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ytnavigator/flutter_ytnavigator.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:tcm/components/yt_network_image.dart';
import 'package:tcm/core/blocs/extension.dart';
import 'package:tcm/core/blocs/order/order_cubit.dart';
import 'package:tcm/core/blocs/order/order_state.dart';
import 'package:tcm/models/order.dart';
import 'package:tcm/pages/order_create_page.dart';
import 'package:tcm/utils/sp_util.dart';

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
  late bool _isSingleColumn;

  @override
  void initState() {
    super.initState();
    _isSingleColumn = SPUtil.getOrderListLayout();
    context.read<OrderCubit>().getOrderDetail(widget.orderId);
  }

  void _toggleLayout() {
    setState(() {
      _isSingleColumn = !_isSingleColumn;
      SPUtil.saveOrderListLayout(_isSingleColumn);
    });
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
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '处方明细',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            IconButton(
              icon: Icon(_isSingleColumn
                  ? HugeIcons.strokeRoundedLayout02
                  : HugeIcons.strokeRoundedLayout3Row),
              onPressed: _toggleLayout,
              tooltip: _isSingleColumn ? '切换为网格视图' : '切换为列表视图',
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_isSingleColumn)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _order!.orderLines.length,
            itemBuilder: (context, index) {
              final line = _order!.orderLines[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(line.product?.name ?? 'Unknown'),
                      ),
                      const SizedBox(width: 16),
                      Text('× ${line.quantity}'),
                    ],
                  ),
                ),
              );
            },
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 0,
              crossAxisSpacing: 0,
              childAspectRatio:
                  (MediaQuery.of(context).size.width - 40) / 2 / 60,
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
                          '${index + 1}',
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
          title: Text(
              '#${widget.orderId} ${_order?.contact?.name} ${_order?.isVip == true ? '🚀' : ''}'),
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
                  Text(
                    '订单信息',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
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
                          // 显示备注信息
                          if (_order!.remark != null &&
                              _order!.remark!.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            const Text(
                              '备注：',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(_order!.remark!),
                          ],
                        ],
                      ),
                    ),
                  ),
                  // 图片
                  const SizedBox(height: 24),
                  if (_order!.images.isNotEmpty) ...[
                    Text(
                      '图片',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
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
