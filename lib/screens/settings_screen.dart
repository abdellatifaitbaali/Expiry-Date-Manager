import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/item_provider.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppConstants.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: AppConstants.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App info section
            _buildSectionHeader('About'),
            const SizedBox(height: 12),
            _buildInfoCard(),
            const SizedBox(height: 24),

            // Legal section
            _buildSectionHeader('Legal'),
            const SizedBox(height: 12),
            _buildLegalCard(context),
            const SizedBox(height: 24),

            // Data section
            _buildSectionHeader('Data'),
            const SizedBox(height: 12),
            _buildDataCard(context),
            const SizedBox(height: 24),

            // Slots section
            _buildSectionHeader('Storage'),
            const SizedBox(height: 12),
            _buildSlotsCard(context),
            const SizedBox(height: 32),

            // Developer info
            _buildDeveloperInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppConstants.secondaryColor,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildInfoCard() {
    return _buildCard(
      children: [
        _buildRow(
          icon: Icons.timer_rounded,
          title: AppConstants.appName,
          subtitle: 'Version ${AppConstants.appVersion}',
        ),
        const Divider(color: Colors.white10, height: 24),
        _buildRow(
          icon: Icons.info_outline_rounded,
          title: 'Track expiry dates, reduce waste',
          subtitle: 'Scan barcodes or type items manually',
        ),
      ],
    );
  }

  Widget _buildLegalCard(BuildContext context) {
    return _buildCard(
      children: [
        _buildTappableRow(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy Policy',
          onTap: () => _launchUrl(AppConstants.privacyPolicyUrl),
        ),
        const Divider(color: Colors.white10, height: 24),
        _buildTappableRow(
          icon: Icons.description_outlined,
          title: 'Terms of Service',
          onTap: () => _launchUrl(AppConstants.termsOfServiceUrl),
        ),
      ],
    );
  }

  Widget _buildDataCard(BuildContext context) {
    return _buildCard(
      children: [
        _buildTappableRow(
          icon: Icons.delete_forever_rounded,
          title: 'Delete All Data',
          titleColor: AppConstants.expiredColor,
          onTap: () => _showDeleteDialog(context),
        ),
      ],
    );
  }

  Widget _buildSlotsCard(BuildContext context) {
    return Consumer<ItemProvider>(
      builder: (context, provider, child) {
        final usedPercent = provider.maxSlots > 0
            ? provider.totalItems / provider.maxSlots
            : 0.0;

        return _buildCard(
          children: [
            Row(
              children: [
                const Icon(Icons.inventory_rounded,
                    color: AppConstants.textSecondary, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${provider.totalItems} / ${provider.maxSlots} slots used',
                        style: const TextStyle(
                          color: AppConstants.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: usedPercent.clamp(0.0, 1.0),
                          backgroundColor: AppConstants.surfaceColor,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            usedPercent > 0.8
                                ? AppConstants.expiredColor
                                : AppConstants.secondaryColor,
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!provider.canAddItem) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final success = await provider.unlockBonusSlots();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? '🎉 10 bonus slots unlocked!'
                                : 'Video not available. Try again later.',
                          ),
                          backgroundColor: AppConstants.surfaceColor,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.play_circle_outline_rounded, size: 20),
                  label: const Text('Watch video for +10 slots'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.secondaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildDeveloperInfo() {
    return Center(
      child: Column(
        children: [
          Text(
            'Developed by ${AppConstants.organizationName}',
            style: TextStyle(
              color: AppConstants.textSecondary.withValues(alpha: 0.5),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => _launchUrl(AppConstants.websiteUrl),
            child: Text(
              AppConstants.websiteUrl,
              style: TextStyle(
                color: AppConstants.secondaryColor.withValues(alpha: 0.6),
                fontSize: 13,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildRow({
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppConstants.textSecondary, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppConstants.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppConstants.textSecondary.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTappableRow({
    required IconData icon,
    required String title,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(icon, color: titleColor ?? AppConstants.textSecondary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: titleColor ?? AppConstants.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: AppConstants.textSecondary.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppConstants.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete All Data?',
          style: TextStyle(color: AppConstants.textPrimary),
        ),
        content: const Text(
          'This will permanently remove all tracked items and their notifications. This action cannot be undone.',
          style: TextStyle(color: AppConstants.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppConstants.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ItemProvider>().deleteAllItems();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All data has been deleted.'),
                  backgroundColor: AppConstants.surfaceColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.expiredColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
