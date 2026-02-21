import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'Expiry Date Manager';
  static const String appVersion = '1.0.0';
  static const String developerName = 'NEXO Dev';
  static const String organizationName = 'nexoDev LLC';
  static const String websiteUrl = 'https://edm.nexodev.site/';
  static const String contactEmail = 'contact@nexodev.site';
  static const String privacyPolicyUrl =
      'https://edm.nexodev.site/privacy-policy.html';
  static const String termsOfServiceUrl =
      'https://edm.nexodev.site/terms-of-service.html';

  // Free Tier Limits
  static const int maxFreeSlots = 20;
  static const int rewardedSlotBonus = 10;

  // Ad Trigger
  static const int interstitialTriggerCount = 3;

  // Notification Days
  static const int earlyWarningDays = 3;
  static const int urgentWarningDays = 1;

  // AdMob IDs (TEST IDs — replace with production before release)
  static const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String interstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String rewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';
  // Android test app ID
  static const String admobAppId = 'ca-app-pub-3940256099942544~3347511713';

  // Colors
  static const Color primaryColor = Color(0xFF2E7D32); // Deep green
  static const Color secondaryColor = Color(0xFF66BB6A); // Light green
  static const Color accentColor = Color(0xFFFF8F00); // Amber
  static const Color expiredColor = Color(0xFFD32F2F); // Red
  static const Color warningColor = Color(0xFFFF6F00); // Orange
  static const Color cautionColor = Color(0xFFFBC02D); // Yellow
  static const Color safeColor = Color(0xFF43A047); // Green
  static const Color surfaceColor = Color(0xFF1A1A2E); // Dark blue-black
  static const Color cardColor = Color(0xFF16213E); // Dark navy
  static const Color backgroundColor = Color(0xFF0F0F1E); // Deep dark
  static const Color textPrimary = Color(0xFFE8E8E8);
  static const Color textSecondary = Color(0xFFB0B0B0);

  // Categories
  static const Map<String, IconData> categoryIcons = {
    'food': Icons.restaurant_rounded,
    'medicine': Icons.medical_services_rounded,
    'cosmetics': Icons.face_rounded,
    'other': Icons.inventory_2_rounded,
  };
}
