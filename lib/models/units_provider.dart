import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:project_mobile_app/models/runner_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

/* The main unitsprovider, thats passed around for 
accesing which unit that is currently choosed */
class UnitsProvider extends ChangeNotifier {
  Unit unit = Unit.metric;
  String heightUnit = "cm";
  String weightUnit = "kg";
  String disctanceUnit = "km";
  String elevationUnit = "m";
  String fulldistanceUnit = "kilometer";
  String avgPaceUnit = "minute per kilometer ";

  double dp(double val, int places) {
    num mod = pow(10.0, places);
    return ((val * mod).round().toDouble() / mod);
  }

  /* Change the unit of choice*/
  void changeUnit(Unit convertToUnit) async {
    if (convertToUnit != unit) {
      if (convertToUnit == Unit.metric) {
        unit = Unit.metric;
        heightUnit = "cm";
        weightUnit = "kg";
        disctanceUnit = "km";
        elevationUnit = "m";
        fulldistanceUnit = "kilometer";
        avgPaceUnit = "minute per kilometer ";
      }

      if (convertToUnit == Unit.imperial) {
        heightUnit = "in";
        weightUnit = "lbs";
        disctanceUnit = "mi";
        elevationUnit = "ft";
        avgPaceUnit = "minute per mile";
        fulldistanceUnit = "mile";
        unit = Unit.imperial;
      }
    }
    /* Change the unit i the file also */
    File file = await RunnerProvider.getFile("unit.json");
    Map<String, dynamic> json = {
      "unit": unit.index,
    };
    notifyListeners();
    file.writeAsStringSync(jsonEncode(json));
  }

  /* Convert the height */
  double convertHeight(double height, Unit convertToUnit) {
    if (convertToUnit == Unit.imperial) {
      return dp(0.3937 * height, 1);
    } else {
      return dp(height / 0.3937, 1);
    }
  }
/* Convert the weight */
  double convertWeight(double weight, Unit convertToUnit) {
    if (convertToUnit == Unit.imperial) {
      return dp(weight * 2.20462262185, 1);
    } else {
      return dp(weight / 2.20462262185, 1);
    }
  }
}

enum Unit {
  metric,
  imperial,
}
