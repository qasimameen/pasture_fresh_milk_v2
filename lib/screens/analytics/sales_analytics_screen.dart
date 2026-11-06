import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../models/product.dart';
import '../../providers/sales_analytics_provider.dart';

class SalesAnalyticsScreen extends ConsumerStatefulWidget {
  const SalesAnalyticsScreen({
    super.key,
    required this.timeframe,
  });

  final Timeframe timeframe;

  @override
  ConsumerState<SalesAnalyticsScreen> createState() => _SalesAnalyticsScreenState();
}

class _SalesAnalyticsScreenState extends ConsumerState<SalesAnalyticsScreen> {
  bool _showQuantity = false;

  @override
  Widget build(BuildContext context) {
    final analyticsAsync = ref.watch(salesAnalyticsProvider(widget.timeframe));
    final typography = AppTypography.of(context);
    
    final title = widget.timeframe == Timeframe.daily ? 'Daily Sales' : 'Monthly Sales';

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: Text(
          title,
          style: typography.subhead.copyWith(color: AppColors.neutralTitle),
        ),
        backgroundColor: AppColors.card,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.neutralTitle),
        actions: [
          Row(
            children: [
              Text('Revenue', style: typography.caption.copyWith(color: AppColors.neutralBody)),
              Switch(
                value: _showQuantity,
                onChanged: (val) => setState(() => _showQuantity = val),
                activeColor: AppColors.brandPrimary,
              ),
              Text('Qty', style: typography.caption.copyWith(color: AppColors.neutralBody)),
              const SizedBox(width: AppSpacing.spaceMd),
            ],
          )
        ],
      ),
      body: analyticsAsync.when(
        data: (data) {
          final l10n = AppLocalizations.of(context);
          return _buildBody(data, typography, l10n);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text(e.toString())),
      ),
    );
  }

  Widget _buildBody(List<ProductSalesData> data, AppTypography typography, AppLocalizations? l10n) {
    if (data.isEmpty) {
      return Center(
        child: Text('No sales data found.', style: typography.bodyLg),
      );
    }

    double maxVal = 0;
    for (final item in data) {
      final val = _showQuantity ? item.quantity : item.revenue;
      if (val > maxVal) maxVal = val;
    }
    maxVal = maxVal == 0 ? 10 : maxVal * 1.2;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenGutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.spaceMd),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.brandTint),
              ),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxVal,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx >= 0 && idx < data.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                data[idx].productName,
                                style: typography.caption.copyWith(fontSize: 10),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          if (value == maxVal) return const SizedBox.shrink();
                          return Text(
                            value.toInt().toString(),
                            style: typography.caption.copyWith(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                  borderData: FlBorderData(show: false),
                  barGroups: data.asMap().entries.map((e) {
                    final index = e.key;
                    final item = e.value;
                    final val = _showQuantity ? item.quantity : item.revenue;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: val,
                          color: AppColors.brandPrimary,
                          width: 16,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.spaceLg),
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.brandTint),
              ),
              child: ListView.separated(
                itemCount: data.length,
                separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.brandTint),
                itemBuilder: (context, index) {
                  final item = data[index];
                  return ListTile(
                    title: Text(item.productName.localized(l10n?.localeName), style: typography.bodyLg.copyWith(fontWeight: FontWeight.w600)),
                    subtitle: Text('Qty: ${item.quantity.toStringAsFixed(1)}', style: typography.caption),
                    trailing: Text('Rs. ${item.revenue.toStringAsFixed(0)}', style: typography.subhead.copyWith(color: AppColors.brandPrimary)),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
