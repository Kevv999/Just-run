import 'package:flip_card/flip_card.dart';

import 'package:flutter/material.dart';

import 'package:project_mobile_app/page_resources/custom_icons_icons.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:project_mobile_app/models/activityProvider.dart';
import 'package:project_mobile_app/models/runner_provider.dart';
import 'package:project_mobile_app/models/units_provider.dart';
import 'package:project_mobile_app/page_resources/history_paused_resources.dart';
import 'package:project_mobile_app/pages/newsetting.dart';
import 'package:provider/provider.dart';
import 'package:project_mobile_app/activity_resources/activity_timers.dart';



/* Home widget */
class TestHomeScreen2 extends StatefulWidget {
  const TestHomeScreen2({super.key});

  @override
  State<TestHomeScreen2> createState() => _TestHomeScreen2State();
}

class _TestHomeScreen2State extends State<TestHomeScreen2> {
  bool card1 = true;
  List<int> flippedCards = [];
  @override
  Widget build(BuildContext context) {
    RunnerProvider runnerProvider = Provider.of<RunnerProvider>(context);
    ActivityDataProvider activityDataProvider =
        Provider.of<ActivityDataProvider>(context);

    UnitsProvider unitsProvider = Provider.of<UnitsProvider>(context);
    Duration avgDur;
    unitsProvider.unit == Unit.metric
        ? avgDur = Duration(
            seconds: avgPaceInSeconds(runnerProvider.totalDistance / 1000,
                runnerProvider.totalDuration.inSeconds))
        : avgDur = Duration(
            seconds: avgPaceInSeconds(runnerProvider.totalDistance / 1600,
                runnerProvider.totalDuration.inSeconds));

                /* All cards that
                later will be displayed in the widget, some
                of them ar flippeble */
    var cardData = [
      CardData(
        isFlipable: false,
        frontTitle: 'Runs',
        frontText: "${runnerProvider.runs.length}",
        frontIcon: Icon(Icons.directions_run,
            size: 25, color: Theme.of(context).highlightColor),
      ),
      CardData(
        isFlipable: false,
        frontTitle: 'Avg. Pace',
        frontText: avgDur.inSeconds == 0
            ? "00:00"
            : "${addZero(avgDur.inMinutes.remainder(60))}:${addZero(avgDur.inSeconds.remainder(60))}",
        frontIcon: Icon(Icons.speed,
            size: 25, color: Theme.of(context).highlightColor),
      ),
      CardData(
        isFlipable: true,
        frontTitle: 'Calories',
        frontText: runnerProvider.gender == Genders.Male
            ? (runnerProvider.totalCalories).toStringAsFixed(0)
            : runnerProvider.gender == Genders.Female
                ? ((runnerProvider.totalCalories * 0.92)).toStringAsFixed(0)
                : (((runnerProvider.totalCalories +
                            runnerProvider.totalCalories * 0.92) /
                        2))
                    .toStringAsFixed(0),
        frontIcon: Icon(CustomIcons.flame_icon,
            size: 25, color: Theme.of(context).highlightColor),
        backTitle: 'Bag of chips',
        backText: runnerProvider.gender == Genders.Male
            ? (runnerProvider.totalCalories / 1500).toStringAsFixed(1)
            : runnerProvider.gender == Genders.Female
                ? ((runnerProvider.totalCalories * 0.92) / 1500)
                    .toStringAsFixed(1)
                : (((runnerProvider.totalCalories +
                                runnerProvider.totalCalories * 0.92) /
                            2) /
                        1500)
                    .toStringAsFixed(1),
        backIcon: Icon(CustomIcons.chips_bag__1_,
            size: 25, color: Theme.of(context).highlightColor),
      ),
      CardData(
        isFlipable: true,
        frontTitle: 'Distance',
        frontText: unitsProvider.unit == Unit.metric
            ? ((runnerProvider.totalDistance / 1000)).toStringAsFixed(1)
            : ((runnerProvider.totalDistance / 1600)).toStringAsFixed(1),
        frontIcon: Icon(CustomIcons.distance,
            size: 25, color: Theme.of(context).highlightColor),
        backTitle: 'Soccer fields',
        backText: (runnerProvider.totalDistance / 120).toStringAsFixed(1),
        backIcon: Icon(CustomIcons.soccer_field,
            size: 25, color: Theme.of(context).highlightColor),
      ),
    ];

    return Container(
        color: Theme.of(context).canvasColor,
        child: Column(
          children: [
            const SizedBox(
              height: 70,
            ),
            startButton(context, activityDataProvider),
            Expanded(
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    itemCount: cardData.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    /* here all cards are displayed and tested if they are flippeble or 
                    not. Widget can easily extend with more cards if needed */
                    itemBuilder: (context, index) {
                      var card = cardData[index];
                      if (card.isFlipable) {
                        return FlipCard(
                          front: CardContent(
                            title: card.frontTitle,
                            text: card.frontText,
                            icon: card.frontIcon,
                            flip: true,
                          ),
                          back: CardContent(
                            title: card.backTitle,
                            text: card.backText,
                            icon: card.backIcon,
                            flip: true,
                          ),
                        );
                      } else {
                        return CardContent(
                          title: card.frontTitle,
                          text: card.frontText,
                          icon: card.frontIcon,
                          flip: false,
                        );
                      }
                    },
                  )),
            ),
          ],
        ));
  }
}

