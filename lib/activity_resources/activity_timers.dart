import 'dart:async';
import 'package:project_mobile_app/models/units_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:text_to_speech/text_to_speech.dart';
import 'stats_fields.dart';

/////////////COUNTDOWN OVERLAY BEFORE ACTIVITY START//////////////////////////////////////
class CountdownOverlay extends StatefulWidget {
  //function from activity page to stop displaying overlay once timer expires
  final Function stopDisplayingOverlay;
  final bool speech;
  const CountdownOverlay(
      {super.key, required this.stopDisplayingOverlay, required this.speech});

  @override
  State<CountdownOverlay> createState() => _CountdownOverlayState();
}

class _CountdownOverlayState extends State<CountdownOverlay> {
  int timer = 5;
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    //creating a timer that counts down starting at 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        timer--;
        if (widget.speech && timer >= 0 && timer < 6) {
          TextToSpeech textToSpeech = TextToSpeech();
          textToSpeech.setVolume(1.0);
          textToSpeech.setRate(0.8);
          if (timer == 0) {
            textToSpeech.speak("GO!");
          } else {
            textToSpeech.speak(timer.toString());
          }
        }
        if (timer < 0) {
          _timer!.cancel();
          widget.stopDisplayingOverlay();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    //returning an overlay that countsdown, with a button to add more time to the timer
    return SafeArea(
      child: Positioned.fill(
        child: Container(
          color: const Color.fromARGB(249, 0, 150, 135),
          child: Center(
              child: timer > 0
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Starting in',
                            style: TextStyle(fontSize: 50)),
                        Text(
                          '$timer',
                          style: const TextStyle(fontSize: 150),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(
                              150,
                              50,
                            ),
                            side: const BorderSide(
                              color: Colors.black,
                              width: 2,
                            ),
                            backgroundColor: Colors.teal,
                          ),
                          onPressed: (() => setState(() {
                                timer += 3;
                              })),
                          icon: const Icon(
                            size: 45,
                            Icons.add,
                            color: Colors.black,
                          ),
                          label: const Text('3 SEC',
                              style:
                                  TextStyle(fontSize: 35, color: Colors.black)),
                        )
                      ],
                    )
                  : const Text(
                      'GO',
                      style: TextStyle(fontSize: 100),
                    )),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////STOPWATCH FOR THE ACTIVITY////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
class StopwatchTimer extends StatefulWidget {
  //function to update the pace and duration.
  final Function paceAvgUpdateDuration;
  const StopwatchTimer({super.key, required this.paceAvgUpdateDuration});

  @override
  State<StopwatchTimer> createState() => StopwatchTimerState();
}

//adding 0 to single digits to display timer as 02:05 instead of 2:5
String addZero(int i) {
  return i.toString().padLeft(2, '0');
}

class StopwatchTimerState extends State<StopwatchTimer>
    with WidgetsBindingObserver {
  Duration duration = const Duration();
  Timer? timer;
  bool isRunning = true;
  DateTime pauseDate = DateTime.now();
  Duration pauseTimer = const Duration();
  late UnitsProvider unitsProvider = Provider.of<UnitsProvider>(context);

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  //counts the differance in seconds from when the app is paused till it's resumed(locked screen -> unlocked)
  int getSeconds(DateTime pauseTime) {
    DateTime now = DateTime.now();
    return ((now.millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond) -
            (pauseDate.millisecondsSinceEpoch ~/
                Duration.millisecondsPerSecond))
        .toInt();
  }

  @override
  //check if app is paused or active
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    setState(() {
      //save the current time and timer duration when the app is paused
      if (state == AppLifecycleState.paused) {
        pauseDate = DateTime.now();
        pauseTimer = duration;
      } else if (state == AppLifecycleState.resumed) {
        //check how long the app was paused and add it to timer duration of when the app paused,
        //update the timer with new value
        int tempSeconds = getSeconds(pauseDate);
        duration = Duration(seconds: pauseTimer.inSeconds + tempSeconds);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  //pause function
  void pause() {
    if (isRunning) {
      setState(() {
        timer?.cancel();
        !isRunning;
      });
    } else {
      setState(() {
        startTimer();
        !isRunning;
      });
    }
  }

  //called every second when timer is running
  void updateTime() {
    setState(() {
      duration = Duration(seconds: duration.inSeconds + 1);

      widget.paceAvgUpdateDuration(duration);
    });
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), ((_) => updateTime()));
  }

  @override
  Widget build(BuildContext context) {
    //return a card with the timer
    return cardBox(
        'Time',
        duration.inHours !=
                0 // check if to display 01:10:01 or 10:01 depending on duration
            ? "${addZero(duration.inHours.remainder(60))}:${addZero(duration.inMinutes.remainder(60))}:${addZero(duration.inSeconds.remainder(60))}"
            : "${addZero(duration.inMinutes.remainder(60))}:${addZero(duration.inSeconds.remainder(60))}",
        unitsProvider.unit,
        context);
  }
}
