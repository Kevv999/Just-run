import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'chart_settings.dart';
import '../models/runner_provider.dart';
import '../models/units_provider.dart';
import 'package:provider/provider.dart';

//Fill x-axis depending on type of chart.
SideTitles leftTiles() {
  return SideTitles(
      showTitles: true,
      getTitlesWidget: (value, meta) {
        String text = '';
        if (value % 5 == 0) {
          text = value.toStringAsFixed(0);
        }

        return Text(text);
      },
      reservedSize: 40,
      interval: 5);
}

SideTitles bottomTitles(Settings setting) => SideTitles(
      showTitles: true,
      getTitlesWidget: (value, meta) {
        String text = '';
        if (setting.duration == 'week') {
          switch (value.toInt()) {
            case 0:
              text = 'Monday';
              break;
            case 1:
              text = 'Tuesday';
              break;
            case 2:
              text = 'Wednesday';
              break;
            case 3:
              text = 'Thursday';
              break;
            case 4:
              text = 'Friday';
              break;
            case 5:
              text = 'Saturaday';
              break;
            case 6:
              text = 'Sunday';
              break;
          }

          return Text(text);
        } else if (setting.duration == 'month') {
          switch (value.toInt()) {
            case 0:
              text = 'Jan';
              break;
            case 1:
              text = 'Feb';
              break;
            case 2:
              text = 'Mar';
              break;
            case 3:
              text = 'Apr';
              break;
            case 4:
              text = 'May';
              break;
            case 5:
              text = 'Jun';
              break;
            case 6:
              text = 'Jul';
              break;
            case 7:
              text = 'Aug';
              break;
            case 8:
              text = 'Sep';
              break;
            case 9:
              text = 'Oct';
              break;
            case 10:
              text = 'Nov';
              break;
            case 11:
              text = 'Dec';
              break;
          }

          return Text(text);
        } else if (setting.duration == 'all time') {
          text = (DateTime.now().year - value.toInt()).toString();
          return Text(text);
        }
        return const Text('Error');
      },
    );

//Fill each column on the x-axis with value

List<BarChartGroupData> xAxisFiller(Settings setting,
    RunnerProvider runnerProvider, UnitsProvider unitsProvider) {
  List<BarChartGroupData> data = [];
  for (int i = 0; i < setting.xAxis; i++) {
    data.add(chartData(i, runnerProvider, setting, unitsProvider));
  }
  return data;
}

//Switch how the values on x-axis are calculated depending on chart type.

Function chartTypeXDefiner(Settings setting) {
  switch (setting.chartType) {
    case 'Distance':
      return (int x, RunnerProvider runnerProvider) {
        double xValue = 0;
        for (int i = 0; i < runnerProvider.runs.length; i++) {
          if (setting.duration == 'week') {
            if (isCurrentWeek(runnerProvider.runs[i])) {
              if (x == runnerProvider.runs[i].activityStartTime.weekday) {
                xValue += runnerProvider.runs[i].distance;
              }
            }
          }
          if (setting.duration == 'month') {
            if (isCurrentYear(runnerProvider.runs[i])) {
              if (x == runnerProvider.runs[i].activityStartTime.month) {
                xValue += runnerProvider.runs[i].distance;
              }
            }
          }
          if (setting.duration == 'all time') {
            if (runnerProvider.runs[i].activityStartTime.year ==
                (DateTime.now().year - x)) {
              xValue += runnerProvider.runs[i].distance;
            }
          }
        }
        return double.parse((xValue / 1000).toStringAsFixed(3));
      };
    case 'Elevation':
      return (int x, RunnerProvider runnerProvider) {
        double xValue = 0;
        for (int i = 0; i < runnerProvider.runs.length; i++) {
          if (setting.duration == 'week') {
            if (isCurrentWeek(runnerProvider.runs[i])) {
              if (x == runnerProvider.runs[i].activityStartTime.weekday) {
                xValue += runnerProvider.runs[i].elevation;
              }
            }
          }
          if (setting.duration == 'month') {
            if (isCurrentYear(runnerProvider.runs[i])) {
              if (x == runnerProvider.runs[i].activityStartTime.month) {
                xValue += runnerProvider.runs[i].elevation;
              }
            }
          }
          if (setting.duration == 'all time') {
            if (runnerProvider.runs[i].activityStartTime.year ==
                (DateTime.now().year - x)) {
              xValue += runnerProvider.runs[i].elevation;
            }
          }
        }
        return double.parse((xValue).toStringAsFixed(3));
      };
    case 'Calories':
      return (int x, RunnerProvider runnerProvider) {
        double xValue = 0;
        for (int i = 0; i < runnerProvider.runs.length; i++) {
          if (setting.duration == 'week') {
            if (isCurrentWeek(runnerProvider.runs[i])) {
              if (x == runnerProvider.runs[i].activityStartTime.weekday) {
                xValue += runnerProvider.runs[i].calories;
                debugPrint('Calories: ${runnerProvider.runs[i].calories}');
              }
            }
          }
          if (setting.duration == 'month') {
            if (isCurrentYear(runnerProvider.runs[i])) {
              if (x == runnerProvider.runs[i].activityStartTime.month) {
                xValue += runnerProvider.runs[i].calories;
              }
            }
          }
          if (setting.duration == 'all time') {
            debugPrint('$i x = $x');
            debugPrint(
                '$i year = ${runnerProvider.runs[i].activityStartTime.year - (DateTime.now().year - i)}');
            if (runnerProvider.runs[i].activityStartTime.year ==
                (DateTime.now().year - x)) {
              xValue += runnerProvider.runs[i].calories;
            }
          }
        }
        return double.parse((xValue).toStringAsFixed(3));
      };

    case 'Activity Count':
      return (int x, RunnerProvider runnerProvider) {
        double xValue = 0;
        for (int i = 0; i < runnerProvider.runs.length; i++) {
          if (setting.duration == 'week') {
            if (isCurrentWeek(runnerProvider.runs[i])) {
              if (x == runnerProvider.runs[i].activityStartTime.weekday) {
                xValue++;
              }
            }
          }
          if (setting.duration == 'month') {
            if (isCurrentYear(runnerProvider.runs[i])) {
              if (x == runnerProvider.runs[i].activityStartTime.month) {
                xValue++;
              }
            }
          }
          if (setting.duration == 'all time') {
            if (runnerProvider.runs[i].activityStartTime.year ==
                (DateTime.now().year - x)) {
              xValue++;
            }
          }
        }
        return xValue;
      };
    default:
      return () {};
  }
}

