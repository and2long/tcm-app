import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ytnavigator/flutter_ytnavigator.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:tcm/models/contact.dart';
import 'package:tcm/pages/contact_edit_page.dart';

class ContactDetailPage extends StatefulWidget {
  final Contact contact;

  const ContactDetailPage({
    super.key,
    required this.contact,
  });

  @override
  State<ContactDetailPage> createState() => _ContactDetailPageState();
}

class _ContactDetailPageState extends State<ContactDetailPage> {
  late Contact _contact;

  @override
  void initState() {
    super.initState();
    _contact = widget.contact;
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

  // 构建紧凑的信息行
  Widget _buildCompactInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool showCopy = false,
    VoidCallback? onCopy,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 50,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: value == '未设置'
                      ? Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant
                          .withOpacity(0.6)
                      : null,
                  fontStyle: value == '未设置' ? FontStyle.italic : null,
                ),
          ),
        ),
        if (showCopy && onCopy != null)
          IconButton(
            icon: Icon(
              HugeIcons.strokeRoundedCopy01,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: onCopy,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            tooltip: '复制$label',
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('联系人详情'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            icon: const Icon(HugeIcons.strokeRoundedEditUser02),
            onPressed: () {
              NavigatorUtil.push(context, ContactEditPage(contact: _contact))
                  .then((value) {
                if (value != null) {
                  setState(() {
                    _contact = value;
                  });
                }
              });
            },
            tooltip: '编辑联系人',
          ),
        ],
      ),
      body: Column(
        children: [
          // 紧凑的联系人信息卡片
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题行：姓名 + ID
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _contact.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'ID: ${_contact.id}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 紧凑的信息行
                _buildCompactInfoRow(
                  context,
                  icon: HugeIcons.strokeRoundedUser,
                  label: '性别',
                  value: _contact.gender?.isNotEmpty == true
                      ? _contact.gender!
                      : '未设置',
                ),
                const SizedBox(height: 8),

                _buildCompactInfoRow(
                  context,
                  icon: HugeIcons.strokeRoundedCall,
                  label: '手机',
                  value: _contact.phone?.isNotEmpty == true
                      ? _contact.phone!
                      : '未设置',
                  showCopy: _contact.phone?.isNotEmpty == true,
                  onCopy: _contact.phone?.isNotEmpty == true
                      ? () => _copyToClipboard(context, _contact.phone!, '手机号')
                      : null,
                ),
                const SizedBox(height: 8),

                _buildCompactInfoRow(
                  context,
                  icon: HugeIcons.strokeRoundedLocation01,
                  label: '地址1',
                  value: _contact.address1?.isNotEmpty == true
                      ? _contact.address1!
                      : '未设置',
                  showCopy: _contact.address1?.isNotEmpty == true,
                  onCopy: _contact.address1?.isNotEmpty == true
                      ? () =>
                          _copyToClipboard(context, _contact.address1!, '地址1')
                      : null,
                ),
                const SizedBox(height: 8),

                _buildCompactInfoRow(
                  context,
                  icon: HugeIcons.strokeRoundedLocation01,
                  label: '地址2',
                  value: _contact.address2?.isNotEmpty == true
                      ? _contact.address2!
                      : '未设置',
                  showCopy: _contact.address2?.isNotEmpty == true,
                  onCopy: _contact.address2?.isNotEmpty == true
                      ? () =>
                          _copyToClipboard(context, _contact.address2!, '地址2')
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
