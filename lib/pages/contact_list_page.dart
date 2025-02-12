import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tcm/components/yt_tile.dart';
import 'package:tcm/core/blocs/contact/contact_cubit.dart';
import 'package:tcm/core/blocs/contact/contact_state.dart';
import 'package:tcm/models/contact.dart';
import 'package:tcm/utils/toast_util.dart';

class ContactListPage extends StatefulWidget {
  const ContactListPage({super.key});

  @override
  State<ContactListPage> createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  final List<Contact> _contacts = [];

  @override
  void initState() {
    super.initState();
    context.read<ContactCubit>().getContactList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ContactCubit, ContactState>(
      listener: (BuildContext context, ContactState state) {
        if (state is ContactListSuccessState) {
          _contacts.clear();
          _contacts.addAll(state.contacts);
          _contacts.sort((a, b) => a.name.compareTo(b.name));
          setState(() {});
        }
        if (state is ContactCreateSuccessState) {
          ToastUtil.show('创建成功');
          _contacts.add(state.contact);
          _contacts.sort((a, b) => a.name.compareTo(b.name));
          setState(() {});
        }
        if (state is ContactDeleteScuuessState) {
          ToastUtil.show('删除成功');
          _contacts.removeWhere((contact) => contact.id == state.id);
          setState(() {});
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('联系人管理'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showCreateContactDialog(context),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () {
            context.read<ContactCubit>().getContactList();
            return Future.value();
          },
          child: ListView.builder(
            itemBuilder: (context, index) {
              final contact = _contacts[index];
              return Dismissible(
                key: Key(contact.id.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: YTTile(
                  title: contact.name,
                ),
                confirmDismiss: (DismissDirection direction) async {
                  // 显示确认对话框
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
                  return null;
                },
              );
            },
            itemCount: _contacts.length,
          ),
        ),
      ),
    );
  }

  void _showCreateContactDialog(BuildContext context) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新建联系人'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: '姓名',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                context
                    .read<ContactCubit>()
                    .createContact(nameController.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
