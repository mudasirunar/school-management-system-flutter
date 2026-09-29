import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';
import '../utils/debouncer.dart';

class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    this.controller,
    this.hint = 'Search...',
    this.onChanged,
    this.onClear,
    this.debounceMs = 300,
  });

  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final int debounceMs;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final TextEditingController _controller;
  late final Debouncer _debouncer;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _debouncer = Debouncer(milliseconds: widget.debounceMs);
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_updateState);
  }

  void _updateState() {
    final bool hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_updateState);
    if (widget.controller == null) {
      _controller.dispose();
    }
    _debouncer.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    _debouncer.run(() {
      widget.onChanged?.call(value);
    });
  }

  void _clear() {
    _controller.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SizedBox(
      height: 48,
      child: TextField(
        controller: _controller,
        onChanged: _onTextChanged,
        style: theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: widget.hint,
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: _hasText
              ? IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  tooltip: 'Clear search',
                  onPressed: _clear,
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          filled: true,
          fillColor: theme.colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(color: theme.colorScheme.outline, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(color: theme.colorScheme.outline, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}
