import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class YTSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;

  const YTSearchField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(HugeIcons.strokeRoundedSearch01),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(HugeIcons.strokeRoundedCancelCircle),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
