import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/l10n/app_localizations.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../models/delivery.dart';
import '../../widgets/app_button.dart';

class DeliveryReportPreviewScreen extends StatefulWidget {
  final String customerName;
  final List<Delivery> deliveries;
  final DateTime startDate;
  final DateTime endDate;

  const DeliveryReportPreviewScreen({
    super.key,
    required this.customerName,
    required this.deliveries,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<DeliveryReportPreviewScreen> createState() => _DeliveryReportPreviewScreenState();
}

class _DeliveryReportPreviewScreenState extends State<DeliveryReportPreviewScreen> {
  late String _reportText;

  @override
  void initState() {
    super.initState();
    // We defer generation until build so we can access l10n if needed
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _generateReportText();
  }

  void _generateReportText() {
    final l10n = AppLocalizations.of(context);
    final dateFmt = DateFormat('dd MMM yyyy');
    final rowDateFmt = DateFormat('dd MMM');
    
    final sStr = dateFmt.format(widget.startDate);
    final eStr = dateFmt.format(widget.endDate);

    final buffer = StringBuffer();
    // Use localized title from the existing variables or hardcoded if simple
    buffer.writeln('${l10n.deliveryHistoryTitle} - ${widget.customerName}');
    buffer.writeln('($sStr - $eStr)');
    buffer.writeln('-------------------------');

    double totalLitres = 0;

    for (final d in widget.deliveries) {
      final dDate = rowDateFmt.format(d.date);
      final shift = d.shift == 'morning' ? 'AM' : 'PM';
      totalLitres += d.deliveredQuantity;
      
      final qtyStr = d.deliveredQuantity.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
      
      buffer.write('✅ $dDate $shift | ${qtyStr}L');
      
      if (d.receiverNote != null && d.receiverNote!.trim().isNotEmpty) {
        buffer.write(' | ${l10n.receiverNamePrefix}${d.receiverNote}');
      }
      buffer.writeln();
    }
    
    buffer.writeln('-------------------------');
    final totalStr = totalLitres.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
    buffer.writeln('Total: ${totalStr}L');

    _reportText = buffer.toString();
  }

  void _shareText() {
    // ignore: deprecated_member_use
    Share.share(_reportText, subject: 'Delivery Report - ${widget.customerName}');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final typography = AppTypography.of(context);

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: Text(l10n.deliveryReportPreview, style: typography.headlineLg.copyWith(color: AppColors.neutralTitle)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.neutralTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.spaceLg),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.neutralLine),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    _reportText,
                    style: typography.body.copyWith(
                      fontFamily: 'monospace', // Gives it a nice receipt look
                      height: 1.5,
                      color: AppColors.neutralTitle,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.spaceLg),
            AppButton(
              label: l10n.shareTextBtn,
              icon: Symbols.share,
              onPressed: _shareText,
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}
