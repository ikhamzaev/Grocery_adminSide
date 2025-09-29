import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class CustomerSearchBar extends StatefulWidget {
  final Function(String) onSearchChanged;
  final String hintText;
  final String? initialValue;

  const CustomerSearchBar({
    Key? key,
    required this.onSearchChanged,
    required this.hintText,
    this.initialValue,
  }) : super(key: key);

  @override
  State<CustomerSearchBar> createState() => _CustomerSearchBarState();
}

class _CustomerSearchBarState extends State<CustomerSearchBar> {
  late TextEditingController _controller;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
    _isSearching = widget.initialValue?.isNotEmpty ?? false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _isSearching = value.isNotEmpty;
    });
    widget.onSearchChanged(value);
  }

  void _clearSearch() {
    _controller.clear();
    _onSearchChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isSearching 
              ? AppTheme.lightTheme.colorScheme.primary.withOpacity(0.3)
              : AppTheme.borderLight,
          width: 1,
        ),
        boxShadow: _isSearching ? [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: TextField(
        controller: _controller,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.5),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: _isSearching 
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.5),
          ),
          suffixIcon: _isSearching
              ? IconButton(
                  onPressed: _clearSearch,
                  icon: Icon(
                    Icons.clear,
                    color: AppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        style: AppTheme.lightTheme.textTheme.bodyLarge,
      ),
    );
  }
}
