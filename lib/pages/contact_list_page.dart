import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tcm/components/yt_tile.dart';
import 'package:tcm/core/blocs/contact/contact_cubit.dart';
import 'package:tcm/core/blocs/contact/contact_state.dart';
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final contacts = context.watch<AppProvider>().contacts;

    return BlocListener<ContactCubit, ContactState>(
      listener: (context, state) {
        if (state is ContactCreateSuccessState) {
          context.read<AppProvider>().addContact(state.contact);
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
              icon: const Icon(Icons.person_add),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => _CreateContactDialog(),
                );
              },
            ),
          ],
        ),
        body: RefreshIndicator(
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
              final contact = contacts[index];
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
                confirmDismiss: (DismissDirection direction) {
                  // 显示确认对话框
                  return showDialog(
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
              );
            },
            itemCount: contacts.length,
          ),
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
