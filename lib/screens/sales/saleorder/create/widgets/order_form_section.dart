// lib/screens/sales/saleorder/create/widgets/order_form_section.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:routy/screens/sales/saleorder/create/controllers/partner_controller.dart';
import 'package:routy/l10n/app_localizations.dart';

/// 📋 Order Form Section - قسم نموذج الطلب
///
/// يدعم:
/// - اختيار العميل
/// - اختيار قائمة الأسعار
/// - اختيار شروط الدفع
/// - تحديد تاريخ التسليم
class OrderFormSection extends StatelessWidget {
  final SalesPartnerController partnerController;
  final VoidCallback? onPartnerChanged;
  final VoidCallback? onPriceListChanged;
  final VoidCallback? onPaymentTermChanged;

  const OrderFormSection({
    super.key,
    required this.partnerController,
    this.onPartnerChanged,
    this.onPriceListChanged,
    this.onPaymentTermChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // عنوان القسم
            Text(
              'تفاصيل الطلب',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            // اختيار العميل
            _buildPartnerSelector(l10n),

            const SizedBox(height: 16),

            // اختيار قائمة الأسعار
            _buildPriceListSelector(l10n),

            const SizedBox(height: 16),

            // اختيار شروط الدفع
            _buildPaymentTermSelector(l10n),

            const SizedBox(height: 16),

            // تاريخ التسليم
            _buildDeliveryDateSelector(l10n),
          ],
        ),
      ),
    );
  }

  // ============= Partner Selector =============

  Widget _buildPartnerSelector(AppLocalizations l10n) {
    return Obx(() {
      final selectedPartner = partnerController.selectedPartner.value;

      return FormBuilderDropdown<int>(
        name: 'partner_id',
        decoration: InputDecoration(
          labelText: 'العميل',
          hintText: 'اختر العميل',
          prefixIcon: const Icon(Icons.person),
          border: const OutlineInputBorder(),
        ),
        initialValue:
            selectedPartner?.id != null &&
                partnerController.partners.any(
                  (p) =>
                      p.id == selectedPartner?.id && p.displayName.isNotEmpty,
                )
            ? selectedPartner?.id
            : null,
        items: partnerController.partners
            .where(
              (partner) => partner.id != null && partner.displayName.isNotEmpty,
            )
            .toSet() // إزالة التكرارات
            .map((partner) {
              return DropdownMenuItem<int>(
                value: partner.id!,
                child: Text(partner.displayName),
              );
            })
            .toList(),
        onChanged: (value) {
          if (value != null) {
            partnerController.selectPartner(value);
            onPartnerChanged?.call();
          }
        },
        validator: (value) {
          if (value == null) {
            return 'يرجى اختيار العميل';
          }
          return null;
        },
      );
    });
  }

  // ============= Price List Selector =============

  Widget _buildPriceListSelector(AppLocalizations l10n) {
    return Obx(() {
      final selectedPriceList = partnerController.selectedPriceList.value;

      return FormBuilderDropdown<int>(
        name: 'pricelist_id',
        decoration: InputDecoration(
          labelText: 'قائمة الأسعار',
          hintText: 'اختر قائمة الأسعار',
          prefixIcon: const Icon(Icons.attach_money),
          border: const OutlineInputBorder(),
        ),
        initialValue: selectedPriceList?.id,
        items: partnerController.partnerPriceLists.map((priceList) {
          return DropdownMenuItem<int>(
            value: priceList.id,
            child: Text(priceList.pricelistName),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            partnerController.selectPriceList(value);
            onPriceListChanged?.call();
          }
        },
        validator: (value) {
          if (value == null) {
            return 'يرجى اختيار قائمة الأسعار';
          }
          return null;
        },
      );
    });
  }

  // ============= Payment Term Selector =============

  Widget _buildPaymentTermSelector(AppLocalizations l10n) {
    return Obx(() {
      final selectedPaymentTerm = partnerController.selectedPaymentTerm.value;

      return FormBuilderDropdown<int>(
        name: 'payment_term_id',
        decoration: InputDecoration(
          labelText: 'شروط الدفع',
          hintText: 'اختر شروط الدفع',
          prefixIcon: const Icon(Icons.payment),
          border: const OutlineInputBorder(),
        ),
        initialValue: selectedPaymentTerm?.id,
        items: partnerController.paymentTerms.map((paymentTerm) {
          return DropdownMenuItem<int>(
            value: paymentTerm.id,
            child: Text(paymentTerm.paymentTermName),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            partnerController.selectPaymentTerm(value);
            onPaymentTermChanged?.call();
          }
        },
        validator: (value) {
          if (value == null) {
            return 'يرجى اختيار شروط الدفع';
          }
          return null;
        },
      );
    });
  }

  // ============= Delivery Date Selector =============

  Widget _buildDeliveryDateSelector(AppLocalizations l10n) {
    return Obx(() {
      final showDeliveryDate = partnerController.showDeliveryDate.value;
      final deliveryDate = partnerController.deliveryDate.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // مفتاح التبديل
          Row(
            children: [
              Checkbox(
                value: showDeliveryDate,
                onChanged: (value) {
                  partnerController.toggleDeliveryDate(value ?? false);
                },
              ),
              Text('تحديد تاريخ التسليم'),
            ],
          ),

          // منتقي التاريخ
          if (showDeliveryDate) ...[
            const SizedBox(height: 8),
            FormBuilderDateTimePicker(
              name: 'commitment_date',
              decoration: InputDecoration(
                labelText: 'تاريخ التسليم',
                hintText: 'اختر تاريخ التسليم',
                prefixIcon: const Icon(Icons.calendar_today),
                border: const OutlineInputBorder(),
              ),
              initialValue: deliveryDate,
              onChanged: (value) {
                partnerController.setDeliveryDate(value);
              },
              validator: (value) {
                if (showDeliveryDate && value == null) {
                  return 'يرجى اختيار تاريخ التسليم';
                }
                return null;
              },
            ),
          ],
        ],
      );
    });
  }
}
