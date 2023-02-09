import 'gps_tracking.dart';
import 'activity_timers.dart';
import 'package:project_mobile_app/models/activityProvider.dart';
import 'package:project_mobile_app/models/units_provider.dart';
import 'package:provider/provider.dart';
import '/page_resources/history_paused_resources.dart';
import 'package:flutter/material.dart';
import '/models/runner_provider.dart';

class ActivityStatsFields extends StatefulWidget {
  final GlobalKey<StopwatchTimerState> myKey;
  final GlobalKey<DistanceFieldState> distanceKey;
  const ActivityStatsFields(
      {super.key, required this.myKey, required this.distanceKey});

  @override
  State<ActivityStatsFields> createState() => _ActivityStatsFieldsState();
}

class _ActivityStatsFieldsState extends State<ActivityStatsFields> {
  Duration currentAvgPace = Duration();
  double oldDistance = 0;
  //update the distance from distanceField (gpstracking widget)
  void updateDistance(double dist) {
    setState(() {
      distance = dist;
    });
  }

  //update the duration from stopwatchTimer (timer widget)
  void updateDuration(Duration dur) {
    setState(() {
      duration = dur;
      if (duration.inSeconds % 10 == 0) {
        currentAvgPace = Duration(
            seconds: avgPaceInSeconds((distance - oldDistance) / 1000, 10));
        oldDistance = distance;

        activityData.addLineChartValue(currentAvgPace, duration);
      }
    });
  }

  //calulcate avg pace
  int avgPaceInSeconds(double distance, int timeInSeconds) {
    if (timeInSeconds != 0 && distance != 0.0) {
      return timeInSeconds ~/ distance;
    }
    return 0;
  }

  final now = DateTime.now();
  Duration tempDur = const Duration(seconds: 0);
  Duration estematedTime = const Duration(seconds: 0);
  Duration duration = const Duration(seconds: 0);
  double distance = 0;
  late ActivityDataProvider activityData =
      Provider.of<ActivityDataProvider>(context, listen: false);

  late UnitsProvider unitsProvider = Provider.of<UnitsProvider>(context);
  late RunnerProvider runnerProvider = Provider.of<RunnerProvider>(context);
  late StopwatchTimer stopwatch;
  late DistanceField distanceCard;

  @override
  Widget build(BuildContext context) {
    distanceCard = DistanceField(
      paceDistanceUpdate: updateDistance,
      key: widget.distanceKey,
    );
    stopwatch = StopwatchTimer(
      key: widget.myKey,
      paceAvgUpdateDuration: updateDuration,
    );
    //update the providers
    activityData.addStartTime(now);
    activityData.addDistance(distance);
    activityData.addDuration(duration);

    //calculate avg pace
    var tempforDur = Duration(
        seconds: avgPaceInSeconds(distance / 1000, duration.inSeconds));
    unitsProvider.unit == Unit.metric
        ? tempDur = tempforDur
        : tempDur = Duration(
            seconds: avgPaceInSeconds(distance / 1600, duration.inSeconds));
    activityData.addAvgPace(tempforDur);

    //calulate calories burned
    var cals = returnCals(
        tempforDur, unitsProvider.unit, runnerProvider.weight, duration);
    activityData.addCalories(cals);
    estematedTime = Duration(seconds: tempforDur.inSeconds * 10);
    //display the stats
    return Column(
      children: [
        const SizedBox(
          height: 130,
        ),
        stopwatch,
        distanceCard,
        Row(children: [
          displayCard(
              context,
              "Avg. Pace",
              tempDur.inHours != 0
                  ? "${tempDur.inHours.remainder(60)}:${addZero(tempDur.inMinutes.remainder(60))}:${addZero(tempDur.inSeconds.remainder(60))}"
                  : "${addZero(tempDur.inMinutes.remainder(60))}:${addZero(tempDur.inSeconds.remainder(60))}"),
          displayCard(
              context,
              "Estimated",
              estematedTime.inHours != 0
                  ? "${estematedTime.inHours.remainder(60)}:${addZero(estematedTime.inMinutes.remainder(60))}:${addZero(estematedTime.inSeconds.remainder(60))}"
                  : "${addZero(estematedTime.inMinutes.remainder(60))}:${addZero(estematedTime.inSeconds.remainder(60))}")
        ]),
        /* SizedBox(
          height: 75,
        ) */
      ],
    );
  }
}

