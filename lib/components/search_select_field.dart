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
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  bool _isOpen = false;
  String _searchText = '';
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
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
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _showOverlay() {
    _isOpen = true;
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _isOpen = false;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 5.0),
          child: Material(
            elevation: 4.0,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 200),
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: widget.items
                    .where((item) => widget
                        .getLabel(item)
                        .toLowerCase()
                        .contains(_searchText.toLowerCase()))
                    .map((item) => ListTile(
                          title: Text(widget.getLabel(item)),
                          onTap: () {
                            widget.onChanged(item);
                            _controller.text = widget.getLabel(item);
                            _removeOverlay();
                            _focusNode.unfocus();
                          },
                        ))
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        controller: _controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          suffixIcon: IconButton(
            icon: Icon(_isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down),
            onPressed: () {
              if (_isOpen) {
                _focusNode.unfocus();
              } else {
                _focusNode.requestFocus();
              }
            },
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchText = value;
            if (_overlayEntry != null) {
              _overlayEntry!.markNeedsBuild();
            }
          });
        },
        validator: widget.validator != null
            ? (value) => widget.validator!(widget.value)
            : null,
      ),
    );
  }
}
