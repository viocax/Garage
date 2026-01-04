import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:garage/theme/app_theme.dart';
import 'package:intl/intl.dart';
import '../bloc/all_records_state.dart';

class FuelEfficiencyChart extends StatelessWidget {
  final List<FuelEfficiencyData> data;

  const FuelEfficiencyChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.whiteTransparent08, AppTheme.whiteTransparent04],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.whiteTransparent15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '油耗趨勢 (km/L)',
            style: TextStyle(fontSize: 12, color: AppTheme.systemGray),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: data.isEmpty
                ? const Center(
                    child: Text(
                      '需要至少兩筆加油紀錄來計算油耗',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.systemGray,
                      ),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (_) => AppTheme.darkSurface,
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              return LineTooltipItem(
                                '${spot.y.toStringAsFixed(1)} km/L',
                                const TextStyle(
                                  color: AppTheme.dashboardAccentRed,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 22,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < data.length) {
                                if (data.length > 5 &&
                                    index % (data.length ~/ 3) != 0 &&
                                    index != data.length - 1) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    DateFormat(
                                      'MM/dd',
                                    ).format(data[index].date),
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: AppTheme.systemGray,
                                    ),
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
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toStringAsFixed(0),
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: AppTheme.systemGray,
                                ),
                              );
                            },
                            reservedSize: 28,
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: data.asMap().entries.map((e) {
                            return FlSpot(e.key.toDouble(), e.value.kmPerLiter);
                          }).toList(),
                          isCurved: true,
                          gradient: const LinearGradient(
                            colors: [
                              AppTheme.recordTypeFuelColor,
                              AppTheme.dashboardAccentRed,
                            ],
                          ),
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppTheme.recordTypeFuelColor.withValues(
                                  alpha: 0.3,
                                ),
                                AppTheme.recordTypeFuelColor.withValues(
                                  alpha: 0,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
