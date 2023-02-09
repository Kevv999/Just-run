import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:project_mobile_app/models/runner_provider.dart';
import 'package:project_mobile_app/pages/newsetting.dart';
import 'dart:io';
import 'package:project_mobile_app/charts/pace_chart.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';

import '../models/units_provider.dart';

class InitialLoad extends StatefulWidget {
  const InitialLoad({super.key});

  @override
  State<InitialLoad> createState() => _InitialLoadState();
}

class _InitialLoadState extends State<InitialLoad> {
  int init = 0;
  @override
  void initiState() {
    super.initState();
  }

  /* Main initial function that reads data from three diffrent json files,
  on containing all the runs, on information about which unit is the 
  chosen one and one with information about height, weight etc */
  Future<bool> initial() async {
    if (init == 0) {
      init++; 
      RunnerProvider runnerProvider = Provider.of<RunnerProvider>(context);
      UnitsProvider unitsProvider = Provider.of<UnitsProvider>(context);
      File file = await RunnerProvider.getFile("runs.json");
      String temp = await file.readAsString();
      if (temp.isNotEmpty == true) {
        List<dynamic> json = await jsonDecode(temp);

        for (var data in json) {
          List<LatLng> latLng = [];
          List<ShowPoint> paces = [];
          for (var coordinates in data["route"]) {
            latLng.add(LatLng(
                coordinates["coordinates"][1], coordinates["coordinates"][0]));
          }
          for (var pace in data["paces"]) {
            paces.add(ShowPoint(
                pace: Duration(seconds: pace["pace"]),
                time: Duration(seconds: pace["time"])));
          }
          ActivityData activityData = ActivityData(
            activityDuration: Duration(seconds: data["duration"]),
            calories: data["calories"],
            id: data["id"],
            avgPace: Duration(seconds: data["avgPace"]),
            activityStartTime: DateTime.parse(data["startTime"]),
            route: latLng,
            paces: paces,
            distance: data["distance"],
            speed: Duration(seconds:data["speed"]),
            elevation: data["elevation"],
          ); 
          if(!runnerProvider.runs.contains(activityData))
          {
            await runnerProvider.initAdd(activityData);
          }
        }
      }
      file = await RunnerProvider.getFile("unit.json");
      String tempUnit = file.readAsStringSync();
      if (tempUnit.isNotEmpty == true) {
        var js = jsonDecode(tempUnit);
        if (js["unit"] == 0) {
          unitsProvider.changeUnit(Unit.metric);
        } else {
          unitsProvider.changeUnit(Unit.imperial);
        }
      }
      file = await RunnerProvider.getFile("runnerInfo.json");
      String tempInfo = file.readAsStringSync();
      if (tempInfo.isNotEmpty == true) {
        var json = jsonDecode(tempInfo);
        runnerProvider.age = json["age"];
        if (json["gender"] == 0) {
          runnerProvider.gender = Genders.Male;
        } else if (json["gender"] == 1) {
          runnerProvider.gender = Genders.Female;
        } else {
          runnerProvider.gender = Genders.Other;
        }
        if (unitsProvider.unit == Unit.metric) {
          runnerProvider.height = json["height"];
          runnerProvider.weight = json["weight"];
        } else {
          runnerProvider.height =
              unitsProvider.convertHeight(json["height"], Unit.imperial);
          runnerProvider.weight =
              unitsProvider.convertWeight(json["weight"], Unit.imperial);
        }
        runnerProvider.textToSpeechOn = json["speech"];
        runnerProvider.notifyListeners();
      }
    }
    return true;
  }
/* Future buiilder showing an loading screen while all the runs and data gets initialized */
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: initial(),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
              Navigator.of(context).popAndPushNamed("/");
            });
            return Scaffold(
                body:Stack(
                  children: const [
                    Positioned.fill(
                      child: Image(
                        image: AssetImage('images/backgroundRunner.jpg'),
                        fit: BoxFit.cover,
                        alignment: Alignment.bottomCenter,
                      ),
                    ),
                    Center(
                      child:Text(
                        "JUST RUN IT", style: TextStyle(
                          fontSize: 50,
                          color: Colors.teal, 
                          fontWeight: FontWeight.w900
                        )
                      )
                    )            
                  ]
              )
            )
            ;
          } else {
            return Scaffold(
                body: Stack(
                  children: const [
                    Positioned.fill(
                       child: Image(
                         image: AssetImage('images/backgroundRunner.jpg'),
                         fit: BoxFit.cover,
                         alignment: Alignment.bottomCenter,
                       ),
                    ),                 
                    Center(
                      child: CircularProgressIndicator(),
                      ),
                  ]
                )
              );
          }
        }));
  }
}
