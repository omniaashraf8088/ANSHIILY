import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

import 'package:anshiily/features/templates/models/document_structure.dart';
import 'package:anshiily/features/export/models/export_options.dart';
import 'package:anshiily/features/export/services/canvas_render_service.dart';
import 'package:anshiily/features/export/services/pdf_export_service.dart';
import 'package:anshiily/features/subscription/models/subscription_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 6: Professional Export Engine Tests', () {
    late TemplateDocument testDocument;

    setUp(() {
      testDocument = TemplateDocument(
        pages: [
          DocumentPage(
            id: 'page_1',
            background: const PageBackground(color: '#0B132B'),
            elements: [
              const DocumentElement(
                id: 'el_title',
                type: 'text',
                content: 'تصميم أنشئلي الفاخر',
                x: 100,
                y: 200,
                width: 600,
                height: 80,
                style: {
                  'fontFamily': 'Cairo',
                  'fontSize': 32.0,
                  'color': '#D4AF37',
                  'fontWeight': 'bold',
                  'textAlign': 'right',
                },
              ),
              const DocumentElement(
                id: 'el_badge',
                type: 'shape',
                content: '',
                x: 100,
                y: 350,
                width: 200,
                height: 50,
                style: {
                  'backgroundColor': '#7A0E2C',
                  'borderRadius': 12.0,
                },
              ),
            ],
          ),
          DocumentPage(
            id: 'page_2',
            background: const PageBackground(color: '#131D38'),
            elements: [
              const DocumentElement(
                id: 'el_p2_text',
                type: 'text',
                content: 'الصفحة الثانية من التصميم',
                x: 150,
                y: 300,
                width: 500,
                height: 60,
                style: {
                  'fontFamily': 'Tajawal',
                  'fontSize': 28.0,
                  'color': '#F6E9D8',
                },
              ),
            ],
          ),
        ],
      );
    });

    test('Feature A - PNG Export generates valid PNG bytes with correct dimensions', () async {
      const config = ExportConfig(
        format: ExportFormat.png,
        quality: ExportQuality.standard,
        scope: ExportPageScope.currentPage,
      );

      final bytes = await CanvasRenderService.instance.renderPageToImageBytes(
        page: testDocument.pages[0],
        config: config,
        baseWidth: 400,
        baseHeight: 400,
      );

      expect(bytes, isNotNull);
      expect(bytes.length, greaterThan(100));
      // PNG header magic bytes: 0x89 0x50 0x4E 0x47 (PNG)
      expect(bytes[0], 0x89);
      expect(bytes[1], 0x50);
      expect(bytes[2], 0x4E);
      expect(bytes[3], 0x47);
    });

    test('Feature B - JPG Export generates valid JPEG bytes with compression', () async {
      const config = ExportConfig(
        format: ExportFormat.jpg,
        quality: ExportQuality.standard,
        scope: ExportPageScope.currentPage,
        jpgQuality: 85,
      );

      final bytes = await CanvasRenderService.instance.renderPageToImageBytes(
        page: testDocument.pages[0],
        config: config,
        baseWidth: 400,
        baseHeight: 400,
      );

      expect(bytes, isNotNull);
      expect(bytes.length, greaterThan(100));
      // JPEG header magic bytes: 0xFF 0xD8
      expect(bytes[0], 0xFF);
      expect(bytes[1], 0xD8);
    });

    test('Feature C - PDF Export generates valid single and multi-page PDF documents', () async {
      const config = ExportConfig(
        format: ExportFormat.pdf,
        quality: ExportQuality.standard,
        scope: ExportPageScope.allPages,
      );

      final pdfBytes = await PdfExportService.instance.generatePdf(
        pages: testDocument.pages,
        config: config,
        baseWidth: 400,
        baseHeight: 400,
      );

      expect(pdfBytes, isNotNull);
      expect(pdfBytes.length, greaterThan(500));
      // PDF magic header: %PDF-
      final headerStr = utf8.decode(pdfBytes.sublist(0, 5));
      expect(headerStr, '%PDF-');
    });

    test('Feature D - Print Quality calculates target 300 DPI resolution scaling', () {
      expect(ExportQuality.standard.scaleFactor, 1.0);
      expect(ExportQuality.standard.dpi, 72);

      expect(ExportQuality.high.scaleFactor, 2.0);
      expect(ExportQuality.high.dpi, 150);

      expect(ExportQuality.print300Dpi.scaleFactor, closeTo(4.1667, 0.001));
      expect(ExportQuality.print300Dpi.dpi, 300);

      const baseDim = 1080.0;
      final printPixels = (baseDim * ExportQuality.print300Dpi.scaleFactor).round();
      expect(printPixels, 4500);
    });

    test('Empty document validation prevents exporting empty pages', () async {
      const emptyDoc = TemplateDocument(pages: []);
      expect(emptyDoc.pages.isEmpty, isTrue);

      expect(
        () => PdfExportService.instance.generatePdf(
          pages: [],
          config: const ExportConfig(format: ExportFormat.pdf),
        ),
        throwsException,
      );
    });
  });

  group('Phase 6: Subscription & Entitlements Tests', () {
    test('Default customer subscription is Free Plan', () {
      final freeSub = CustomerSubscription.free();
      expect(freeSub.tier, SubscriptionTier.free);
      expect(freeSub.isPremiumActive, isFalse);
      expect(freeSub.status, SubscriptionStatus.none);
    });

    test('Feature Entitlements correctly protect Pro features without blocking free access', () {
      expect(FeatureEntitlement.printQualityExport300Dpi.isAvailableFor(SubscriptionTier.free), isFalse);
      expect(FeatureEntitlement.printQualityExport300Dpi.isAvailableFor(SubscriptionTier.premium), isTrue);

      expect(FeatureEntitlement.multiPagePdfExport.isAvailableFor(SubscriptionTier.free), isFalse);
      expect(FeatureEntitlement.multiPagePdfExport.isAvailableFor(SubscriptionTier.premium), isTrue);
    });

    test('Subscription Products have accurate billing cycles and transparent pricing', () {
      final monthly = SubscriptionProduct.fallbackMonthly;
      final yearly = SubscriptionProduct.fallbackYearly;

      expect(monthly.cycle, BillingCycle.monthly);
      expect(monthly.price, 9.99);

      expect(yearly.cycle, BillingCycle.yearly);
      expect(yearly.discountBadge, contains('35%'));
    });

    test('CustomerSubscription parses Supabase record accurately', () {
      final supabaseRecord = {
        'id': 'sub_123',
        'user_id': 'user_abc',
        'plan_type': 'premium',
        'status': 'active',
        'current_period_start': '2026-11-12T00:00:00.000Z',
        'current_period_end': '2026-12-12T00:00:00.000Z',
      };

      final sub = CustomerSubscription.fromSupabase(supabaseRecord);
      expect(sub.tier, SubscriptionTier.premium);
      expect(sub.isActive, isTrue);
      expect(sub.isPremiumActive, isTrue);
      expect(sub.currentPeriodEnd, isNotNull);
    });
  });
}