//class for parameters to be sent to pause page
class PausedParameters {
  late bool isPaused;
  GlobalKey<StopwatchTimerState>? timerKey;
  GlobalKey<DistanceFieldState>? distanceKey;
  ActivityData activityData;
  PausedParameters({
    required this.isPaused,
    required this.timerKey,
    required this.distanceKey,
    required this.activityData,
  });
}

//function to calculate calories burned
double returnCals(Duration? avgPace, Unit unit, double weight, Duration? time) {
  double MET = 0;
  if (unit == Unit.metric) {
    if (avgPace!.inSeconds >= 445) {
      MET = 8.3;
    } else if (avgPace.inSeconds > 375) {
      MET = 9.8;
    } else if (avgPace.inSeconds > 337) {
      MET = 10.5;
    } else if (avgPace.inSeconds > 299) {
      MET = 11.5;
    } else if (avgPace.inSeconds > 241) {
      MET = 12.3;
    } else if (avgPace.inSeconds > 224) {
      MET = 14.5;
    } else if (avgPace.inSeconds > 0) {
      MET = 19;
    } else if (avgPace.inSeconds == 0) {
      MET = 0;
    }
  } else {
    if (avgPace!.inSeconds >= 720) {
      MET = 8.3;
    } else if (avgPace.inSeconds > 600) {
      MET = 9.8;
    } else if (avgPace.inSeconds > 540) {
      MET = 10.5;
    } else if (avgPace.inSeconds > 480) {
      MET = 11.5;
    } else if (avgPace.inSeconds > 420) {
      MET = 12.3;
    } else if (avgPace.inSeconds > 300) {
      MET = 14.5;
    } else if (avgPace.inSeconds > 0) {
      MET = 19;
    } else if (avgPace.inSeconds == 0) {
      MET = 0;
    }
    weight = weight / 2.20462262185;
  }

  var calories = (((MET * 3.5 * weight) / 200)) * (time!.inSeconds / 60);
  /*
    if (gender == Genders.Male) {
      calories =
          (((MET * 3.5 * weight) / 200)) * (activityDuration.inSeconds / 60);
    } else if (gender == Genders.Female) {
      calories = (((MET * 3.5 * weight) / 200)) *
          (activityDuration.inSeconds / 60) *
          0.92;
    } else {
      calories =
          ((((MET * 3.5 * weight) / 200)) * (activityDuration.inSeconds / 60) +
                  (((MET * 3.5 * weight) / 200)) *
                      (activityDuration.inSeconds / 60) *
                      0.92) /
              2;
    }*/

  return calories;
}

////////////////////////////////////////////////////////////////////////
//&&&&&&&&&&&/Card for displaying the stats////////&&&&&&&&&&&&&&&////
Card cardBox(String rubric, String value, Unit unit, context) {
  return Card(
    //margin: EdgeInsets.all(8),
    shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.black, width: 2.0),
        borderRadius: BorderRadius.circular(12)),
    child: Container(
        width: 500,
        height: 150,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.tealAccent, Colors.teal],
          ),
        ),
        child: Column(children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(15.0, 5.0, 0, 0),
                  child: Text(
                    rubric,
                    style: Theme.of(context)
                        .textTheme
                        .headline1
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 5, 15, 0),
                child: Text(
                  rubric == "Distance"
                      ? unit == Unit.metric
                          ? "km"
                          : "mi"
                      : "",
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 20),
                ),
              ))
            ],
          ),
          Expanded(
            child: Center(
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
            ),
          ),
        ])),
  );
}
