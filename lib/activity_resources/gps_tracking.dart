import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:project_mobile_app/models/activityProvider.dart';
import 'package:project_mobile_app/models/units_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:text_to_speech/text_to_speech.dart';
import '/models/runner_provider.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'stats_fields.dart';

class DistanceField extends StatefulWidget {
  //fucntion to update distance in parent widget
  final Function paceDistanceUpdate;
  const DistanceField({super.key, required this.paceDistanceUpdate});

  @override
  State<DistanceField> createState() => DistanceFieldState();
}

class DistanceFieldState extends State<DistanceField> {
  LocationSettings locationOptions = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 4,
  );
  Duration localDurationTracking = const Duration(seconds: 0);
  Duration durationLastSpeech = const Duration(seconds: 0);
  late UnitsProvider unitsProvider =
      Provider.of<UnitsProvider>(context, listen: false);
  late ActivityDataProvider activityData =
      Provider.of<ActivityDataProvider>(context, listen: false);
  late RunnerProvider runnerProvider =
      Provider.of<RunnerProvider>(context, listen: false);
  List<Position?> route = [];

  Position? currentpos;
  double elevation = 0;
  double distance = 0;
  int times = 0;
  bool _isRunning = false;
  bool _enabled = false;
  Timer? _timer;
  //pause and unpause
  void pauseAndUnpause(bool runOrPause) {
    _isRunning = runOrPause;
  }

  //manually singnal the geolocator to track movements
  void onClickChangePace() {
    setState(() {
      bg.BackgroundGeolocation.setOdometer(0.0);
    });

    bg.BackgroundGeolocation.changePace(true)
        .then((bool isMoving) {})
        .catchError((e) {});
  }

  //initallize the gps tracking
  void startGpsTracking() {
    //declare what to do on location changes
    bg.BackgroundGeolocation.onLocation((bg.Location location) {
      if (currentpos != null && _isRunning) {
        //calculate the differance in between old and new postion in meters
        double tempDis = Geolocator.distanceBetween(
            currentpos!.latitude,
            currentpos!.longitude,
            location.coords.latitude,
            location.coords.longitude);
        setState(() {
          //update the distance locally and in parent widget
          double elevDiff = 0;
          if (currentpos!.altitude - location.coords.altitude > 0) {
            elevDiff = currentpos!.altitude - location.coords.altitude;
            elevation += elevDiff;
          }
          distance += tempDis;
          widget.paceDistanceUpdate(distance);
        });

        //text to speech
        if (runnerProvider.textToSpeechOn == true) {
          Duration durationLastKm = Duration(
              seconds: localDurationTracking.inSeconds -
                  durationLastSpeech.inSeconds);
          if (unitsProvider.unit == Unit.metric) {
            int amount = (1000 * (times + 1));
            /*   int high = amount+50;  */
            int repetions = distance ~/ 1000;
            if (distance >= amount && repetions != times) {
              times++;
              speech(activityData, unitsProvider, times, localDurationTracking,
                  durationLastKm);
            }
          } else {
            int amount = (1609 * (times + 1));
            /*   int high = amount+50;  */
            int repetions = distance ~/ 1609;
            if (distance >= amount && repetions != times) {
              times++;
              speech(activityData, unitsProvider, times, localDurationTracking,
                  durationLastKm);
            }
          }
        }
        //update the provider with postion and elevation

        activityData.addPositionalData(currentpos);
        activityData.addElevation(elevation);
      }
      //update the current postion with the new postion
      currentpos = Position(
          longitude: location.coords.longitude,
          latitude: location.coords.latitude,
          timestamp: DateTime.now(),
          accuracy: location.coords.accuracy,
          altitude: location.coords.altitude,
          heading: location.coords.heading,
          speed: location.coords.speed,
          speedAccuracy: location.coords.speedAccuracy);
    });
    _onClickEnable(true);
  }

  //starting the geolocationtracker
  void _onClickEnable(enabled) {
    if (enabled) {
      bg.BackgroundGeolocation.start().then((bg.State state) {
        setState(() {
          bg.BackgroundGeolocation.setOdometer(0.0);
          _enabled = state.enabled;
          _isRunning = state.isMoving = false;
          onClickChangePace();
        });
      });
    } else {
      bg.BackgroundGeolocation.stop().then((bg.State state) {
        setState(() {
          _enabled = state.enabled;
          _isRunning = state.isMoving as bool;
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        if (_isRunning) {
          localDurationTracking =
              Duration(seconds: localDurationTracking.inSeconds + 1);
        }
      });
    });
    startGpsTracking();
  }

  @override
  void dispose() {
    //remove listerners and stop the trackings
    _timer!.cancel();
    bg.BackgroundGeolocation.removeListeners();
    bg.BackgroundGeolocation.stop();
    super.dispose();
  }

  //text to speec function
  void speech(
      ActivityDataProvider activityDataProvider,
      UnitsProvider unitsProvider,
      int distance,
      Duration duration,
      Duration avgPaceLastKm) async {
    TextToSpeech textToSpeech = TextToSpeech();
    String time =
        '${duration.inMinutes.remainder(60)} minutes and ${duration.inSeconds.remainder(60)} seconds';
    duration.inHours != 0
        ? time = '${duration.inHours} hours, $time'
        : time = time;
    String avgPace =
        '${avgPaceLastKm.inMinutes.remainder(60)} minutes and ${avgPaceLastKm.inSeconds.remainder(60)} seconds';
    avgPaceLastKm.inHours != 0
        ? avgPace = '${avgPaceLastKm.inHours} hours, $avgPace'
        : avgPace = avgPace;
    String speach =
        "$distance ${unitsProvider.fulldistanceUnit}${distance != 1 ? "s" : " "} Duration $time, average speed last ${unitsProvider.fulldistanceUnit} of $avgPace ";
    textToSpeech.setLanguage("en-US");
    textToSpeech.setVolume(1.0);
    textToSpeech.setRate(0.8);
    await textToSpeech.speak(speach);
  }

  @override
  Widget build(BuildContext context) {
    //displaying the distance in card with two decimal points
    return cardBox(
        'Distance',
        unitsProvider.unit == Unit.metric
            ? (activityData.distance / 1000).toStringAsFixed(2)
            : (activityData.distance / 1600).toStringAsFixed(2),
        unitsProvider.unit,
        context);
  }
}
