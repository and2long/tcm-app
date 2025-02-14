import 'package:flutter/material.dart';

class SearchSelectField<T> extends StatefulWidget {
  final String label;
  final String hint;
  final List<T> items;
  final T? value;
  final String Function(T) getLabel;
  final Function(T?) onChanged;
  final String? Function(T?)? validator;

  const SearchSelectField({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    required this.value,
    required this.getLabel,
    required this.onChanged,
    this.validator,
  });

  @override
  State<SearchSelectField<T>> createState() => _SearchSelectFieldState<T>();
}

class _SearchSelectFieldState<T> extends State<SearchSelectField<T>> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    if (widget.value != null) {
      _controller.text = widget.getLabel(widget.value as T);
    }
  }

  @override
  void didUpdateWidget(SearchSelectField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _controller.text =
          widget.value != null ? widget.getLabel(widget.value as T) : '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showSelectionSheet() {
    if (widget.value != null) {
      _searchController.text = widget.getLabel(widget.value as T);
      _searchText = _searchController.text;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return StatefulBuilder(
                  builder: (context, setState) {
                    final sortedItems = List<T>.from(widget.items);
                    if (_searchText.isNotEmpty) {
                      sortedItems.sort((a, b) {
                        final labelA = widget.getLabel(a).toLowerCase();
                        final labelB = widget.getLabel(b).toLowerCase();
                        final searchLower = _searchText.toLowerCase();
                        final aContains = labelA.contains(searchLower);
                        final bContains = labelB.contains(searchLower);

                        if (aContains && !bContains) return -1;
                        if (!aContains && bContains) return 1;

                        return labelA.compareTo(labelB);
                      });
                    }

                    return Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '选择${widget.label}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: TextField(
                            controller: _searchController,
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: widget.hint,
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: _searchText.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        setState(() {
                                          _searchController.clear();
                                          _searchText = '';
                                        });
                                      },
                                    )
                                  : null,
                              border: const OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _searchText = value;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            controller: scrollController,
                            itemCount: sortedItems.length,
                            itemBuilder: (context, index) {
                              final item = sortedItems[index];
                              final isSelected = widget.value == item;
                              final itemLabel = widget.getLabel(item);
                              final isMatch = _searchText.isEmpty ||
                                  itemLabel
                                      .toLowerCase()
                                      .contains(_searchText.toLowerCase());

                              return ListTile(
                                title: Text(
                                  itemLabel,
                                  style: TextStyle(
                                    color: isMatch
                                        ? null
                                        : Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color
                                            ?.withValues(alpha: 0.5),
                                  ),
                                ),
                                selected: isSelected,
                                trailing: isSelected
                                    ? const Icon(Icons.check,
                                        color: Colors.blue)
                                    : null,
                                onTap: () {
                                  widget.onChanged(item);
                                  _controller.text = itemLabel;
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    ).whenComplete(() {
      _searchController.clear();
      _searchText = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        suffixIcon: IconButton(
          icon: const Icon(Icons.arrow_drop_down),
          onPressed: _showSelectionSheet,
        ),
      ),
      onTap: _showSelectionSheet,
      validator: widget.validator != null
          ? (value) => widget.validator!(widget.value)
          : null,
    );
  }
}
