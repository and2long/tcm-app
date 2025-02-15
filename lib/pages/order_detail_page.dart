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
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('#${widget.orderId} ${_order?.contact?.name}'),
          actions: [
            if (_order != null)
              IconButton(
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
                          Text('状态：${_order!.isCompleted ? "已完成" : "未完成"}'),
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

                  // 处方明细
                  Text(
                    '处方明细',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ..._order!.orderLines.asMap().entries.map((entry) {
                    final index = entry.key;
                    final line = entry.value;
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
                  }),
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
            left: 16,
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
