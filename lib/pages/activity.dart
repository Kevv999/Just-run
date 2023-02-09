import 'dart:async';
import '/activity_resources/gps_tracking.dart';
import '/activity_resources/stats_fields.dart';
import '/activity_resources/activity_timers.dart';
import 'package:project_mobile_app/models/activityProvider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import '/models/runner_provider.dart';

class Activity extends StatefulWidget {
  const Activity({super.key});

  @override
  State<Activity> createState() => _ActivityState();
}

class _ActivityState extends State<Activity> {
  //keys to access timer and distance fucntions outside of class
  final GlobalKey<StopwatchTimerState> timerKey =
      GlobalKey<StopwatchTimerState>();
  final GlobalKey<DistanceFieldState> distanceKey =
      GlobalKey<DistanceFieldState>();
  late ActivityDataProvider activityData =
      Provider.of<ActivityDataProvider>(context, listen: false);
  bool showCountdownOverlay = true;

  //Remove the countdown overlay and start the activity
  void setCountdownBool() {
    setState(() {
      showCountdownOverlay = false;
      distanceKey.currentState!.pauseAndUnpause(true);
      timerKey.currentState!.startTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    RunnerProvider runnerProvider = Provider.of<RunnerProvider>(context);
    final CountdownOverlay overlay = CountdownOverlay(
      stopDisplayingOverlay: setCountdownBool,
      speech: runnerProvider.textToSpeechOn,
    );
    activityData.paces = [];
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          backgroundColor: Theme.of(context).canvasColor,
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Center(
                    child: Column(children: [
                  ActivityStatsFields(
                    myKey: timerKey,
                    distanceKey: distanceKey,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  //pause button, pause activity tracking and push the stats page.
                  //Sending keys to timer & distance to be able to resume tracking
                  RawMaterialButton(
                    padding: EdgeInsets.all(25),
                    onPressed: (() {
                      timerKey.currentState?.pause();
                      distanceKey.currentState?.pauseAndUnpause(false);

                      Navigator.pushNamed(context, "/viewActivity",
                          arguments: PausedParameters(
                              activityData: ActivityData(
                                  id: 0,
                                  calories: activityData.calories,
                                  distance: activityData.distance,
                                  avgPace: activityData.avgPace,
                                  elevation: activityData.elevation,
                                  speed: activityData.speed,
                                  activityStartTime:
                                      activityData.activityStartTime,
                                  route: activityData.route,
                                  paces: activityData.paces,
                                  activityDuration:
                                      activityData.activityDuration),
                              isPaused: true,
                              timerKey: timerKey,
                              distanceKey: distanceKey));
                    }),
                    child: Icon(
                      Icons.pause,
                      color: Colors.white,
                      size: 75,
                    ),
                    shape: CircleBorder(),
                    fillColor: Colors.red,
                    elevation: 8.0,
                    highlightColor: Colors.red,
                    splashColor: Color.fromARGB(255, 230, 122, 115),
                  ),
                ])),
              ),
              //show the countdown overlay untill timer expires and bool turns false
              if (showCountdownOverlay) overlay,
            ],
          )),
    );
  }
}
