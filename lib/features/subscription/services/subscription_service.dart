import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../core/services/supabase_service.dart';
import '../models/subscription_models.dart';

class SubscriptionService {
  SubscriptionService._();
  static final SubscriptionService instance = SubscriptionService._();

  // Environment or configured keys
  static const String _revenueCatGoogleApiKey = String.fromEnvironment(
    'REVENUECAT_GOOGLE_API_KEY',
    defaultValue: '',
  );
  static const String _revenueCatAppleApiKey = String.fromEnvironment(
    'REVENUECAT_APPLE_API_KEY',
    defaultValue: '',
  );

  bool _isInitialized = false;
  bool _isStoreConfigured = false;
  CustomerSubscription _cachedSubscription = CustomerSubscription.free();

  bool get isStoreConfigured => _isStoreConfigured;
  CustomerSubscription get currentSubscription => _cachedSubscription;

  /// Initializes the centralized billing & subscription architecture.
  Future<void> initialize() async {
    if (_isInitialized) return;

    final String apiKey = Platform.isAndroid
        ? _revenueCatGoogleApiKey
        : _revenueCatAppleApiKey;

    if (apiKey.isNotEmpty) {
      try {
        await Purchases.setLogLevel(
          kDebugMode ? LogLevel.debug : LogLevel.info,
        );
        final configuration = PurchasesConfiguration(apiKey);
        await Purchases.configure(configuration);
        _isStoreConfigured = true;
        if (kDebugMode) {
          print('✅ RevenueCat configured successfully.');
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ RevenueCat initialization notice: $e');
        }
        _isStoreConfigured = false;
      }
    } else {
      if (kDebugMode) {
        print(
          'ℹ️ RevenueCat API keys not configured in environment. Running in sandbox test mode.',
        );
      }
      _isStoreConfigured = false;
    }

    _isInitialized = true;
    await refreshSubscription();
  }

