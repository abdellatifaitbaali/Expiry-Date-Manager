import 'package:flutter/material.dart';
import '../models/item.dart';
import '../utils/constants.dart';
import '../utils/date_helpers.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onMarkUsed;

  const ItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.onDelete,
    this.onMarkUsed,
  });

  @override
  Widget build(BuildContext context) {
    final daysLeft = DateHelpers.daysUntilExpiry(item.expiryDate);
    final color = DateHelpers.expiryColor(item.expiryDate);
    final icon =
        AppConstants.categoryIcons[item.category] ?? Icons.inventory_2_rounded;

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppConstants.expiredColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded,
            color: AppConstants.expiredColor, size: 28),
      ),
      onDismissed: (_) => onDelete?.call(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppConstants.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Category icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 14),
                // Item info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          color: AppConstants.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateHelpers.formatDate(item.expiryDate),
                        style: TextStyle(
                          color:
                              AppConstants.textSecondary.withValues(alpha: 0.7),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                // Countdown badge
                _CountdownBadge(daysLeft: daysLeft, color: color),
                if (onMarkUsed != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onMarkUsed,
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    color: AppConstants.safeColor,
                    tooltip: 'Mark as used',
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CountdownBadge extends StatelessWidget {
  final int daysLeft;
  final Color color;

  const _CountdownBadge({required this.daysLeft, required this.color});

  @override
  Widget build(BuildContext context) {
    String label;
    if (daysLeft < 0) {
      label = '${-daysLeft}d\nago';
    } else if (daysLeft == 0) {
      label = 'Today';
    } else {
      label = '$daysLeft\ndays';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),
      ),
    );
  }
}
