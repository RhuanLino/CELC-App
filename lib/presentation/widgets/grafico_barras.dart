import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AttendanceChart extends StatelessWidget {
  final Map<String, Map<String, int>> monthlyData;

  const AttendanceChart({super.key, required this.monthlyData});

  @override
  Widget build(BuildContext context) {
    // Processa os dados para o gráfico
    final weekList = monthlyData.keys.toList();
    final presenceData = weekList.map((week) => monthlyData[week]!['presence']!.toDouble()).toList();
    final absenceData = weekList.map((week) => monthlyData[week]!['absence']!.toDouble()).toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 10, // Ajuste conforme seu valor máximo
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final week = weekList[group.x.toInt()];
              return BarTooltipItem(
                '$week\nPresenças: ${rod.toY.toInt()}\nFaltas: ${absenceData[group.x.toInt()].toInt()}',
                const TextStyle(color: Colors.black),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(weekList[value.toInt()]),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(value.toInt().toString());
              },
              reservedSize: 40,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          for (int i = 0; i < weekList.length; i++)
            BarChartGroupData(
              x: i,
              groupVertically: true,
              barsSpace: 4,
              barRods: [
                BarChartRodData(
                  toY: presenceData[i],
                  color: Colors.green[400],
                  width: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
                BarChartRodData(
                  toY: absenceData[i],
                  color: Colors.red[400],
                  width: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
        ],
      ),
    );
  }
}