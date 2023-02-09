import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:project_mobile_app/models/units_provider.dart';
import 'package:project_mobile_app/pages/history.dart';
import 'dart:math';
import 'package:project_mobile_app/models/activityProvider.dart';
import 'package:project_mobile_app/models/runner_provider.dart';
import 'package:provider/provider.dart';

import 'shared_functions.dart';

class LineChartWidget extends StatelessWidget {
  final ActivityData activityData;
  const LineChartWidget(this.activityData, {super.key});

  @override
  Widget build(BuildContext context) {
    UnitsProvider unitsProvider = Provider.of<UnitsProvider>(context);
    double maxY = getMaxY(activityData, unitsProvider);
    Duration currentUnitAvgPace = activityData.avgPace as Duration;

    if (unitsProvider.unit == Unit.imperial) {
      currentUnitAvgPace = Duration(
          seconds: (activityData.avgPace!.inSeconds * 1.609344).toInt());
    }

    return activityData.paces.isEmpty ||
            activityData.activityDuration!.inMinutes < 1
        ? Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.tealAccent, Colors.teal],
              ),
            ),
            height: 100,
            child: const Center(
                child: Text("Not enough data to show graph, try a longer run")),
          )
        : Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.tealAccent, Colors.teal],
              ),
            ),
            child: Column(
              children: [
                Center(
                    child: Text(
                  'Pace',
                  style: Theme.of(context).textTheme.titleLarge,
                )),
                Row(
                  children: [
                    buildLegend(
                        text: 'Avg pace', color: Colors.teal, context: context),
                    buildLegend(
                        text: 'Current pace',
                        color: Colors.black,
                        context: context),
                  ],
                ), //asd
                AspectRatio(
                  aspectRatio: 1.8,
                  child: LineChart(
                    LineChartData(
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          fitInsideHorizontally: true,
                          tooltipBgColor: Colors.teal,
                          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                            bool first = true;
                            return touchedBarSpots.map((barSpot) {
                              final flSpot = barSpot;
                              Duration tempDur =
                                  Duration(seconds: flSpot.x.toInt());
                              Duration tempAvgDur =
                                  Duration(seconds: (flSpot.y * 60).toInt());
                              String avgPace =
                                  '${(tempAvgDur.inMinutes.remainder(60).toString().padLeft(2, '0'))}:${(tempAvgDur.inSeconds.remainder(60)).toString().padLeft(2, '0')}';
                              if (first) {
                                first = false;
                                return LineTooltipItem(
                                  unitsProvider.unit == Unit.metric
                                      ? '$avgPace min/km \n'
                                      : '$avgPace min/mi \n',
                                  const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  children: [
                                    TextSpan(
                                      text:
                                          '${(tempDur.inMinutes.remainder(60).toString().padLeft(2, '0'))}:${(tempDur.inSeconds.remainder(60)).toString().padLeft(2, '0')} min',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                );
                              }
                            }).toList();
                          },
                        ),
                      ),
                      maxY: maxY + 2,
                      minY: -.5,

                      titlesData: FlTitlesData(
                        bottomTitles: axisTitle(
                            _bottomTitles(activityData), 'Time (min)', 25),
                        leftTitles: axisTitle(
                            _leftTiles(currentUnitAvgPace),
                            unitsProvider.unit == Unit.metric
                                ? 'Pace (min/km)'
                                : 'Pace (min/mi)',
                            25),
                        topTitles:
                            axisTitle(SideTitles(showTitles: false), '', 10),
                        rightTitles:
                            axisTitle(SideTitles(showTitles: false), '', 20),
                      ),
                      gridData: FlGridData(
                        show: true,
                        getDrawingHorizontalLine: (value) => FlLine(
                            strokeWidth: value % 1 == 0 ? 0 : 0,
                            color: Color.fromARGB(40, 0, 0, 0)),
                        getDrawingVerticalLine: (value) => FlLine(
                          strokeWidth: value % 30 == 0 ? 0 : 0,
                        ),
                      ),

                      borderData: FlBorderData(
                          show: true,
                          border: Border.all(
                              color: Theme.of(context).canvasColor,
                              width:
                                  1)), //border: Border.all(color: Colors.amberAccent, width: 1)),
                      lineBarsData: [
                        LineChartBarData(
                          spots: activityData.paces
                              .map((point) => FlSpot(
                                  (point.time.inSeconds * 1.0),
                                  // (double.parse((point.time.inMinutes
                                  //             .remainder(60) +
                                  //         0.01 * point.time.inSeconds.remainder(60))
                                  //     .toStringAsFixed(2))),
                                  unitsProvider.unit == Unit.metric
                                      ? (point.pace.inSeconds / 60)
                                      : ((point.pace.inSeconds * 1.609344) /
                                          60)))
                              .toList(),

                          isCurved: true,
                          color: Theme.of(context).canvasColor,
                          barWidth: 4,
                          dotData: FlDotData(show: false),

                          //titlesData: FlTitlesData(
                          //show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color:
                                Theme.of(context).canvasColor.withOpacity(0.7),
                          ),
                        ),
                        LineChartBarData(
                            dotData: FlDotData(show: false),
                            barWidth: 3,
                            color: Colors.teal,
                            spots: [
                              FlSpot(
                                  activityData.paces.first.time.inSeconds * 1.0,
                                  currentUnitAvgPace.inSeconds / 60),
                              FlSpot(
                                  activityData.paces.last.time.inSeconds * 1.0,
                                  currentUnitAvgPace.inSeconds / 60)
                            ])
                      ],
                      // backgroundColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  SideTitles _bottomTitles(ActivityData activity) {
    return SideTitles(
        showTitles: true,
        getTitlesWidget: (value, meta) {
          Duration tempDur = Duration(seconds: value.toInt());
          String text = '';
          if (value != 10 && value != activity.paces.last.time.inSeconds) {
            text = //(value / 60).toStringAsFixed(0);
                '${(tempDur.inMinutes.remainder(60).toString())}:${(tempDur.inSeconds.remainder(60)).toString().padRight(2, '0')}';
          }

          return Text(text);
        },
        reservedSize: 20,
        interval: (activity.paces.length / 6) * 10);
  }

  SideTitles _leftTiles(Duration avgPace) {
    return SideTitles(
        showTitles: true,
        getTitlesWidget: (value, meta) {
          String text = '';
          if (value.toStringAsFixed(2) ==
              (avgPace.inSeconds / 60).toStringAsFixed(2)) {
            text =
                '${(avgPace.inMinutes.remainder(60).toString())}:${(avgPace.inSeconds.remainder(60)).toString().padLeft(2, '0')}';
          }

          return Text(text);
        },
        reservedSize: 30,
        interval: 0.01);
  }
}

double getMaxY(ActivityData activityData, UnitsProvider unitsProvider) {
  double maxYvalue = 0;
  for (var point in activityData.paces) {
    {
      double temppace = point.pace.inSeconds / 60;
      if (unitsProvider.unit == Unit.imperial) {
        temppace *= 1.609344;
      }

      if (temppace > maxYvalue) {
        maxYvalue = temppace;
      }
    }
  }
  return maxYvalue;
}

Widget buildLegend({required String text, required Color color, context}) =>
    Row(
      children: [
        const SizedBox(width: 10),
        Container(
          width: 25,
          height: 5,
          color: color,
        ),
        const SizedBox(
          width: 10,
        ),
        Text(
          text,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );

mixin CopyWith {
  ShowPoint copyWith({required Duration pace, required Duration time}) {
    return ShowPoint(
      pace: pace,
      time: time,
    );
  }
}

class ShowPoint {
  late Duration pace;
  late Duration time;

  ShowPoint({required this.pace, required this.time});
  Map<String, dynamic> toJson() => {
        "pace": pace.inSeconds,
        "time": time.inSeconds,
      };
}
