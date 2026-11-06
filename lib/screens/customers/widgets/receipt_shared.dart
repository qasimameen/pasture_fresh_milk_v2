import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class ReceiptHeader extends StatelessWidget {
  final String shopName;
  final String address;
  final String phone;
  final String receiptTitle;
  final String date;
  final String? billNumber;
  
  final String customerName;
  final String customerPhone;
  final String customerAddress;

  const ReceiptHeader({
    super.key,
    required this.shopName,
    required this.address,
    required this.phone,
    required this.receiptTitle,
    required this.date,
    this.billNumber,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
  });

  @override
  Widget build(BuildContext context) {
    final typography = AppTypography.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Shop Info (Centered)
        Text(shopName, style: typography.heading, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.space2xs),
        Text(address, style: typography.bodySm.copyWith(color: AppColors.neutralMuted), textAlign: TextAlign.center),
        Text(phone, style: typography.bodySm.copyWith(color: AppColors.neutralMuted), textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.spaceMd),
        
        const DashedDivider(),
        const SizedBox(height: AppSpacing.spaceMd),

        // Customer Info (Left aligned, or Right in RTL)
        Text(customerName, style: typography.subhead),
        const SizedBox(height: AppSpacing.space2xs),
        Text(customerPhone, style: typography.bodySm.copyWith(color: AppColors.neutralMuted)),
        Text(customerAddress, style: typography.bodySm.copyWith(color: AppColors.neutralMuted)),
        const SizedBox(height: AppSpacing.spaceMd),
        
        const DashedDivider(),
        const SizedBox(height: AppSpacing.spaceMd),

        // Receipt Meta Info
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: receiptTitle,
                  style: typography.subhead,
                  children: billNumber != null
                      ? [
                          TextSpan(
                            text: '  \u202A#$billNumber\u202C',
                            style: typography.bodySm.copyWith(color: AppColors.neutralMuted),
                          )
                        ]
                      : [],
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(date, style: typography.caption),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class DashedDivider extends StatelessWidget {
  final double height;
  final Color color;
  final double dashWidth;

  const DashedDivider({
    super.key,
    this.height = 1,
    this.color = AppColors.neutralLine,
    this.dashWidth = 5.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashHeight = height;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }
}
