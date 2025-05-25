import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_ytnavigator/flutter_ytnavigator.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:pinyin/pinyin.dart';
import 'package:tcm/components/yt_search_field.dart';
import 'package:tcm/components/yt_tile.dart';
import 'package:tcm/core/blocs/contact/contact_cubit.dart';
import 'package:tcm/core/blocs/contact/contact_state.dart';
import 'package:tcm/models/contact.dart';
import 'package:tcm/pages/contact_edit_page.dart';
import 'package:tcm/providers/app_provider.dart';

class ContactListPage extends StatefulWidget {
  const ContactListPage({super.key});

  @override
  State<ContactListPage> createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _searchController = TextEditingController();
  String _searchText = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Contact> _getFilteredContacts(List<Contact> contacts) {
    if (_searchText.isEmpty) return contacts;
    return contacts
        .where((contact) =>
            contact.name.toLowerCase().contains(_searchText.toLowerCase()) ||
            PinyinHelper.getShortPinyin(contact.name)
                .contains(_searchText.toLowerCase()))
        .toList();
  }

  Widget _buildSearchBar() {
    return YTSearchField(
      controller: _searchController,
      hintText: '搜索客户...',
      onChanged: (value) {
        setState(() {
          _searchText = value;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final allContacts = context.watch<AppProvider>().contacts;
    final filteredContacts = _getFilteredContacts(allContacts);

    return BlocListener<ContactCubit, ContactState>(
      listener: (context, state) {
        if (state is ContactCreateSuccessState) {
          List<Contact> items = context.read<AppProvider>().contacts;
          items.add(state.contact);
          items.sort((a, b) => PinyinHelper.getShortPinyin(a.name)
              .compareTo(PinyinHelper.getShortPinyin(b.name)));
          context.read<AppProvider>().setContacts(items);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('创建成功')),
          );
        }
        if (state is ContactDeleteScuuessState) {
          context.read<AppProvider>().removeContact(state.id);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('删除成功')),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('联系人管理'),
          actions: [
            IconButton(
              icon: const Icon(HugeIcons.strokeRoundedUserAdd01),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => _CreateContactDialog(),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  final cubit = context.read<ContactCubit>();
                  final provider = context.read<AppProvider>();
                  final contacts = await cubit.getContactList();
                  if (!mounted) return;
                  if (contacts != null) {
                    provider.setContacts(contacts);
                  }
                },
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    final contact = filteredContacts[index];
                    return Slidable(
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (c) {
                              NavigatorUtil.push(
                                context,
                                ContactEditPage(contact: contact),
                              );
                            },
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            icon: HugeIcons.strokeRoundedEditUser02,
                          ),
                          SlidableAction(
                            onPressed: (c) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('确认删除'),
                                    content: Text('确认删除 ${contact.name} 吗？'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('取消'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: const Text('确认'),
                                        onPressed: () {
                                          context
                                              .read<ContactCubit>()
                                              .deleteContact(contact.id);
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: HugeIcons.strokeRoundedDelete02,
                          ),
                        ],
                      ),
                      child: YTTile(title: '${index + 1}. ${contact.name}'),
                    );
                  },
                  itemCount: filteredContacts.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateContactDialog extends StatefulWidget {
  @override
  State<_CreateContactDialog> createState() => _CreateContactDialogState();
}

class _CreateContactDialogState extends State<_CreateContactDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('新建联系人'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          autocorrect: false,
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: '姓名',
            hintText: '请输入姓名',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '请输入姓名';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              context
                  .read<ContactCubit>()
                  .createContact(_nameController.text.trim());
              Navigator.pop(context);
            }
          },
          child: const Text('确定'),
        ),
      ],
    );
  }
}
