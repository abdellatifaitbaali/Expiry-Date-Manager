import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../providers/item_provider.dart';
import '../services/ad_service.dart';
import '../utils/constants.dart';
import '../utils/date_helpers.dart';
import '../widgets/item_card.dart';
import 'add_item_screen.dart';
import 'pantry_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AdService _adService = AdService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllItemsTab(),
                const PantryScreen(),
              ],
            ),
          ),
          // Banner Ad
          _buildBannerAd(),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppConstants.surfaceColor,
      elevation: 0,
      title: const Row(
        children: [
          Icon(Icons.timer_rounded,
              color: AppConstants.secondaryColor, size: 28),
          SizedBox(width: 10),
          Text(
            'Expiry Tracker',
            style: TextStyle(
              color: AppConstants.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_rounded,
              color: AppConstants.textSecondary),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: AppConstants.secondaryColor,
        indicatorWeight: 3,
        labelColor: AppConstants.secondaryColor,
        unselectedLabelColor: AppConstants.textSecondary,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        tabs: const [
          Tab(text: 'All Items', icon: Icon(Icons.list_rounded, size: 22)),
          Tab(
              text: 'Use Today',
              icon: Icon(Icons.warning_amber_rounded, size: 22)),
        ],
      ),
    );
  }

  Widget _buildAllItemsTab() {
    return Consumer<ItemProvider>(
      builder: (context, provider, child) {
        if (provider.items.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            // Stats bar
            _buildStatsBar(provider),
            // Items list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: provider.items.length,
                itemBuilder: (context, index) {
                  final item = provider.items[index];
                  return ItemCard(
                    item: item,
                    onDelete: () {
                      provider.deleteItem(item.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${item.name} removed'),
                          backgroundColor: AppConstants.surfaceColor,
                          action: SnackBarAction(
                            label: 'Undo',
                            textColor: AppConstants.secondaryColor,
                            onPressed: () {
                              provider.addItem(
                                name: item.name,
                                category: item.category,
                                expiryDate: item.expiryDate,
                                barcode: item.barcode,
                                quantity: item.quantity,
                                notes: item.notes,
                              );
                            },
                          ),
                        ),
                      );
                    },
                    onTap: () => _navigateToEdit(item),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsBar(ItemProvider provider) {
    final expiredCount = provider.items
        .where(
          (i) => DateHelpers.daysUntilExpiry(i.expiryDate) < 0,
        )
        .length;
    final soonCount = provider.expiringSoon.length;
    final todayCount = provider.expiringToday.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statChip(
              'Total', '${provider.totalItems}', AppConstants.textSecondary),
          _statChip('Expired', '$expiredCount', AppConstants.expiredColor),
          _statChip('Today', '$todayCount', AppConstants.warningColor),
          _statChip('Soon', '$soonCount', AppConstants.cautionColor),
          _statChip(
            'Slots',
            '${provider.totalItems}/${provider.maxSlots}',
            provider.canAddItem
                ? AppConstants.safeColor
                : AppConstants.expiredColor,
          ),
        ],
      ),
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: AppConstants.textSecondary.withValues(alpha: 0.6),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: AppConstants.textSecondary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'No items tracked yet',
            style: TextStyle(
              color: AppConstants.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first item',
            style: TextStyle(
              color: AppConstants.textSecondary.withValues(alpha: 0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerAd() {
    if (!_adService.isBannerLoaded || _adService.bannerAd == null) {
      return const SizedBox(height: 50);
    }
    return Container(
      color: AppConstants.surfaceColor,
      width: double.infinity,
      height: _adService.bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _adService.bannerAd!),
    );
  }

  Widget _buildFAB() {
    return Consumer<ItemProvider>(
      builder: (context, provider, child) {
        return FloatingActionButton.extended(
          onPressed: () async {
            if (!provider.canAddItem) {
              _showSlotLimitDialog();
              return;
            }
            final result = await Navigator.push<bool>(
              context,
              MaterialPageRoute(builder: (_) => const AddItemScreen()),
            );
            if (result == true && _adService.shouldShowInterstitial()) {
              _adService.showInterstitial();
            }
          },
          backgroundColor: AppConstants.primaryColor,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text(
            'Add Item',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        );
      },
    );
  }

  void _showSlotLimitDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppConstants.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Pantry Full!',
          style: TextStyle(color: AppConstants.textPrimary),
        ),
        content: const Text(
          'You\'ve reached the maximum number of items. Watch a short video to unlock 10 more slots!',
          style: TextStyle(color: AppConstants.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppConstants.textSecondary)),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = context.read<ItemProvider>();
              final success = await provider.unlockBonusSlots();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? '🎉 10 bonus slots unlocked!'
                          : 'Video not available, try again later.',
                    ),
                    backgroundColor: AppConstants.surfaceColor,
                  ),
                );
              }
            },
            icon: const Icon(Icons.play_circle_outline_rounded, size: 20),
            label: const Text('Watch Video'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.secondaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToEdit(item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddItemScreen(editItem: item)),
    );
  }
}