//Function that builds the x-axis and calculate the y-value

BarChartGroupData chartData(
  int x,
  RunnerProvider runnerProvider,
  Settings setting,
  UnitsProvider unitsProvider,
) {
  int allTime = 0;
  if (setting.duration == 'all time') {
    allTime = -1;
  }
  Function valueOnYAxis = chartTypeXDefiner(setting);
  double yValue = valueOnYAxis(x + 1 + allTime, runnerProvider);
  Color color = Colors.black;
  if (setting.toolTipUnit == 'ft') {
    yValue = yValue * 3.28;
  }
  if (setting.toolTipUnit == 'mi') {
    yValue = yValue * 0.621371192;
  }

  return BarChartGroupData(
    x: x,
    barRods: [
      BarChartRodData(
        toY: yValue,
        color: color,
        width: 20,
        borderRadius: const BorderRadius.vertical(),
      ),
    ],
  );
}

//Helper functiom that checks if activities started on the current year.

bool isCurrentYear(ActivityData run) {
  if (DateTime.now().year == run.activityStartTime.year) {
    return true;
  } else {
    return false;
  }
}

//Check if a date is in current week.

bool isCurrentWeek(ActivityData data) {
  if (data.activityStartTime.isAfter(firstDateOfTheWeek(DateTime.now())) &&
      data.activityStartTime.isBefore(lastDateOfTheWeek(DateTime.now()))) {
    return true;
  }
  return false;
}

//2 helper functions to determine if a date is in a week

DateTime firstDateOfTheWeek(DateTime date) =>
    DateTime(date.year, date.month, date.day - (date.weekday - 1));

DateTime lastDateOfTheWeek(DateTime date) =>
    date.add(Duration(days: DateTime.daysPerWeek - date.weekday));

//Function that calculates the max grading of the Y-axis making sure the bars fit.

double maxYValue(RunnerProvider runnerProvider, Settings setting,
    UnitsProvider unitsProvider) {
  double maxY = 0;
  Function valueOnXAxis = chartTypeXDefiner(setting);
  List<double> yValues = [];
  for (int i = 0; i < setting.xAxis; i++) {
    yValues.add(valueOnXAxis(i, runnerProvider));
    if (i == 0) {
      maxY = yValues[i];
    } else {
      if (yValues[i] > yValues[i - 1] && yValues[i] > maxY) {
        maxY = yValues[i];
      }
    }
  }

  if (setting.toolTipUnit != 'm' && unitsProvider.elevationUnit == 'ft') {
    maxY = maxY * 3.28;
  }

  if (maxY < 10) {
    return (maxY + (10 - maxY % 10));
  } else if (maxY >= 10 && maxY < 100) {
    return (maxY + (100 - maxY % 100));
  } else {
    return (maxY + (1000 - maxY % 1000));
  }
}

//Helper function that styles the text.

AxisTitles axisTitle(SideTitles sideTitle, String title, double size) {
  return AxisTitles(
    sideTitles: sideTitle,
    axisNameWidget: Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        letterSpacing: 1.1,
        fontWeight: FontWeight.w500,
      ),
    ),
    axisNameSize: size,
  );
}
