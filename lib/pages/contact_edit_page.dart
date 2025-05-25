import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tcm/core/blocs/contact/contact_cubit.dart';
import 'package:tcm/core/blocs/contact/contact_state.dart';
import 'package:tcm/models/contact.dart';
import 'package:tcm/providers/app_provider.dart';

class ContactEditPage extends StatefulWidget {
  final Contact? contact; // 如果为 null 则为创建模式

  const ContactEditPage({
    super.key,
    this.contact,
  });

  @override
  State<ContactEditPage> createState() => _ContactEditPageState();
}

class _ContactEditPageState extends State<ContactEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _address1Controller = TextEditingController();
  final _address2Controller = TextEditingController();

  String? _selectedGender;
  final List<String> _genderOptions = ['男', '女'];

  bool get _isEditMode => widget.contact != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _nameController.text = widget.contact!.name;
      _phoneController.text = widget.contact!.phone ?? '';
      _address1Controller.text = widget.contact!.address1 ?? '';
      _address2Controller.text = widget.contact!.address2 ?? '';
      _selectedGender = widget.contact!.gender;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    super.dispose();
  }

  void _saveContact() {
    if (_formKey.currentState!.validate()) {
      final cubit = context.read<ContactCubit>();
      final payload = ContactPayload(
        name: _nameController.text.trim(),
        gender: _selectedGender,
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        address1: _address1Controller.text.trim().isEmpty
            ? null
            : _address1Controller.text.trim(),
        address2: _address2Controller.text.trim().isEmpty
            ? null
            : _address2Controller.text.trim(),
      );
      if (_isEditMode) {
        cubit.updateContact(widget.contact!.id, payload);
      } else {
        cubit.createContact(payload);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ContactCubit, ContactState>(
      listener: (context, state) {
        if (state is ContactUpdateSuccessState) {
          context.read<AppProvider>().updateContact(state.contact);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('修改成功')),
          );
          Navigator.pop(context);
        } else if (state is ContactCreateSuccessState) {
          final provider = context.read<AppProvider>();
          final contacts = List<Contact>.from(provider.contacts);
          contacts.add(state.contact);
          contacts.sort((a, b) => a.name.compareTo(b.name));
          provider.setContacts(contacts);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('创建成功')),
          );
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditMode ? '编辑联系人' : '新建联系人'),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // 姓名输入框
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '姓名 *',
                  hintText: '请输入联系人姓名',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入联系人姓名';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 性别选择
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(
                  labelText: '性别',
                  border: OutlineInputBorder(),
                ),
                items: _genderOptions.map((gender) {
                  return DropdownMenuItem<String>(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                hint: const Text('请选择性别'),
              ),
              const SizedBox(height: 16),

              // 手机号输入框
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: '手机号',
                  hintText: '请输入手机号',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    // 简单的手机号验证
                    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(value.trim())) {
                      return '请输入正确的手机号格式';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 地址1输入框
              TextFormField(
                controller: _address1Controller,
                decoration: const InputDecoration(
                  labelText: '地址1',
                  hintText: '请输入地址信息',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // 地址2输入框
              TextFormField(
                controller: _address2Controller,
                decoration: const InputDecoration(
                  labelText: '地址2',
                  hintText: '请输入备用地址信息',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 32),

              // 保存按钮
              FilledButton(
                onPressed: _saveContact,
                child: Text(_isEditMode ? '保存修改' : '创建联系人'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
