import 'package:flutter/physics.dart';
import 'package:geolocator/geolocator.dart';
import 'package:project_mobile_app/models/runner_provider.dart';
import 'package:project_mobile_app/models/units_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:project_mobile_app/models/activityProvider.dart';
import 'package:latlong2/latlong.dart';
import 'package:project_mobile_app/charts/pace_chart.dart';


/* Data for storing data on an ongoing run  */
class ActivityDataProvider extends ChangeNotifier {
  late int id = -1;
  late double calories = 0;
  late double distance = 0;
  late double elevation = 0;
  late Duration? avgPace = Duration(seconds: 0);
  late Duration speed = Duration(seconds: 0);
  late Duration activityDuration;

  late DateTime activityStartTime;
  late DateTime activityEndTime;
  late bool lessThenHour = false;
  List<LatLng> route = [];
  List<ShowPoint> paces = [];
  List<Duration> avgPacePerDistanceUnit = [Duration(seconds: 0)];
  int durIndex = 0;

  ActivityData(
      {id,
      calories,
      distance,
      elevation,
      avgPace,
      speed,
      activiyDuration,
      activityStartTime,
      activityEndTime}) {
    //This has impact on the presentation of this data
    if (activityDuration.inHours < 1) lessThenHour = true;
  }

  addStartTime(DateTime start) {
    activityStartTime = start;
  }

  addDistance(double dist) {
    distance = dist;
  }

  addDuration(Duration? dur) {
    activityDuration = dur!;
  }

  addElevation(double elev) {
    elevation = elev;
  }

  addAvgPace(Duration? avg) {
    avgPace = avg;
  }

  addListAll(List<ShowPoint> list) {
    paces = [];
    for (ShowPoint point in list) {
      paces.add(ShowPoint(pace: point.pace, time: point.time));
    }
  }

  /* Add points for the chart and evaluating the current speed if its higher or not */
  addLineChartValue(Duration? avg, Duration? time) {
    paces.add(ShowPoint(pace: avg!, time: time as Duration));
    if (speed.inSeconds == 0) {
      speed = avg;
      return;
    }
    if (speed.compareTo(avg) > 0 && avg.inSeconds != 0) {
      speed = avg;
      return;
    }
  }

  addPositionalData(Position? pos) {
    if (pos != null) {
      route.add(LatLng(pos.latitude, pos.longitude));
    }
  }

  addCalories(double cals) {
    calories = cals;
  }


/* Cearing the route and preparing for a new one */
  clearRoute() {
    route = [];
    durIndex = 0;
    avgPacePerDistanceUnit.clear();
    avgPacePerDistanceUnit.add(Duration(seconds: 0));
    speed = Duration(seconds: 0);
    avgPace = Duration(seconds: 0);
  }

  String getAveragePace(Unit unit) {
    if (distance > 0 && activityDuration.inSeconds > 0) {
      Duration temp = Duration(seconds: avgPaceInSeconds());
      return "${addZero(temp.inMinutes.remainder(60))}:${addZero(temp.inSeconds.remainder(60))}";
    }
    return "- - : - -";
  }

  String addZero(int i) {
    return i.toString().padLeft(2, '0');
  }

  String getDistance(Unit unit) {
    if (distance >= 0) {
      if (unit == Unit.metric) {
        return (distance / 1000).toStringAsFixed(0);
      } else {
        return (distance / 1609).toStringAsFixed(0);
      }
    }
    return "0";
  }

  int avgPaceInSeconds() {
    Duration lastDistance = activityDuration - avgPacePerDistanceUnit[durIndex];
    avgPacePerDistanceUnit.add(activityDuration);
    durIndex++;

    if (activityDuration.inSeconds != 0) {
      return lastDistance.inSeconds;
    }
    return 0;
  }
}
