import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

class FilterItem<T> {
  const FilterItem({
    required this.label,
    required this.value,
    this.count,
  });

  final String label;
  final T value;
  final int? count;
}

class FilterChipsRow<T> extends StatelessWidget {
  const FilterChipsRow({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onSelected,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
  });

  final List<FilterItem<T>> items;
  final T selectedValue;
  final ValueChanged<T> onSelected;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        children: items.map((FilterItem<T> item) {
          final bool isSelected = item.value == selectedValue;

          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs),
            child: FilterChip(
              selected: isSelected,
              showCheckmark: false,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    item.label,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  if (item.count != null) ...<Widget>[
                    const SizedBox(width: AppSpacing.xxs),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary.withAlpha(40)
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${item.count}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              selectedColor: theme.colorScheme.primaryContainer,
              backgroundColor: theme.colorScheme.surface,
              side: BorderSide(
                color: isSelected
                    ? theme.colorScheme.primary.withAlpha(120)
                    : theme.colorScheme.outline,
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: AppSpacing.borderRadiusChip,
              ),
              onSelected: (_) => onSelected(item.value),
            ),
          );
        }).toList(),
      ),
    );
  }
}
