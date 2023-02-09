import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:project_mobile_app/models/units_provider.dart';
import 'package:project_mobile_app/pages/newsetting.dart';
import 'dart:io';
import 'package:project_mobile_app/charts/pace_chart.dart';
import 'package:latlong2/latlong.dart';
//import 'package:provider/provider.dart';


/* The main provider
here all runs are stored and data about the user */
class RunnerProvider extends ChangeNotifier {
  final List<ActivityData> _runs = [];

  List<ActivityData> get runs => _runs;
  initRun(ActivityData data) => _runs.add(data);
  double totalDistance = 0;
  Duration totalDuration = Duration(seconds: 0);
  double totalCalories = 0;
  int age = 19;
  Genders gender = Genders.Male;
  double height = 198.4;
  double weight = 80.7;
  bool textToSpeechOn = true;

/* For initializing all the runs the first 
time its used  */
  initAdd(ActivityData run) {
    if(!_runs.contains(run))
    {
      _runs.add(run);
      totalDistance += run.distance;
      totalDuration += run.activityDuration!;
      totalCalories += run.calories;
    }
  }
/* For cahninging info about the runner, this data is written 
to a duffrent file for performence benifits instead of 
removing and writing all runs also  */
  changeRunnerInfo(UnitsProvider unitsProvider) async {
    double heightJson;
    double weightJson;
    if (unitsProvider.unit == Unit.metric) {
      heightJson = height;
      weightJson = weight;
    } else {
      heightJson = unitsProvider.convertHeight(height, Unit.metric);
      weightJson = unitsProvider.convertWeight(weight, Unit.metric);
    }
    Map<String, dynamic> json = {
      "speech": textToSpeechOn,
      "age": age,
      "gender": gender.index,
      "height": heightJson,
      "weight": weightJson,
    };
    notifyListeners();
    File file = await getFile("runnerInfo.json");
    file.writeAsStringSync(jsonEncode(json));
  }

/* Add a new run */
  add(ActivityData run) async {
    if (_runs.isEmpty) {
      run.id = 1;
    } else {
      run.id = runs.last.id + 1;
    }

    _runs.add(run);
    totalDistance += run.distance;
    totalDuration += run.activityDuration!;
    totalCalories += run.calories;
    var temp = jsonEncode(runs);

    /* Writing to a diffrent file then the user info */
    File file = await getFile("runs.json");

    file.writeAsStringSync(temp, flush: true, mode: FileMode.write);

    ///REMOVE THIS TO FIX JSON
    notifyListeners();
  }
  /* Deleting a run from both the list and from the file */
  delete(ActivityData run) async {
    _runs.remove(run);
    totalDuration = totalDuration - run.activityDuration!;
    totalDistance = totalDistance - run.distance;
    totalCalories = totalCalories - run.calories;
    File file = await getFile("runs.json");
    var temp = jsonEncode(runs);
    /* Writing the new runs to the file  
    and overwriting the old ones*/
    file.writeAsStringSync(temp);
    notifyListeners();
  }

/* A static function tha is used on diffrent places */
  static Future<File> getFile(String name) async {
    final directory = await getApplicationDocumentsDirectory();
    String path = directory.path;
    bool doesFileExists = await File('$path/$name').exists();
    if (!doesFileExists) {
      await File('$path/$name').create();
    }
    final File file = File('$path/$name');
    return file;
  }
}

/* Class for storing data about a run */
class ActivityData {
  int id;
  double calories;
  double distance;
  Duration? avgPace;
  Duration? activityDuration;
  DateTime activityStartTime;
  double elevation;
  Duration speed;
  List<LatLng> route = [];
  List<ShowPoint> paces = [];
  bool lessThenHour = false;


  ActivityData({
    required this.id,
    required this.calories,
    required this.distance,
    required this.avgPace,
    required this.elevation,
    required this.speed,
    required this.activityStartTime,
    required this.route,
    required this.paces,
    required this.activityDuration,
  }) {
    if (activityDuration!.inHours < 1) lessThenHour = true;
  }
  /* @override */
  Map<String, dynamic> toJson() => {
        "id": id,
        "calories": calories,
        "distance": distance,
        "avgPace": avgPace!.inSeconds,
        "startTime": activityStartTime.toString(),
        "route": route,
        "paces": paces,
        "duration": activityDuration!.inSeconds,
        "lessThenHour": lessThenHour,
        "speed": speed.inSeconds,
        "elevation": elevation
      };

  @override
  bool operator ==(dynamic other) =>
      other != null &&
      other is ActivityData &&
      distance == other.distance &&
      activityStartTime == other.activityStartTime &&
      id == other.id;
  //&& activityEndTime == other.activityEndTime;

  @override
  int get hashCode => super.hashCode;
}
