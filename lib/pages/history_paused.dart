import 'dart:ui';
import '/activity_resources/activity_timers.dart';
import 'package:project_mobile_app/pages/activity.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:project_mobile_app/models/activityProvider.dart';
import 'package:project_mobile_app/charts/pace_chart.dart';
import 'package:project_mobile_app/models/units_provider.dart';
import 'package:project_mobile_app/pages/newsetting.dart';
import 'package:provider/provider.dart';
import 'package:project_mobile_app/charts/pace_chart.dart';
import '../page_resources/map.dart';
import '../charts/pace_chart.dart';
import '/models/runner_provider.dart';
import '/activity_resources/gps_tracking.dart';
import '/activity_resources/stats_fields.dart';
import '/page_resources/history_paused_resources.dart';

class RunInfo {
  const RunInfo({required this.title, required this.text});

  final String title;
  final String text;
}

class ExtendHistory extends StatefulWidget {
  const ExtendHistory({super.key});

  @override
  State<ExtendHistory> createState() => _ExtendHistoryState();
}

class _ExtendHistoryState extends State<ExtendHistory> {
  late ActivityDataProvider activityData =
      Provider.of<ActivityDataProvider>(context);

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    final PausedParameters parameters =
        ModalRoute.of(context)?.settings.arguments as PausedParameters;
    bool isPaused = parameters.isPaused;
    /* For choosing which type of the widget thats going to be displayed */
    ActivityData activityData = parameters.activityData;
    UnitsProvider unitsProvider = Provider.of<UnitsProvider>(context);
    RunnerProvider runnerProvider = Provider.of<RunnerProvider>(context);
    Duration currentUnitAvgPace = activityData.avgPace as Duration;
    Duration speed;
    if (unitsProvider.unit == Unit.imperial) {
      currentUnitAvgPace = Duration(
          seconds: (activityData.avgPace!.inSeconds * 1.609344).toInt());
      speed =
          Duration(seconds: (activityData.speed.inSeconds * 1.609344).toInt());
    } else {
      speed = activityData.speed;
    }
    /* Deppeninding on if the run is a paused run or 
    you are viewing a old run the finnish, resume button will be displayed.
    This also affects the chart for showing avrage pace.  */
    return WillPopScope(
      onWillPop: isPaused == true ? () async => false : () async => true,
      child: Scaffold(
          backgroundColor: Theme.of(context).canvasColor,
          appBar: isPaused
              ? null
              : AppBar(
                  iconTheme: const IconThemeData(
                    color: Colors.black,
                  ),
                  centerTitle: true,
                  title: Text(
                    DateFormat('yyyy-MM-dd – kk:mm')
                        .format(activityData.activityStartTime),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
          body: Stack(children: [
            Container(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: SafeArea(
                  child: SingleChildScrollView(
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                              padding: const EdgeInsets.all(5),
                              child: Container(
                                height: 225,
                                width: 400,
                                decoration: const BoxDecoration(
                                    boxShadow: [BoxShadow(blurRadius: 20.0)]),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: myMap(route: activityData.route),
                                ),
                              )),
                          Row(
                            children: [
                              displayCard(
                                context,
                                "Time",
                                activityData.activityDuration!.inHours != 0
                                    ? "${addZero(activityData.activityDuration!.inHours.remainder(60))}:${addZero(activityData.activityDuration!.inMinutes.remainder(60))}:${addZero(activityData.activityDuration!.inSeconds.remainder(60))}"
                                    : "${addZero(activityData.activityDuration!.inMinutes.remainder(60))}:${addZero(activityData.activityDuration!.inSeconds.remainder(60))}",
                              ),
                              displayCard(
                                  context,
                                  "Distance",
                                  unitsProvider.unit == Unit.metric
                                      ? (activityData.distance / 1000)
                                          .toStringAsFixed(2)
                                      : (activityData.distance / 1600)
                                          .toStringAsFixed(2)),
                            ],
                          ),
                          Row(
                            children: [
                              displayCard(
                                context,
                                "Avg. Pace",
                                currentUnitAvgPace.inHours != 0
                                    ? "${addZero(currentUnitAvgPace.inHours.remainder(60))}:${addZero(currentUnitAvgPace.inMinutes.remainder(60))}:${addZero(currentUnitAvgPace.inSeconds.remainder(60))}"
                                    : "${addZero(currentUnitAvgPace.inMinutes.remainder(60))}:${addZero(currentUnitAvgPace.inSeconds.remainder(60))}",
                              ),
                              displayCard(
                                  context,
                                  "Max Speed",
                                  speed.inHours != 0
                                      ? "${addZero(speed.inHours.remainder(60))}:${addZero(speed.inMinutes.remainder(60))}:${addZero(speed.inSeconds.remainder(60))}"
                                      : "${addZero(speed.inMinutes.remainder(60))}:${addZero(speed.inSeconds.remainder(60))}")
                            ],
                          ),
                          Row(
                            children: [
                              displayCard(
                                  context,
                                  "Calories",
                                  runnerProvider.gender == Genders.Male
                                      ? activityData.calories.toStringAsFixed(0)
                                      : runnerProvider.gender == Genders.Female
                                          ? (activityData.calories * 0.92)
                                              .toStringAsFixed(0)
                                          : ((activityData.calories +
                                                      activityData.calories *
                                                          0.92) /
                                                  2)
                                              .toStringAsFixed(0)),
                              displayCard(
                                  context,
                                  "Elevation",
                                  unitsProvider.unit == Unit.metric
                                      ? activityData.elevation
                                          .toStringAsFixed(0)
                                      : (activityData.elevation * 32.81)
                                          .toStringAsFixed(0)),
                            ],
                          ),
                          isPaused/* Either displaying a chart for avrage pace or makeing you able to 
                          continue the current run */
                              ? const SizedBox(height: 25)
                              : const SizedBox(height: 0),
                          isPaused
                              ? finnishResumeButtons(context,
                                  parameters.timerKey, parameters.distanceKey)
                              : charts(activityData),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          ])),
    );
  }
}
