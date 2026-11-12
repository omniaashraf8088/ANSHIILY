enum SubscriptionTier {
  free('الباقة المجانية (Free)', 'free'),
  premium('أنشئلي بريميوم (ANSHIILY Pro)', 'premium');

  final String labelAr;
  final String key;
  const SubscriptionTier(this.labelAr, this.key);

  bool get isPremium => this == SubscriptionTier.premium;
}

enum BillingCycle {
  monthly('شهرياً', 'monthly'),
  yearly('سنوياً', 'yearly');

  final String labelAr;
  final String key;
  const BillingCycle(this.labelAr, this.key);
}

enum SubscriptionStatus {
  active('نشط'),
  trialing('فترة تجريبية'),
  canceled('تم الإلغاء'),
  expired('منتهي الصلاحية'),
  none('غير مشترك');

  final String labelAr;
  const SubscriptionStatus(this.labelAr);
}

enum FeatureEntitlement {
  printQualityExport300Dpi('تصدير بجودة الطباعة الفائقة 300 DPI'),
  multiPagePdfExport('تصدير مستندات PDF متعددة الصفحات'),
  unlimitedAiGenerations('توليد غير محدود للتصاميم بالذكاء الاصطناعي'),
  vipTemplatesAccess('وصول حصري لجميع قوالب VIP الفاخرة'),
  cloudStorage10Gb('مساحة تخزين سحابية موسعة 10 جيجابايت');

  final String descriptionAr;
  const FeatureEntitlement(this.descriptionAr);

  bool isAvailableFor(SubscriptionTier tier) {
    if (tier == SubscriptionTier.premium) return true;
    // Free tier has basic access to standard features; premium features require Pro tier
    return false;
  }
}

class SubscriptionProduct {
  final String id;
  final String title;
  final String description;
  final double price;
  final String priceString;
  final String currencyCode;
  final BillingCycle cycle;
  final bool isAvailableInStore;
  final String? discountBadge;

  const SubscriptionProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.priceString,
    required this.currencyCode,
    required this.cycle,
    this.isAvailableInStore = false,
    this.discountBadge,
  });

  /// Fallback test products when Store credentials / RevenueCat is in Sandbox
  static const SubscriptionProduct fallbackMonthly = SubscriptionProduct(
    id: 'anshiily_pro_monthly',
    title: 'بريميوم شهري',
    description: 'وصول كامل لجميع المزايا الاحترافية وتصدير 300 DPI',
    price: 9.99,
    priceString: '\$9.99 / شهر',
    currencyCode: 'USD',
    cycle: BillingCycle.monthly,
    isAvailableInStore: false,
  );

  static const SubscriptionProduct fallbackYearly = SubscriptionProduct(
    id: 'anshiily_pro_yearly',
    title: 'بريميوم سنوي',
    description: 'وفر 35% مع الدفع السنوي وتجديد تلقائي مرن',
    price: 79.99,
    priceString: '\$79.99 / سنة',
    currencyCode: 'USD',
    cycle: BillingCycle.yearly,
    isAvailableInStore: false,
    discountBadge: 'وفر 35% ★',
  );
}

class CustomerSubscription {
  final SubscriptionTier tier;
  final SubscriptionStatus status;
  final List<String> activeEntitlements;
  final DateTime? currentPeriodStart;
  final DateTime? currentPeriodEnd;
  final DateTime? originalPurchaseDate;
  final bool isSandbox;
  final String? productId;

  const CustomerSubscription({
    required this.tier,
    required this.status,
    this.activeEntitlements = const [],
    this.currentPeriodStart,
    this.currentPeriodEnd,
    this.originalPurchaseDate,
    this.isSandbox = true,
    this.productId,
  });

  factory CustomerSubscription.free() {
    return const CustomerSubscription(
      tier: SubscriptionTier.free,
      status: SubscriptionStatus.none,
      activeEntitlements: [],
      isSandbox: true,
    );
  }

  factory CustomerSubscription.fromSupabase(Map<String, dynamic> json) {
    final plan = json['plan_type'] as String? ?? 'free';
    final statusStr = json['status'] as String? ?? 'active';
    final tier = (plan == 'premium' || plan == 'pro')
        ? SubscriptionTier.premium
        : SubscriptionTier.free;

    SubscriptionStatus status;
    switch (statusStr.toLowerCase()) {
      case 'active':
        status = SubscriptionStatus.active;
        break;
      case 'canceled':
        status = SubscriptionStatus.canceled;
        break;
      case 'expired':
        status = SubscriptionStatus.expired;
        break;
      case 'trialing':
        status = SubscriptionStatus.trialing;
        break;
      default:
        status = SubscriptionStatus.none;
    }

    final endStr = json['current_period_end'] as String?;
    final startStr = json['current_period_start'] as String?;

    return CustomerSubscription(
      tier: tier,
      status: status,
      activeEntitlements: tier.isPremium
          ? FeatureEntitlement.values.map((e) => e.name).toList()
          : [],
      currentPeriodStart: startStr != null ? DateTime.tryParse(startStr) : null,
      currentPeriodEnd: endStr != null ? DateTime.tryParse(endStr) : null,
      isSandbox: false,
    );
  }

  bool get isActive =>
      status == SubscriptionStatus.active ||
      status == SubscriptionStatus.trialing;

  bool get isPremiumActive => tier == SubscriptionTier.premium && isActive;
}

