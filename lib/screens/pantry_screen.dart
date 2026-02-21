import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/item_provider.dart';
import '../utils/constants.dart';
import '../widgets/item_card.dart';

class PantryScreen extends StatelessWidget {
  const PantryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ItemProvider>(
      builder: (context, provider, child) {
        final urgentItems = provider.expiringToday;

        if (urgentItems.isEmpty) {
          return _buildClearState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: urgentItems.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildHeader(urgentItems.length);
            }
            final item = urgentItems[index - 1];
            return ItemCard(
              item: item,
              onDelete: () => provider.deleteItem(item.id),
              onMarkUsed: () {
                provider.markAsUsed(item.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ ${item.name} marked as used!'),
                    backgroundColor: AppConstants.surfaceColor,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(int count) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.expiredColor.withValues(alpha: 0.15),
            AppConstants.warningColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppConstants.warningColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppConstants.warningColor,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count item${count == 1 ? '' : 's'} need${count == 1 ? 's' : ''} attention!',
                  style: const TextStyle(
                    color: AppConstants.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'These items are expiring today or already expired.',
                  style: TextStyle(
                    color: AppConstants.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClearState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppConstants.safeColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              size: 56,
              color: AppConstants.safeColor,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'All clear! 🎉',
            style: TextStyle(
              color: AppConstants.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No items expiring today.\nKeep tracking your products!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppConstants.textSecondary.withValues(alpha: 0.7),
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
