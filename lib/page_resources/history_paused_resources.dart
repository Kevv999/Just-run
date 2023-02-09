import 'dart:ui';
import '/activity_resources/activity_timers.dart';

import 'package:flutter/material.dart';

import 'package:project_mobile_app/models/activityProvider.dart';
import 'package:project_mobile_app/charts/pace_chart.dart';
import 'package:project_mobile_app/models/units_provider.dart';

import 'package:provider/provider.dart';

import '/models/runner_provider.dart';
import '/activity_resources/gps_tracking.dart';
import '/activity_resources/stats_fields.dart';

Padding charts(ActivityData activityData) {
  return Padding(
    padding: const EdgeInsets.all(5),
    child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
            decoration: const BoxDecoration(color: Colors.white),
            child: LineChartWidget(activityData))),
  );
}

/* Butto to either finish the run or continue it */
Column finnishResumeButtons(
  BuildContext context,
  GlobalKey<StopwatchTimerState>? timerKey,
  GlobalKey<DistanceFieldState>? distanceKey,
) {
  return Column(
    children: [
      Row(
        children: [
          Expanded(
            flex: 5,
            child: Center(
                child: RawMaterialButton(
              padding: const EdgeInsets.all(25),
              onPressed: () {
                timerKey!.currentState?.startTimer();
                distanceKey!.currentState?.pauseAndUnpause(true);
                Navigator.of(context).pop(); // Perform some action
                /* Start the clock again and pop the widget out of its place 
                for continues tracking of the run */
              },
              child: Column(
                children: [
                  const Icon(
                    Icons.play_arrow,
                    size: 75,
                    color: Colors.white,
                  ),
                ],
              ),
              shape: const CircleBorder(),
              fillColor: Colors.green,
              elevation: 8.0,
              highlightColor: Colors.lightGreen,
              splashColor: Colors.greenAccent,
            )),
          ),
          Expanded(
            flex: 5,
            child: Center(
                child: RawMaterialButton(
              padding: const EdgeInsets.all(25),
              onPressed: () {
                /* Pop up for making sure that
                you defenitly want to finnish the run */
                dialogButton(context);
              },
              child: Column(
                children: [
                  const Icon(
                    Icons.done,
                    size: 75,
                    color: Colors.white,
                  ),
                ],
              ),
              shape: const CircleBorder(),
              fillColor: Colors.red,
              elevation: 8.0,
              highlightColor: Colors.red,
              splashColor: const Color.fromARGB(255, 230, 122, 115),
            )),
          ),
        ],
      ),
      const SizedBox(
        height: 100,
      )
    ],
  );
}

Future<dynamic> dialogButton(BuildContext context) {
  return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: const Color.fromARGB(255, 30, 196, 179),
            title: const Center(
                child: Text(
              "Complete run",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            )),
            content: Container(
              width: double.maxFinite,
              height: 50,
              child: const Expanded(
                  child: Text('Are you sure you want to exit your workout',textAlign: TextAlign.center, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: Container(
                     decoration: BoxDecoration(
                        color: Theme.of(context).canvasColor, 
                        borderRadius: BorderRadius.circular(12), 
                      ),
                      padding: const EdgeInsets.all(14),
                      child: const Text('Cancel',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.white)),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      /* If run is to be finnished, a run gets initialized and added in the
                      lists of runs in the main provider, Runnerprovidern  */
                      RunnerProvider runnerProvider =
                          Provider.of<RunnerProvider>(context, listen: false);
                      ActivityDataProvider activityDataProvider =
                          Provider.of<ActivityDataProvider>(context,
                              listen: false);
                      ActivityData test = ActivityData(
                        id: runnerProvider.runs.isEmpty
                            ? 1
                            : runnerProvider.runs.last.id + 1,
                        paces: activityDataProvider.paces,
                        calories: activityDataProvider.calories,
                        distance: activityDataProvider.distance,
                        avgPace: activityDataProvider.avgPace,
                        activityDuration: activityDataProvider.activityDuration,
                        activityStartTime:
                            activityDataProvider.activityStartTime,
                        elevation: activityDataProvider.elevation,
                        speed: activityDataProvider.speed,
                        route: activityDataProvider.route,
                      );

                      runnerProvider.add(test);
                      /* Pop until first page so the current run is "removed from widget tree" */
                      Navigator.popUntil(context, ModalRoute.withName("/"));
                      Navigator.pushNamed(context, "/viewActivity",
                          arguments: PausedParameters(
                              activityData: test,
                              isPaused: false,
                              timerKey: null,
                              distanceKey: null));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).canvasColor, 
                        borderRadius: BorderRadius.circular(12), 
                      ),
                      padding: const EdgeInsets.all(14),
                      child: const Text('Finish',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ));
}

/* For displaying all the data in crads format when 
viewing a run ion both paused and finiished run */
Expanded displayCard(BuildContext context, String headline, String data) {
  UnitsProvider unitsProvider = Provider.of<UnitsProvider>(context);
  return Expanded(
    flex: 5,
    child: Card(
      color: Theme.of(context).canvasColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        side: BorderSide(color: Colors.black, width: 1.0),
      ),
      child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.tealAccent, Colors.teal],
            ),
          ),
          width: 200,
          height: 80,
          child: Container(
            margin: const EdgeInsets.all(8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          headline,
                          style: Theme.of(context)
                              .textTheme
                              .headline1
                              ?.copyWith(
                                  fontSize: 20, fontWeight: FontWeight.w500),
                        )),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text.rich(
                        TextSpan(
                          children: <InlineSpan>[
                            WidgetSpan(
                              child: Builder(
                                builder: (context) {
                                  if (headline == "Distance" ||
                                      headline == "Avg. Pace" ||
                                      headline == "Max Speed" ||
                                      headline == "Estimated") {
                                    return RichText(
                                      text: TextSpan(
                                        text: headline == "Distance"
                                            ? unitsProvider.disctanceUnit
                                            : headline == "Avg. Pace"
                                                ? "min/${unitsProvider.disctanceUnit}"
                                                : headline == "Estimated"
                                                    ? "10 ${unitsProvider.disctanceUnit}"
                                                    : "min/${unitsProvider.disctanceUnit}",
                                        style: const TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                    );
                                  } else if (headline == "Elevation") {
                                    return RichText(
                                        text: TextSpan(
                                      text: unitsProvider.elevationUnit,
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ));
                                  } else if (headline == "Calories") {
                                    return RichText(
                                        text: const TextSpan(
                                      text: 'kcal',
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ));
                                  } else {
                                    return RichText(
                                      text: const TextSpan(
                                        text: "",
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    data,
                    style: Theme.of(context)
                        .textTheme
                        .headline3
                        ?.copyWith(fontSize: 35),
                  ),
                ),
              ],
            ),
          )),
    ),
  );
}
