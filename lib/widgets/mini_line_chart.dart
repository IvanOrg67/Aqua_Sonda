import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MiniLineChart extends StatelessWidget {
  final List<FlSpot> series;
  const MiniLineChart({super.key, required this.series});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: LineChart(
        LineChartData(
          backgroundColor: Colors.transparent,
          gridData: FlGridData(show: true, drawVerticalLine: false,
              horizontalInterval: 0.25,
              getDrawingHorizontalLine: (_) => FlLine(color: AppColors.border, strokeWidth: 1)),
          borderData: FlBorderData(show: true, border: Border.all(color: AppColors.border)),
          titlesData: FlTitlesData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              color: AppColors.primary,
              barWidth: 3,
              spots: series,
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
