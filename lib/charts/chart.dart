import 'shared_functions.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:project_mobile_app/charts/chart_settings.dart';
import 'package:project_mobile_app/models/units_provider.dart';
import 'package:provider/provider.dart';
import '../models/runner_provider.dart';

class Chart extends StatefulWidget {
  final RunnerProvider runnerProvider;
  final Settings setting;
  const Chart({
    Key? key,
    required this.runnerProvider,
    required this.setting,
  }) : super(key: key);

  @override
  State<Chart> createState() =>
      _ChartState(runnerProvider: runnerProvider, setting: setting);
}
/* Widget for displaying the charts  */
class _ChartState extends State<Chart> {
  final RunnerProvider runnerProvider;
  final Settings setting;
  _ChartState({required this.runnerProvider, required this.setting});
  late UnitsProvider unitsProvider = Provider.of<UnitsProvider>(context);

  @override
  Widget build(BuildContext context) {
    List<BarChartGroupData> xAxis =
        xAxisFiller(setting, runnerProvider, unitsProvider);
    double maxY = maxYValue(runnerProvider, setting, unitsProvider);
    return Card(
      elevation: 10,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          side: BorderSide()),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.tealAccent, Colors.teal],
          ),
        ),
        child: BarChart(
          BarChartData(
            maxY: maxY,
            alignment: BarChartAlignment.spaceEvenly,
            barGroups: xAxis,
            barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                    fitInsideVertically: true,
                    fitInsideHorizontally: true,
                    tooltipBgColor: Colors.teal,
                    direction: TooltipDirection.auto,
                    tooltipBorder: const BorderSide(color: Colors.black),
                    tooltipPadding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    getTooltipItem: ((group, groupIndex, rod, rodIndex) {
                      String tooltipValue = setting.chartType == 'Distance'
                          ? '${rod.toY.toStringAsFixed(1)}'
                          : '${rod.toY.toStringAsFixed(0)}';
                      return BarTooltipItem(
                          '$tooltipValue ${setting.toolTipUnit}',
                          const TextStyle(color: Colors.black));
                    }))),
            groupsSpace: setting.xAxis.toDouble(),
            borderData: FlBorderData(
                show: true,
                border: const Border(
                  bottom: BorderSide(),
                  left: BorderSide(),
                  right: BorderSide(),
                )),
            gridData: FlGridData(
              show: true,
              verticalInterval: 1,
            ),
            titlesData: FlTitlesData(
              bottomTitles:
                  axisTitle((bottomTitles(setting)), setting.bottomTitle, 30),
              leftTitles: axisTitle(
                  SideTitles(showTitles: true, reservedSize: 40),
                  setting.leftTitle,
                  30),
              topTitles: axisTitle(
                  SideTitles(showTitles: false), setting.topTitle, 30),
              rightTitles: axisTitle(SideTitles(showTitles: false), '', 20),
            ),
          ),
        ),
      ),
    );
  }
}
