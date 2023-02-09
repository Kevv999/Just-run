import 'dart:ui';
import 'package:project_mobile_app/charts/chart_settings.dart';
import 'package:flutter/material.dart';
import 'package:project_mobile_app/models/units_provider.dart';
import 'package:provider/provider.dart';
import 'activity.dart';
import '/models/activityProvider.dart';
import '/models/runner_provider.dart';
import 'package:project_mobile_app/charts/pace_chart.dart';
import 'package:project_mobile_app/activity_resources/activity_timers.dart';
import '/activity_resources/stats_fields.dart';
import '/models/units_provider.dart';


/* History page 
that lists all past runs */
class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  late RunnerProvider runnerProvider = Provider.of<RunnerProvider>(context);
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            color: Theme.of(context).primaryColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const <Widget>[
                TabBar(
                  labelColor: Colors.white,
                  indicatorSize: TabBarIndicatorSize.label,
                  tabs: [
                    HistoryTab(text: 'Week'),
                    HistoryTab(text: 'Month'),
                    HistoryTab(text: 'All Time'),
                  ],
                ),
              ],
            ),
          ),
        ),
        /* Deppending on which tab that is selected 
        diffrent amount of runs should be displayed */
        body: const TabBarView(
          children: [
            HistoryPage(page: 'week'),
            HistoryPage(page: 'month'),
            HistoryPage(page: 'all time'),
          ],
        ),
      ),
    );
  }
}

class HistoryPage extends StatefulWidget {
  final String page;
  const HistoryPage({
    Key? key,
    required this.page,
  }) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState(page: page);
}

class _HistoryPageState extends State<HistoryPage> {
  late RunnerProvider runnerProvider = Provider.of<RunnerProvider>(context);
  late UnitsProvider unitsProvider = Provider.of<UnitsProvider>(context);
  var flatRightBorder = const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
      side: BorderSide());
  var border = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)), side: BorderSide());
  final String page;
  _HistoryPageState({required this.page});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Theme.of(context).canvasColor,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Expanded(

                  child: ListView.builder(
                    itemCount: runnerProvider.runs.length + 1,
                    itemBuilder: (BuildContext context, int index) {
                      if (index == 0) {
                        return Card(
                            elevation: 10,
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              side: BorderSide(),
                            ),
                            child: AspectRatio(
                              aspectRatio: 2,
                              child: Container(
                                decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.tealAccent, Colors.teal],
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Text('Charts',
                                          style: TextStyle(
                                            fontSize: 30,
                                          )),
                                      Expanded(
                                          child: chartCardRow(
                                              'Distance', 'Calories')),
                                      Expanded(
                                          child: chartCardRow(
                                              'Activity Count', 'Elevation')),
                                      //chart,
                                      //chart,
                                    ],
                                  ),
                                ),
                              ),
                            ));
                      } else {
                        /* For deleting passed runs with a swipe */
                        if (tabSelector(page, runnerProvider, index)) {
                          return Dismissible(

                            key: Key(runnerProvider.runs.toString()),
                            background: Card(
                              color: Colors.red,
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  side: BorderSide()),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: const [
                                  Icon(
                                    Icons.delete,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 20,
                                  )
                                ],
                              ),
                            ),
                            direction: DismissDirection.endToStart,
                            onDismissed: (DismissDirection direction) {
                              setState(() {
                                runnerProvider.delete(runnerProvider
                                    .runs[runnerProvider.runs.length - index]);
                              });
                            },
                            dismissThresholds: const {
                              DismissDirection.endToStart: 0.5,
                            },
                            /* Pop up for comfirmation of deleting a run
                             */
                            confirmDismiss: (DismissDirection direction) async {
                              return await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      backgroundColor:
                                          Color.fromARGB(255, 30, 196, 179),
                                      title: Center(
                                        child: const Text(
                                          'Delete Confirmation',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      content: Container(
                                        width: double.maxFinite,
                                        height: 50,
                                        child: const Text(
                                          'Are you sure you want to delete this activity?',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      actions: <Widget>[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(false),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .canvasColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.all(14),
                                                  child: const Text(
                                                    'Cancel',
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                )),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(true),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .canvasColor,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                padding:
                                                    const EdgeInsets.all(14),
                                                child: const Text('Delete',
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.white,
                                                    )),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  });
                            },
                            child: historyCard(
                                runnerProvider
                                    .runs[runnerProvider.runs.length - index],
                                context,
                                border),
                          );
                        } else {
                          return const SizedBox(
                            width: 0,
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  //Change settings depending of chart type

  Settings loadSettings(String page) {
    switch (page) {
      case 'week':
        return Settings(
            chartType: '',
            xAxis: 7,
            duration: page,
            bottomTitle: 'Weekday',
            leftTitle: 'Distance in ${unitsProvider.disctanceUnit}',
            topTitle: 'Distance this Week',
            toolTipUnit: 'km');
      case 'month':
        return Settings(
            chartType: '',
            xAxis: 12,
            duration: page,
            bottomTitle: 'Month',
            leftTitle: 'Distance in ${unitsProvider.disctanceUnit}',
            topTitle: 'Distance per Month',
            toolTipUnit: 'km');
      case 'all time':
        int count = 1;
        for (int i = 0; i < runnerProvider.runs.length; i++) {
          if (runnerProvider.runs.last != runnerProvider.runs[i]) {
            if (runnerProvider.runs[i].activityStartTime.year !=
                runnerProvider.runs[i + 1].activityStartTime.year) {
              count++;
            }
          }
          debugPrint(count.toString());
        }
        return Settings(
            chartType: '',
            xAxis: count,
            duration: page,
            bottomTitle: 'All Time',
            leftTitle: 'Distance in ${unitsProvider.disctanceUnit}',
            topTitle: 'Total Distance',
            toolTipUnit: 'km');
      default:
        return Settings(
            chartType: '',
            xAxis: 1,
            duration: page,
            bottomTitle: '',
            leftTitle: '',
            topTitle: '',
            toolTipUnit: '');
    }
  }

  //Reusable code

  Row chartCardRow(String title1, String title2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(child: chartCard(title1)),
        Expanded(child: chartCard(title2)),
      ],
    );
  }

