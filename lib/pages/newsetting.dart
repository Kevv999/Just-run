import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:project_mobile_app/models/units_provider.dart';

import 'package:provider/provider.dart';
import '/models/activityProvider.dart';
import '/models/runner_provider.dart';

enum Genders { Male, Female, Other }

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}


/* Settings page */
class _SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    RunnerProvider runnerProvider = Provider.of<RunnerProvider>(context);
    ActivityDataProvider activityDataProvider =
        Provider.of<ActivityDataProvider>(context);

    UnitsProvider unitsProvider = Provider.of<UnitsProvider>(context);
    var integer = 0;
    var decimal = 0;
    List<Map<String, dynamic>> settingList = [
      {
        'Title': "Age",
        'Data': "${runnerProvider.age}",
      },
      {
        'Title': "Gender",
        'Data': runnerProvider.gender == Genders.Male
            ? "Male"
            : runnerProvider.gender == Genders.Female
                ? "Female"
                : "Other",
      },
      {
        'Title': "Weight",
        'Data': "${runnerProvider.weight} ${unitsProvider.weightUnit}"
      },
      {
        'Title': "Height",
        'Data': "${runnerProvider.height} ${unitsProvider.heightUnit}"
      },
      {
        'Title': "Unit",
        'Data': unitsProvider.unit == Unit.metric ? "Metric" : "Imperial"
      },
      {
        'Title': "Audio Notification",
        'Data': runnerProvider.textToSpeechOn == true ? "On" : "Off"
      },
    ];
    /* Returns container filled with boxes for changing the 
    users information */
    return Container(
      color: Theme.of(context).canvasColor,
      /* Building a liost with all the data 
      from the settings list, keeping the displaying of data similiar. */
      child: ListView.builder(
        itemCount: settingList.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
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
              height: 82,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(settingList[index]["Title"],
                        style: Theme.of(context).textTheme.headline1),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GestureDetector(
                      /* Deppending on wchich index on diffrent accetions is taken 
                      when the bar is clicked up on  */
                        onTap: () async {
                          switch (settingList[index]["Title"]) {
                            case "Age":
                              DateTime? newDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1945),
                                  lastDate: DateTime.now());
                              if (newDate == null) return;
                              setState(() {
                                runnerProvider.age = Yeardiffence(newDate);
                                runnerProvider.changeRunnerInfo(unitsProvider);
                              });
                              break;
                            case "Gender":
                              genderDialog(context);
                              break;
                            case "Weight":
                              showMyDialog(
                                  context, settingList[index]['Title']);

                              break;
                            case "Height":
                              showMyDialog(
                                  context, settingList[index]['Title']);

                              break;
                            case "Unit":
                              unitsProvider.unit == Unit.imperial
                                  ? unitsProvider.changeUnit(Unit.metric)
                                  : unitsProvider.changeUnit(Unit.imperial);
                              runnerProvider.height =
                                  unitsProvider.convertHeight(
                                      runnerProvider.height,
                                      unitsProvider.unit);
                              runnerProvider.weight =
                                  unitsProvider.convertWeight(
                                      runnerProvider.weight,
                                      unitsProvider.unit);

                              break;
                            case "Audio Notification":
                              runnerProvider.textToSpeechOn == true
                                  ? runnerProvider.textToSpeechOn = false
                                  : runnerProvider.textToSpeechOn = true;
                              runnerProvider.changeRunnerInfo(unitsProvider);

                              break;
                            default:
                              break;
                          }
                        },
                        child: Container(
                            width: 100,
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(12)),
                              color: Theme.of(context).canvasColor,
                            ),
                            child: Center(
                              child: Text(
                                settingList[index]["Data"],
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                            ))),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/* Returns diffrence from the selected year */
int Yeardiffence(DateTime birth) {
  var difference = DateTime.now().difference(birth).inDays;

  var age = difference / 365;
  return age.toInt();
}