/* Count the avrage pace in seconds */
int avgPaceInSeconds(double distance, int timeInSeconds) {
  if (timeInSeconds != 0 && distance != 0.0) {
    return timeInSeconds ~/ distance;
  }
  return 0;
}

/* Start button thats when clicked redirect you to activity page where 
the run begins after count down*/
ElevatedButton startButton(
    BuildContext context, ActivityDataProvider activityDataProvider) {
  return ElevatedButton(
    onPressed: () {
      /* Checks if the correct permissions are given for the app */
      bg.BackgroundGeolocation.requestPermission().then((value) {
        activityDataProvider.clearRoute();
        Navigator.pushNamed(context, '/activity');
      }).catchError((error) {
        /* Prompts for accecs to the location 
        otherwise may the app not work as intended */
        locationAccessDeiniedPopUp(context);
      });
    },
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [startButtText('Start'), startButtText('Activity')],
    ),
    style: ElevatedButton.styleFrom(
        foregroundColor: Theme.of(context).canvasColor,
        //shadowColor: Colors.tealAccent,
        elevation: 5,
        backgroundColor: Colors.tealAccent,
        shape: CircleBorder(),
        padding: EdgeInsets.all(24),
        minimumSize: Size(200, 200)),
  );
}

/* Prompt for location access on the app */
Future<dynamic> locationAccessDeiniedPopUp(BuildContext context) {
  return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Color.fromARGB(255, 30, 196, 179),
            title: const Center(
                child: Text(
              "Location Access denied",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            )),
            content: Container(
              width: double.maxFinite,
              height: 50,
              child: const Expanded(
                  child: Text(
                      'Please enable location access in the app settings',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600))),
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
                      child: const Text('OK',
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

Text startButtText(String text) {
  return Text(
    text,
    style: const TextStyle(
      fontSize: 40,
    ),
  );
}

class CardData {
  late bool isFlipable;
  late String frontTitle;
  late String frontText;
  late Icon frontIcon;
  late String? backTitle;
  late String? backText;
  late Icon? backIcon;

  CardData({
    required this.isFlipable,
    required this.frontTitle,
    required this.frontText,
    required this.frontIcon,
    this.backTitle,
    this.backText,
    this.backIcon,
  });
}

/* This is how the cars a built. */
class CardContent extends StatelessWidget {
  late String? title;
  late String? text;
  late Icon? icon;
  late bool flip;

  CardContent(
      {required this.title,
      required this.text,
      required this.icon,
      required this.flip});

  @override
  Widget build(BuildContext context) {
    UnitsProvider unitsProvider = Provider.of<UnitsProvider>(context);
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.tealAccent, Colors.teal],
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(12),
          )),
      child: Stack(
        children: [
          Center(
              child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                    text: text,
                    style: const TextStyle(color: Colors.black, fontSize: 40)),
                TextSpan(
                  text: title == "Distance" || title == "Avg. Pace"
                      ? title == "Avg. Pace"
                          ? "min/${unitsProvider.disctanceUnit}"
                          : unitsProvider.disctanceUnit
                      : "",
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
          )),
          Column(
            children: [
              Stack(
                children: [
                  flip
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: const Icon(Icons.autorenew_rounded),
                        )
                      : const Text(""),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                            backgroundColor: Theme.of(context).canvasColor,
                            child: icon),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 50,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(title ?? '',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