//Reusable code

  Hero chartCard(String title) {
    Settings setting = loadSettings(page);
    setting.chartType = title;
    return Hero(
      tag: title,
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, "/fullscreenChart",
            arguments: setting),
        child: Card(
          elevation: 10,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              side: BorderSide()),
          child: Container(
            width: 300,
            height: 100,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Theme.of(context).canvasColor),
            child: Center(
              child: Text(title,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  )),
            ),
          ),
        ),
      ),
    );
  }
}

//Sort the list of activities shown in history tab depending of type.
//Also reverses the list showing newest activities first.

bool tabSelector(String choice, RunnerProvider runnerProvider, int index) {
  switch (choice) {
    case 'week':
      if (runnerProvider.runs.reversed
          .toList()[index - 1]
          .activityStartTime
          .isAfter(DateTime(DateTime.now().year, DateTime.now().month,
              DateTime.now().day - (DateTime.now().weekday - 1)))) {
        return true;
      }
      break;
    case 'month':
      if (runnerProvider.runs.reversed
          .toList()[index - 1]
          .activityStartTime
          .isAfter(DateTime(DateTime.now().year, DateTime.now().month, 1))) {
        return true;
      }
      break;
    case 'all time':
      return true;
  }
  return false;
}

class HistoryTab extends StatelessWidget {
  final String text;
  const HistoryTab({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Align(
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}

/* Displaying the card containing the run */
GestureDetector historyCard(
  ActivityData data,
  BuildContext context,
  RoundedRectangleBorder border,
) {
  ActivityDataProvider activityDataProvider =
      Provider.of<ActivityDataProvider>(context);
  UnitsProvider unitsProvider = Provider.of<UnitsProvider>(context);
  RunnerProvider runnerProvider = Provider.of<RunnerProvider>(context);
  //return a clickable card.
  return GestureDetector(
    onTap: () {
      /* If clicked up on ppusched to another page containgen 
      a more detailed view of the data */
      Navigator.pushNamed(context, "/viewActivity",
          arguments: PausedParameters(
              activityData: data,
              isPaused: false,
              timerKey: null,
              distanceKey: null));
    },
    child: Card(
      elevation: 10,
      shape: border,
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.tealAccent, Colors.teal],
          ),
        ),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  radius: 35,
                  backgroundColor: Theme.of(context).canvasColor,
                  child: Icon(
                    Icons.directions_run,
                    color: Theme.of(context).selectedRowColor,
                    size: 45,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    data.activityStartTime.toString().substring(0, 19),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                      data.activityDuration?.inHours != 0
                          ? "${addZero(data.activityDuration!.inHours.remainder(60))}:${addZero(data.activityDuration!.inMinutes.remainder(60))}:${addZero(data.activityDuration!.inSeconds.remainder(60))}"
                          : "${addZero(data.activityDuration!.inMinutes.remainder(60))}:${addZero(data.activityDuration!.inSeconds.remainder(60))}",
                      style: Theme.of(context)
                          .textTheme
                          .headline1
                          ?.copyWith(fontWeight: FontWeight.w400))
                ],
              ),
              Text(
                  unitsProvider.unit == Unit.metric
                      ? '${(data.distance / 1000).toStringAsFixed(2)} km   '
                      : '${(data.distance / 1600).toStringAsFixed(2)} mi   ',
                  style: Theme.of(context)
                      .textTheme
                      .headline1
                      ?.copyWith(fontSize: 20)),
            ]),
      ),
    ),
  );
}