Widget test(DateTime birth) {
  return Container(
    height: 20,
  );
}


/* Pop up dialog containing the cupertion picker for changing weight and height*/
Future<void> showMyDialog(BuildContext context, String text) async {
  UnitsProvider unitsProvider =
      Provider.of<UnitsProvider>(context, listen: false);
  RunnerProvider runnerProvider =
      Provider.of<RunnerProvider>(context, listen: false);
  int integer;
  int decimal = 0;

  text == "Height"
      ? integer = runnerProvider.height.toInt()
      : integer = runnerProvider.weight.toInt();

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: const Color.fromARGB(255, 30, 196, 179),
      title: Text("Enter $text"),
      content: Container(
        width: double.maxFinite,
        height: 100,
        child: Expanded(
          child: Row(
            children: [
              Expanded(
                  flex: 1,
                  child: CupertinoPicker(
                      useMagnifier: true,
                      magnification: 1.5,
                      onSelectedItemChanged: (value) {
                        integer = value;
                      },
                      itemExtent: 25,
                      scrollController:
                          FixedExtentScrollController(initialItem: integer),
                      children: List<Widget>.generate(
                          unitsProvider.unit == Unit.imperial
                              ? text == "Height"
                                  ? 99
                                  : 550
                              : 250, (int index) {
                        return Text('$index');
                      }))),
              const Text(
                ',',
                style: TextStyle(fontSize: 30),
              ),
              Expanded(
                  flex: 1,
                  child: CupertinoPicker(
                      looping: true,
                      onSelectedItemChanged: (value) {
                        decimal = value;
                      },
                      useMagnifier: true,
                      magnification: 1.5,
                      itemExtent: 25,
                      scrollController:
                          FixedExtentScrollController(initialItem: decimal),
                      children: List<Widget>.generate(10, (int index) {
                        return Text('$index');
                      }))),
              Text("$text" == "Weight"
                  ? "${unitsProvider.weightUnit}"
                  : "${unitsProvider.heightUnit}")
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            if ("$text" == "Weight") {
              runnerProvider.weight = integer + 0.1 * decimal;
            } else {
              runnerProvider.height = integer + 0.1 * decimal;
            }
            /* Uppdatated the runner info */
            runnerProvider.changeRunnerInfo(unitsProvider);

            Navigator.of(ctx).pop();
          },
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).canvasColor,
              ),
              height: 50,
              width: 100,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8),
              child: Text('OK',
                  style: Theme.of(context)
                      .textTheme
                      .headline4!
                      .copyWith(fontSize: 20)),
            ),
          ),
        ),
      ],
    ),
  );
}


/* Pop up for changing the gender */
Future<void> genderDialog(BuildContext context) async {
  UnitsProvider unitsProvider =
      Provider.of<UnitsProvider>(context, listen: false);
  RunnerProvider runnerProvider =
      Provider.of<RunnerProvider>(context, listen: false);
  List<Map<String, dynamic>> genderList = [
    {'Title': "Male", 'Data': Genders.Male},
    {'Title': "Female", 'Data': Genders.Female},
    {'Title': "Other", 'Data': Genders.Other}
  ];
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: const Color.fromARGB(255, 30, 196, 179),
        title: const Text('Choose Gender'),
        children: <Widget>[
          Container(
            height: 200,
            width: 100,
            child: ListView.builder(
              itemCount: genderList.length,
              itemBuilder: (BuildContext context, int index) {
                return SimpleDialogOption(
                  onPressed: () {
                    /* Updating the info of the runner */
                    runnerProvider.gender = genderList[index]['Data'];
                    runnerProvider.changeRunnerInfo(unitsProvider);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).canvasColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      height: 50,
                      width: 200,
                      child: Center(
                          child: Text(genderList[index]['Title'],
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 20)))),
                );
              },
            ),
          ),
        ],
      );
    },
  );
}
