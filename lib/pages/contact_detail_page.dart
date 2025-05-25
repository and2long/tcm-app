import 'package:flutter/material.dart';
import 'package:flutter_ytnavigator/flutter_ytnavigator.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:tcm/components/custom_label.dart';
import 'package:tcm/models/contact.dart';
import 'package:tcm/pages/contact_edit_page.dart';

class ContactDetailPage extends StatelessWidget {
  final Contact contact;

  const ContactDetailPage({
    super.key,
    required this.contact,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('联系人详情'),
        actions: [
          IconButton(
            icon: const Icon(HugeIcons.strokeRoundedEditUser02),
            onPressed: () {
              NavigatorUtil.push(
                context,
                ContactEditPage(contact: contact),
              );
            },
            tooltip: '编辑联系人',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头部信息卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        contact.name.isNotEmpty ? contact.name[0] : '?',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contact.name,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID: ${contact.id}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 详细信息
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '详细信息',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),

                    // 姓名 - 始终显示
                    CustomLabel(
                      title: '姓名',
                      value: contact.name,
                    ),
                    const SizedBox(height: 12),

                    // 性别 - 仅在非空时显示
                    if (contact.gender != null &&
                        contact.gender!.isNotEmpty) ...[
                      CustomLabel(
                        title: '性别',
                        value: contact.gender,
                      ),
                      const SizedBox(height: 12),
                    ],

                    // 手机号 - 仅在非空时显示
                    if (contact.phone != null && contact.phone!.isNotEmpty) ...[
                      CustomLabel(
                        title: '手机号',
                        value: contact.phone,
                      ),
                      const SizedBox(height: 12),
                    ],

                    // 地址1 - 仅在非空时显示
                    if (contact.address1 != null &&
                        contact.address1!.isNotEmpty) ...[
                      CustomLabel(
                        title: '地址1',
                        value: contact.address1,
                      ),
                      const SizedBox(height: 12),
                    ],

                    // 地址2 - 仅在非空时显示
                    if (contact.address2 != null &&
                        contact.address2!.isNotEmpty) ...[
                      CustomLabel(
                        title: '地址2',
                        value: contact.address2,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
