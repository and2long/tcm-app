import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
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

  // 构建输入框
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isRequired = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: isRequired ? '$label *' : label,
          hintText: hint,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          hintStyle: TextStyle(
            color:
                Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  // 构建性别选择字段
  Widget _buildGenderField() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedGender,
        decoration: InputDecoration(
          labelText: '性别',
          hintText: '请选择性别',
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              HugeIcons.strokeRoundedUser,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
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
      ),
    );
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
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          title: Text(_isEditMode ? '编辑联系人' : '新建联系人'),
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // 表单区域
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 姓名输入框
                      _buildInputField(
                        controller: _nameController,
                        label: '姓名',
                        hint: '请输入联系人姓名',
                        icon: HugeIcons.strokeRoundedUser,
                        isRequired: true,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '请输入联系人姓名';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // 性别选择
                      _buildGenderField(),
                      const SizedBox(height: 20),

                      // 手机号输入框
                      _buildInputField(
                        controller: _phoneController,
                        label: '手机号',
                        hint: '请输入手机号',
                        icon: HugeIcons.strokeRoundedCall,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            if (!RegExp(r'^1[3-9]\d{9}$')
                                .hasMatch(value.trim())) {
                              return '请输入正确的手机号格式';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // 地址1输入框
                      _buildInputField(
                        controller: _address1Controller,
                        label: '地址1',
                        hint: '请输入地址信息',
                        icon: HugeIcons.strokeRoundedLocation01,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 20),

                      // 地址2输入框
                      _buildInputField(
                        controller: _address2Controller,
                        label: '地址2',
                        hint: '请输入备用地址信息',
                        icon: HugeIcons.strokeRoundedLocation02,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 40),

                      // 保存按钮
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _saveContact,
                          icon: Icon(_isEditMode
                              ? HugeIcons.strokeRoundedCheckmarkCircle02
                              : HugeIcons.strokeRoundedUserAdd01),
                          label: Text(_isEditMode ? '保存修改' : '创建联系人'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
