import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../models/subscription_models.dart';
import '../services/subscription_service.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  CustomerSubscription _subscription = CustomerSubscription.free();
  List<SubscriptionProduct> _products = [];
  SubscriptionProduct? _selectedProduct;
  bool _isLoading = true;
  bool _isPurchasing = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final sub = await SubscriptionService.instance.refreshSubscription();
    final prods = await SubscriptionService.instance.getAvailableProducts();

    if (!mounted) return;
    setState(() {
      _subscription = sub;
      _products = prods;
      // Default select the yearly product if available
      _selectedProduct = prods.firstWhere(
        (p) => p.cycle == BillingCycle.yearly,
        orElse: () => prods.first,
      );
      _isLoading = false;
    });
  }

  Future<void> _handlePurchase() async {
    if (_selectedProduct == null) return;

    setState(() {
      _isPurchasing = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final updatedSub = await SubscriptionService.instance.purchaseProduct(
        _selectedProduct!,
      );
      if (!mounted) return;

      setState(() {
        _subscription = updatedSub;
        _isPurchasing = false;
        _successMessage = 'تهانينا! تم تفعيل اشتراك أنشئلي بريميوم بنجاح 🎉';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isPurchasing = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _handleRestore() async {
    setState(() {
      _isPurchasing = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final sub = await SubscriptionService.instance.restorePurchases();
      if (!mounted) return;
      setState(() {
        _subscription = sub;
        _isPurchasing = false;
        if (sub.isPremiumActive) {
          _successMessage = 'تمت استعادة اشتراكك السابق بنجاح!';
        } else {
          _errorMessage = 'لم يتم العثور على اشتراكات سابقة نشطة لهذا الحساب.';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isPurchasing = false;
        _errorMessage = 'فشلت عملية الاستعادة: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_forward_ios_rounded,
            color: AppColors.champagneGold,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'باقات الاشتراك (ANSHIILY Pro)',
          style: GoogleFonts.tajawal(
            color: AppColors.champagneGold,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.champagneGold),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. VIP Banner Header
                  _buildHeaderBanner(),
                  const SizedBox(height: 20),

                  // 2. Current Status Banner
                  _buildCurrentStatusCard(),
                  const SizedBox(height: 20),

                  // Messages
                  if (_successMessage != null) ...[
                    _buildMessageCard(_successMessage!, Colors.greenAccent),
                    const SizedBox(height: 16),
                  ],
                  if (_errorMessage != null) ...[
                    _buildMessageCard(_errorMessage!, Colors.redAccent),
                    const SizedBox(height: 16),
                  ],

                  // 3. Plan Selection Cards
                  Text(
                    'اختر باقة الاشتراك المناسبة لك',
                    textDirection: TextDirection.rtl,
                    style: GoogleFonts.tajawal(
                      color: AppColors.champagneGold,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ..._products.map((p) => _buildProductCard(p)),
                  const SizedBox(height: 20),

                  // 4. Feature Comparison Matrix
                  Text(
                    'مقارنة المزايا بين الباقات',
                    textDirection: TextDirection.rtl,
                    style: GoogleFonts.tajawal(
                      color: AppColors.champagneGold,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildComparisonMatrix(),
                  const SizedBox(height: 24),

                  // 5. Purchase & Restore Action Buttons
                  if (!_subscription.isPremiumActive) ...[
                    ElevatedButton(
                      onPressed: _isPurchasing ? null : _handlePurchase,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.champagneGold,
                        foregroundColor: AppColors.deepNavy,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isPurchasing
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.deepNavy,
                              ),
                            )
                          : Text(
                              'اشترك الآن بـ ${_selectedProduct?.priceString ?? ""}',
                              style: GoogleFonts.tajawal(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Restore Button
                  TextButton.icon(
                    onPressed: _isPurchasing ? null : _handleRestore,
                    icon: const Icon(
                      Icons.restore_rounded,
                      color: AppColors.warmIvory,
                      size: 18,
                    ),
                    label: Text(
                      'استعادة المشتريات السابقة (Restore Purchases)',
                      style: GoogleFonts.tajawal(
                        color: AppColors.warmIvory.withValues(alpha: 0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Footer Terms & Security Note
                  _buildSecurityFooter(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF28101C), Color(0xFF131D38), Color(0xFF0B132B)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.champagneGold.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.champagneGold.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.burgundy,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'ANSHIILY PRO VIP',
              style: GoogleFonts.tajawal(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'أطلق العنان لقدراتك التصميمية',
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(
              color: AppColors.champagneGold,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'تصدير فائق الدقة 300 DPI، وتوليد غير محدود بالذكاء الاصطناعي، ووصول حصري لكل القوالب الفاخرة.',
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: GoogleFonts.tajawal(
              color: AppColors.warmIvory.withValues(alpha: 0.8),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStatusCard() {
    final bool isPro = _subscription.isPremiumActive;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceNavy,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPro
              ? Colors.greenAccent
              : AppColors.champagneGold.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isPro ? Icons.verified_rounded : Icons.account_circle_outlined,
                color: isPro ? Colors.greenAccent : AppColors.champagneGold,
                size: 24,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'حالة حسابك الحالية:',
                    style: GoogleFonts.tajawal(
                      color: AppColors.warmIvory.withValues(alpha: 0.65),
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    _subscription.tier.labelAr,
                    style: GoogleFonts.tajawal(
                      color: isPro
                          ? Colors.greenAccent
                          : AppColors.champagneGold,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isPro
                  ? Colors.greenAccent.withValues(alpha: 0.15)
                  : AppColors.deepNavy,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isPro
                    ? Colors.greenAccent
                    : AppColors.champagneGold.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              _subscription.status.labelAr,
              style: GoogleFonts.tajawal(
                color: isPro ? Colors.greenAccent : AppColors.warmIvory,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(SubscriptionProduct product) {
    final bool isSelected = _selectedProduct?.id == product.id;
    final bool isYearly = product.cycle == BillingCycle.yearly;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => setState(() => _selectedProduct = product),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.champagneGold.withValues(alpha: 0.12)
                : AppColors.surfaceNavy,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppColors.champagneGold
                  : AppColors.deepNavyMid,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.champagneGold
                        : AppColors.warmIvory.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.champagneGold,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          product.title,
                          style: GoogleFonts.tajawal(
                            color: isSelected
                                ? AppColors.champagneGold
                                : AppColors.warmIvory,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                        if (product.discountBadge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.burgundy,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              product.discountBadge!,
                              style: GoogleFonts.tajawal(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.description,
                      style: GoogleFonts.tajawal(
                        color: AppColors.warmIvory.withValues(alpha: 0.65),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    product.priceString,
                    style: GoogleFonts.tajawal(
                      color: AppColors.champagneGold,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                  if (isYearly)
                    Text(
                      'ما يعادل \$6.66/شهر',
                      style: GoogleFonts.tajawal(
                        color: Colors.greenAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComparisonMatrix() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceNavy,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.champagneGold.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        children: [
          // Header Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.deepNavy,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'الميزة (Feature)',
                    style: GoogleFonts.tajawal(
                      color: AppColors.champagneGold,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'مجاني',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.tajawal(
                      color: AppColors.warmIvory.withValues(alpha: 0.6),
                      fontSize: 11,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'بريميوم ★',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.tajawal(
                      color: AppColors.champagneGold,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.deepNavyMid),

          _buildMatrixRow('دقة التصدير', 'Standard (1x)', '300 DPI طباعة'),
          _buildMatrixRow('صيغ التصدير', 'PNG, JPG', 'PNG, JPG, PDF'),
          _buildMatrixRow('تصدير متعدد الصفحات', 'صفحة واحدة', 'غير محدود'),
          _buildMatrixRow('توليد التصاميم بالـ AI', '5 شهرياً', 'غير محدود'),
          _buildMatrixRow(
            'قوالب الهوية البصرية',
            'المجانية فقط',
            'كافة قوالب VIP',
          ),
          _buildMatrixRow('مساحة التخزين السحابي', '100 MB', '10 GB'),
        ],
      ),
    );
  }

  Widget _buildMatrixRow(String feature, String freeVal, String proVal) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              feature,
              style: GoogleFonts.tajawal(
                color: AppColors.warmIvory,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              freeVal,
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                color: AppColors.warmIvory.withValues(alpha: 0.5),
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              proVal,
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                color: AppColors.champagneGold,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard(String msg, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1.2),
      ),
      child: Text(
        msg,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
        style: GoogleFonts.tajawal(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildSecurityFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_outline_rounded,
              color: AppColors.champagneGold,
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              'دفع آمن ومعتمد عبر المتاجر الرسمية (App Store & Google Play)',
              style: GoogleFonts.tajawal(
                color: AppColors.warmIvory.withValues(alpha: 0.5),
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'يمكنك إلغاء الاشتراك في أي وقت عبر إعدادات متجر التطبيقات قبل نهاية الفترة الحالية.',
          textAlign: TextAlign.center,
          style: GoogleFonts.tajawal(
            color: AppColors.warmIvory.withValues(alpha: 0.4),
            fontSize: 9.5,
          ),
        ),
      ],
    );
  }
}