  /// Refreshes the customer's subscription status from Supabase and Store.
  Future<CustomerSubscription> refreshSubscription() async {
    try {
      final user = SupabaseService.instance.currentUser;
      if (user != null && SupabaseService.instance.client != null) {
        final response = await SupabaseService.instance.client!
            .from('subscriptions')
            .select()
            .eq('user_id', user.id)
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();

        if (response != null) {
          _cachedSubscription = CustomerSubscription.fromSupabase(response);
          return _cachedSubscription;
        }
      }

      // If store is configured, check RevenueCat customer info
      if (_isStoreConfigured) {
        final customerInfo = await Purchases.getCustomerInfo();
        final hasProEntitlement =
            customerInfo.entitlements.active.containsKey('pro') ||
            customerInfo.entitlements.active.containsKey('premium');

        if (hasProEntitlement) {
          _cachedSubscription = CustomerSubscription(
            tier: SubscriptionTier.premium,
            status: SubscriptionStatus.active,
            activeEntitlements: FeatureEntitlement.values
                .map((e) => e.name)
                .toList(),
            isSandbox: false,
          );
          return _cachedSubscription;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error refreshing subscription: $e');
      }
    }

    // Default to free if no active record found
    _cachedSubscription = CustomerSubscription.free();
    return _cachedSubscription;
  }

  /// Retrieves available subscription products from Store or fallback catalog.
  Future<List<SubscriptionProduct>> getAvailableProducts() async {
    if (_isStoreConfigured) {
      try {
        final offerings = await Purchases.getOfferings();
        final currentOffering = offerings.current;
        if (currentOffering != null &&
            currentOffering.availablePackages.isNotEmpty) {
          final List<SubscriptionProduct> products = [];
          for (final pkg in currentOffering.availablePackages) {
            final storeProduct = pkg.storeProduct;
            final isYearly = pkg.packageType == PackageType.annual;
            products.add(
              SubscriptionProduct(
                id: storeProduct.identifier,
                title: storeProduct.title,
                description: storeProduct.description,
                price: storeProduct.price,
                priceString: storeProduct.priceString,
                currencyCode: storeProduct.currencyCode,
                cycle: isYearly ? BillingCycle.yearly : BillingCycle.monthly,
                isAvailableInStore: true,
                discountBadge: isYearly ? 'وفر 35% ★' : null,
              ),
            );
          }
          if (products.isNotEmpty) return products;
        }
      } catch (e) {
        if (kDebugMode) {
          print('Notice fetching RevenueCat offerings: $e');
        }
      }
    }

    // Return the transparent fallback products with test environment status
    return [
      SubscriptionProduct.fallbackMonthly,
      SubscriptionProduct.fallbackYearly,
    ];
  }

  /// Checks if current user has an active Premium subscription.
  Future<bool> isPremium() async {
    if (!_cachedSubscription.isPremiumActive) {
      await refreshSubscription();
    }
    return _cachedSubscription.isPremiumActive;
  }

  /// Centralized entitlement check for specific features.
  Future<bool> hasEntitlement(FeatureEntitlement entitlement) async {
    final isPrem = await isPremium();
    return isPrem ? true : entitlement.isAvailableFor(SubscriptionTier.free);
  }

  /// Executes a purchase for the selected [product].
  Future<CustomerSubscription> purchaseProduct(
    SubscriptionProduct product,
  ) async {
    final user = SupabaseService.instance.currentUser;

    if (_isStoreConfigured) {
      try {
        final offerings = await Purchases.getOfferings();
        final package = offerings.current?.availablePackages.firstWhere(
          (p) => p.storeProduct.identifier == product.id,
          orElse: () => throw Exception('الحزمة المحددة غير متاحة في المتجر'),
        );

        if (package != null) {
          final customerInfo = await Purchases.purchasePackage(package);
          final hasPro =
              customerInfo.entitlements.active.containsKey('pro') ||
              customerInfo.entitlements.active.containsKey('premium');

          if (hasPro) {
            _cachedSubscription = CustomerSubscription(
              tier: SubscriptionTier.premium,
              status: SubscriptionStatus.active,
              activeEntitlements: FeatureEntitlement.values
                  .map((e) => e.name)
                  .toList(),
              isSandbox: false,
              productId: product.id,
            );
            return _cachedSubscription;
          }
        }
      } catch (e) {
        throw Exception('فشلت عملية الشراء عبر المتجر: $e');
      }
    }

    // Sandbox / Test Mode purchase flow:
    // Persists the test subscription safely in Supabase for user testing
    if (user != null && SupabaseService.instance.client != null) {
      final now = DateTime.now();
      final periodEnd = product.cycle == BillingCycle.yearly
          ? now.add(const Duration(days: 365))
          : now.add(const Duration(days: 30));

      await SupabaseService.instance.client!.from('subscriptions').insert({
        'user_id': user.id,
        'plan_type': 'premium',
        'status': 'active',
        'current_period_start': now.toIso8601String(),
        'current_period_end': periodEnd.toIso8601String(),
      });
    }

    _cachedSubscription = CustomerSubscription(
      tier: SubscriptionTier.premium,
      status: SubscriptionStatus.active,
      activeEntitlements: FeatureEntitlement.values.map((e) => e.name).toList(),
      currentPeriodStart: DateTime.now(),
      currentPeriodEnd: DateTime.now().add(const Duration(days: 30)),
      isSandbox: true,
      productId: product.id,
    );

    return _cachedSubscription;
  }

  /// Restores previous purchases.
  Future<CustomerSubscription> restorePurchases() async {
    if (_isStoreConfigured) {
      try {
        await Purchases.restorePurchases();
      } catch (e) {
        if (kDebugMode) print('Restore purchases notice: $e');
      }
    }

    await refreshSubscription();
    return _cachedSubscription;
  }

  /// Cancels subscription (sets status to canceled in sandbox test mode).
  Future<void> cancelSubscription() async {
    final user = SupabaseService.instance.currentUser;
    if (user != null && SupabaseService.instance.client != null) {
      await SupabaseService.instance.client!
          .from('subscriptions')
          .update({'status': 'canceled'})
          .eq('user_id', user.id);
    }

    await refreshSubscription();
  }
}
