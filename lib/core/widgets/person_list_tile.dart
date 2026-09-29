import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';
import 'app_card.dart';

class PersonListTile extends StatelessWidget {
  const PersonListTile({
    super.key,
    required this.name,
    required this.subtitle,
    this.tag,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.trailing,
  });

  final String name;
  final String subtitle;
  final String? tag;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Widget? trailing;

  static String getInitials(String name) {
    final List<String> parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String initials = getInitials(name);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: <Widget>[
          // Initials Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              initials,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (tag != null) ...<Widget>[
                      const SizedBox(width: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tag!,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Trailing action
          if (trailing != null)
            trailing!
          else if (onEdit != null || onDelete != null)
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert_rounded,
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              onSelected: (String value) {
                if (value == 'edit') {
                  onEdit?.call();
                } else if (value == 'delete') {
                  onDelete?.call();
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                if (onEdit != null)
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: AppSpacing.sm),
                        Text('Edit'),
                      ],
                    ),
                  ),
                if (onDelete != null)
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        SizedBox(width: AppSpacing.sm),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
