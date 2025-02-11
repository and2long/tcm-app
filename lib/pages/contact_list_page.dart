import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tcm/components/yt_tile.dart';
import 'package:tcm/core/blocs/contact/contact_cubit.dart';
import 'package:tcm/core/blocs/contact/contact_state.dart';
import 'package:tcm/models/contact.dart';

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
          setState(() {
            _contacts.clear();
            _contacts.addAll(state.contacts);
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('联系人管理'),
        ),
        body: RefreshIndicator(
          onRefresh: () {
            context.read<ContactCubit>().getContactList();
            return Future.value();
          },
          child: ListView.builder(
            itemBuilder: (context, index) {
              final contact = _contacts[index];
              return YTTile(
                title: contact.name,
              );
            },
            itemCount: _contacts.length,
          ),
        ),
      ),
    );
  }
}
