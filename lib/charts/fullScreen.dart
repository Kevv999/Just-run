import 'package:flutter/material.dart';
import 'package:project_mobile_app/charts/chart.dart';
import 'package:provider/provider.dart';
import '../models/units_provider.dart';
import '../models/runner_provider.dart';
import 'package:flutter/services.dart';
import 'chart_settings.dart';

class Fullscreen extends StatefulWidget {
  const Fullscreen({super.key});
  @override
  State<Fullscreen> createState() => _FullscreenState();
}

class _FullscreenState extends State<Fullscreen> with WidgetsBindingObserver {
  late RunnerProvider runnerProvider = Provider.of<RunnerProvider>(context);
  late UnitsProvider unitsProvider = Provider.of<UnitsProvider>(context);
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
  }

  @override
  void didChangeMetrics() {
    if (MediaQuery.of(context).orientation != Orientation.landscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
      ]);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget build(BuildContext context) {
    Settings setting = ModalRoute.of(context)?.settings.arguments as Settings;
    fillSettings(setting);
    return WillPopScope(
      onWillPop: () async {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          leading: const BackButton(
            color: Colors.black,
          ),
          title: Text(
            setting.chartType,
            style: const TextStyle(
              color: Colors.black,
            ),
          ),
        ),
        body: Chart(runnerProvider: runnerProvider, setting: setting),
      ),
    );
  }
/* A long if statement do chosse what to display in the charts */
  void fillSettings(Settings setting) {
    String unit = 'feets';
    String distanceTooltipUnit = 'mi';
    String elevationTooltipUnit = 'ft';
    if (unitsProvider.unit == Unit.metric) {
      unit = 'meter';
      distanceTooltipUnit = 'km';
      elevationTooltipUnit = 'm';
    }

    if (setting.duration == 'week') {
      if (setting.chartType == 'Distance') {
        setting.bottomTitle = 'Weekday';
        setting.leftTitle = 'Distance in ${unitsProvider.disctanceUnit}';
        setting.topTitle = 'Distance this Week';
        setting.toolTipUnit = distanceTooltipUnit;
      }
      if (setting.chartType == 'Calories') {
        setting.bottomTitle = 'Weekday';
        setting.leftTitle = 'Calories burnt';
        setting.topTitle = 'Calories burnt this week';
        setting.toolTipUnit = 'Kcal';
      }
      if (setting.chartType == 'Activity Count') {
        setting.bottomTitle = 'Weekday';
        setting.leftTitle = 'Number of activities';
        setting.topTitle = 'Activities this week';
        setting.toolTipUnit = '';
      }
      if (setting.chartType == 'Elevation') {
        setting.bottomTitle = 'Weekday';
        setting.leftTitle = 'Elevation in $unit';
        setting.topTitle = 'Elevation climbed this week';
        setting.toolTipUnit = elevationTooltipUnit;
      }
    }
    if (setting.duration == 'month') {
      if (setting.chartType == 'Distance') {
        setting.bottomTitle = 'Month';
        setting.leftTitle = 'Distance in ${unitsProvider.disctanceUnit}';
        setting.topTitle = 'Distance per Month';
        setting.toolTipUnit = distanceTooltipUnit;
      }
      if (setting.chartType == 'Calories') {
        setting.bottomTitle = 'Month';
        setting.leftTitle = 'Calories burnt';
        setting.topTitle = 'Calories burnt per month';
        setting.toolTipUnit = 'Kcal';
      }
      if (setting.chartType == 'Activity Count') {
        setting.bottomTitle = 'Month';
        setting.leftTitle = 'Number of activities';
        setting.topTitle = 'Activities per month';
        setting.toolTipUnit = '';
      }
      if (setting.chartType == 'Elevation') {
        setting.bottomTitle = 'Month';
        setting.leftTitle = 'Elevation in $unit';
        setting.topTitle = 'Elevation climbed per month';
        setting.toolTipUnit = elevationTooltipUnit;
      }
    }
    if (setting.duration == 'all time') {
      if (setting.chartType == 'Distance') {
        setting.bottomTitle = 'Year';
        setting.leftTitle = 'Distance in ${unitsProvider.disctanceUnit}';
        setting.topTitle = 'Distance per year';
        setting.toolTipUnit = distanceTooltipUnit;
      }
      if (setting.chartType == 'Calories') {
        setting.bottomTitle = 'Year';
        setting.leftTitle = 'Calories burnt';
        setting.topTitle = 'Calories burnt per year';
        setting.toolTipUnit = 'Kcal';
      }
      if (setting.chartType == 'Activity Count') {
        setting.bottomTitle = 'Year';
        setting.leftTitle = 'Number of activities';
        setting.topTitle = 'Activities per year';
        setting.toolTipUnit = '';
      }
      if (setting.chartType == 'Elevation') {
        setting.bottomTitle = 'Year';
        setting.leftTitle = 'Number of ${unitsProvider.disctanceUnit} climbed';
        setting.topTitle = 'Elevation in $unit';
        setting.toolTipUnit = elevationTooltipUnit;
      }
    }
  }
}
