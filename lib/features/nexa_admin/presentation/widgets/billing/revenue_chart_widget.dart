import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/theme/text_styles.dart';

/// Revenue Chart Widget
/// Displays revenue trends and breakdowns using various chart types
class RevenueChartWidget extends StatefulWidget {
  final Map<String, dynamic> revenueData;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final ChartType chartType;
  final bool showLegend;
  final bool interactive;

  const RevenueChartWidget({
    super.key,
    required this.revenueData,
    this.periodStart,
    this.periodEnd,
    this.chartType = ChartType.line,
    this.showLegend = true,
    this.interactive = true,
  });

  @override
  State<RevenueChartWidget> createState() => _RevenueChartWidgetState();
}

class _RevenueChartWidgetState extends State<RevenueChartWidget> {
  late ChartType _selectedChartType;
  late List<RevenueDataPoint> _chartData;
  late List<RevenueByCategory> _categoryData;

  @override
  void initState() {
    super.initState();
    _selectedChartType = widget.chartType;
    _processRevenueData();
  }

  @override
  void didUpdateWidget(RevenueChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.revenueData != widget.revenueData ||
        oldWidget.periodStart != widget.periodStart ||
        oldWidget.periodEnd != widget.periodEnd) {
      _processRevenueData();
    }
  }

  void _processRevenueData() {
    // Process revenue trend data
    final trendData = widget.revenueData['trend'] as List<dynamic>? ?? [];
    _chartData = trendData.map((item) {
      return RevenueDataPoint(
        date: DateTime.parse(item['date']),
        revenue: (item['revenue'] as num).toDouble(),
        invoiceCount: item['invoice_count'] as int? ?? 0,
        paidCount: item['paid_count'] as int? ?? 0,
      );
    }).toList();

    // Process category data
    final categoryData =
        widget.revenueData['by_category'] as Map<String, dynamic>? ?? {};
    _categoryData = categoryData.entries.map((entry) {
      return RevenueByCategory(
        category: entry.key,
        revenue: (entry.value as num).toDouble(),
        color: _getCategoryColor(entry.key),
      );
    }).toList();
  }

  Color _getCategoryColor(String category) {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.success,
      AppColors.warning,
      AppColors.error,
      AppColors.info,
    ];
    final index = category.hashCode % colors.length;
    return colors[index];
  }

  void _toggleChartType() {
    setState(() {
      _selectedChartType = _selectedChartType == ChartType.line
          ? ChartType.column
          : ChartType.line;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Revenue Overview',
                  style: TextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (widget.interactive)
                  IconButton(
                    icon: Icon(
                      _selectedChartType == ChartType.line
                          ? Icons.bar_chart
                          : Icons.show_chart,
                      color: AppColors.primary,
                    ),
                    onPressed: _toggleChartType,
                    tooltip: 'Switch Chart Type',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.periodStart?.toLocal().toString().split(' ')[0] ?? ''} - ${widget.periodEnd?.toLocal().toString().split(' ')[0] ?? ''}',
              style: TextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),

            // Chart
            SizedBox(height: 300, child: _buildChart()),

            // Legend
            if (widget.showLegend && _categoryData.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildLegend(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    if (_chartData.isEmpty && _categoryData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics, size: 48, color: AppColors.gray400),
            const SizedBox(height: 16),
            Text(
              'No revenue data available',
              style: TextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (_selectedChartType == ChartType.line) {
      return _buildLineChart();
    } else {
      return _buildColumnChart();
    }
  }

  Widget _buildLineChart() {
    return SfCartesianChart(
      primaryXAxis: DateTimeAxis(
        dateFormat: 'MMM dd',
        labelStyle: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        axisLine: AxisLine(color: AppColors.border),
        majorGridLines: MajorGridLines(
          color: AppColors.border.withOpacity(0.3),
        ),
      ),
      primaryYAxis: NumericAxis(
        numberFormat: '\$#,##0',
        labelStyle: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        axisLine: AxisLine(color: AppColors.border),
        majorGridLines: MajorGridLines(
          color: AppColors.border.withOpacity(0.3),
        ),
      ),
      series: <CartesianSeries>[
        LineSeries<RevenueDataPoint, DateTime>(
          dataSource: _chartData,
          xValueMapper: (RevenueDataPoint data, _) => data.date,
          yValueMapper: (RevenueDataPoint data, _) => data.revenue,
          color: AppColors.primary,
          width: 3,
          markerSettings: MarkerSettings(
            isVisible: true,
            shape: DataMarkerType.circle,
            borderWidth: 2,
            borderColor: AppColors.primary,
            color: Colors.white,
          ),
          dataLabelSettings: DataLabelSettings(isVisible: false),
        ),
      ],
      tooltipBehavior: TooltipBehavior(
        enable: true,
        format: 'point.x : \$point.y',
        color: AppColors.primary,
        textStyle: TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  Widget _buildColumnChart() {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(
        labelStyle: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        axisLine: AxisLine(color: AppColors.border),
        majorGridLines: MajorGridLines(
          color: AppColors.border.withOpacity(0.3),
        ),
      ),
      primaryYAxis: NumericAxis(
        numberFormat: '\$#,##0',
        labelStyle: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        axisLine: AxisLine(color: AppColors.border),
        majorGridLines: MajorGridLines(
          color: AppColors.border.withOpacity(0.3),
        ),
      ),
      series: <CartesianSeries>[
        ColumnSeries<RevenueByCategory, String>(
          dataSource: _categoryData,
          xValueMapper: (RevenueByCategory data, _) => data.category,
          yValueMapper: (RevenueByCategory data, _) => data.revenue,
          color: AppColors.primary,
          width: 0.6,
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            labelAlignment: ChartDataLabelAlignment.top,
            textStyle: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
      tooltipBehavior: TooltipBehavior(
        enable: true,
        format: 'point.x : \$point.y',
        color: AppColors.primary,
        textStyle: TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: _categoryData.map((category) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: category.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              category.category,
              style: TextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '\$${category.revenue.toStringAsFixed(2)}',
              style: TextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

enum ChartType { line, column, pie }

class RevenueDataPoint {
  final DateTime date;
  final double revenue;
  final int invoiceCount;
  final int paidCount;

  RevenueDataPoint({
    required this.date,
    required this.revenue,
    required this.invoiceCount,
    required this.paidCount,
  });
}

class RevenueByCategory {
  final String category;
  final double revenue;
  final Color color;

  RevenueByCategory({
    required this.category,
    required this.revenue,
    required this.color,
  });
}
