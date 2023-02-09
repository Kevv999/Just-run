import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:project_mobile_app/charts/fullScreen.dart';
import 'package:project_mobile_app/pages/history_paused.dart';
import 'package:project_mobile_app/pages/hometest.dart';

import 'package:project_mobile_app/models/runner_provider.dart';
import 'package:project_mobile_app/models/units_provider.dart';
import 'package:project_mobile_app/pages/newsetting.dart';
import 'package:project_mobile_app/page_resources/runnerInfo.dart';

import 'pages/activity.dart';
import 'pages/history.dart';
import 'models/activityProvider.dart';
import 'package:project_mobile_app/page_resources/bottomNav.dart';
import 'package:provider/provider.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<RunnerProvider>(
            create: (context) => RunnerProvider()),
        ChangeNotifierProvider<UnitsProvider>(
            create: ((context) => UnitsProvider())),
        ChangeNotifierProvider<ActivityDataProvider>(
            create: ((context) => ActivityDataProvider())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.teal,
            ),
            tabBarTheme: TabBarTheme(
              unselectedLabelColor: Colors.black,
              indicator: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
            ),
            scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
            navigationBarTheme:
                const NavigationBarThemeData(indicatorColor: Colors.teal),
            primarySwatch: Colors.teal,
            dividerColor: Colors.grey[600],
            highlightColor: Colors.white,
            canvasColor: Colors.grey[900], //background
            toggleButtonsTheme: const ToggleButtonsThemeData(
              fillColor: Colors.teal,
              selectedBorderColor: Color.fromARGB(255, 8, 104, 94),
              selectedColor: Colors.white,
            ),
            cardTheme: CardTheme(

                //color: [Colors.blue, Colors.purple],
                //color: Colors.white.withOpacity(.6451),
                ),
            textTheme: const TextTheme(
              headline1: TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
              headline2: TextStyle(
                  fontSize: 15,
                  color: Colors.teal,
                  fontWeight: FontWeight.w400,
                  shadows: <Shadow>[
                    Shadow(
                      color: Color.fromARGB(255, 0, 0, 0),
                      blurRadius: 4,
                      offset: Offset(1, 1),
                    )
                  ]),
              headline3: TextStyle(
                fontSize: 40,
                color: Colors.black,
              ),
              headlineLarge: TextStyle(
                  fontSize: 95,
                  color: Colors.black,
                  fontWeight: FontWeight.w400),
              headline4: TextStyle(
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              headline5: TextStyle(
                  fontSize: 20,
                  color: Colors.teal,
                  fontWeight: FontWeight.w400,
                  shadows: <Shadow>[
                    Shadow(
                      color: Color.fromARGB(255, 0, 0, 0),
                      blurRadius: 4,
                      offset: Offset(1, 1),
                    ),
                  ]),
            )),
        initialRoute: "/runnersInfo",
        routes: {
          "/": (context) => const MyHomePage(title: "Main Page"),
          "/runnersInfo": (context) => const InitialLoad(),
          '/history': (context) => const History(),
          '/activity': (context) => const Activity(),
          '/viewActivity': (context) => const ExtendHistory(),
          '/fullscreenChart': (context) => const Fullscreen(),
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  final List<Widget> _pages = [
    const TestHomeScreen2(),
    const History(),
    Setting(),
  ];
  int _selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    bg.BackgroundGeolocation.ready(bg.Config(
            backgroundPermissionRationale: bg.PermissionRationale(
                title:
                    'Allow access to this device\'s location in the background',
                message:
                    'In order to track your activity in the background, please enable "Allow all the time" location permission. Activty tracking will not work as intended without it.',
                positiveAction: 'Change to Allow all the time',
                negativeAction: 'Deny(Tracking will not work)'),
            desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
            distanceFilter: 5.0,
            speedJumpFilter: 100,
            stopOnTerminate: true,
            startOnBoot: false,
            debug: false,
            logLevel: bg.Config.LOG_LEVEL_OFF,
            reset: true,
            disableElasticity: true,
            foregroundService: true,
            notification: bg.Notification(
                title: 'JUST RUN IT', text: 'Tracking your run!')))
        .then((bg.State state) {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    if (MediaQuery.of(context).orientation != Orientation.portrait) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: bottomNav(
            onClick: _onItemTapped) 
        );
  }
}
