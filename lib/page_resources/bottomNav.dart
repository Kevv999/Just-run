import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';


/* Bottom navigation bar */
class bottomNav2 extends StatefulWidget {
  final Function onClick;
  const bottomNav2({super.key, required this.onClick});

  @override
  State<bottomNav2> createState() => _bottomNav2State();
}

class _bottomNav2State extends State<bottomNav2> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        indicatorColor:
            const Color.fromARGB(255, 248, 248, 248).withOpacity(.5),
        height: 60,
        labelTextStyle: const MaterialStatePropertyAll(
            TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      ),
      child: NavigationBar(
        backgroundColor: Colors.teal,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: [
          const NavigationDestination(
            icon: Icon(
              Icons.home,
              size: 40,
            ),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.history, size: 40),
            label: 'Activity History',
          ),
          const NavigationDestination(
            icon: Icon(
              Icons.settings,
              size: 40,
            ),
            label: 'Settings',
          ),
        ],
        selectedIndex: _selectedIndex,
        onDestinationSelected: (value) =>
            {setState(() => _selectedIndex = value), widget.onClick(value)},
      ),
    );
  }
}

class bottomNav extends StatefulWidget {
  final Function onClick;
  const bottomNav({super.key, required this.onClick});

  @override
  State<bottomNav> createState() => _bottomNavState();
}

class _bottomNavState extends State<bottomNav> {
  int currentPage = 0;
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    String? route = ModalRoute.of(context)?.settings.name;
    if (route == "/") {
      currentPage = 0;
    } else if (route == "/history") {
      currentPage = 1;
    } else {
      currentPage = 2;
    }

    return Container(
      color: Theme.of(context).primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: GNav(
            gap: 8,
            backgroundColor: Colors.teal,
            activeColor: Colors.white,
            tabBackgroundColor: Theme.of(context).canvasColor,
            padding: const EdgeInsets.all(8),
            tabs: [
              const GButton(
                icon: Icons.home,
                text: 'Home',
                iconSize: 35,
              ),
              const GButton(icon: Icons.history, text: 'History', iconSize: 35),
              const GButton(
                  icon: Icons.settings, text: 'Settings', iconSize: 35),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: (index) => {
                  setState(() => _selectedIndex = index),
                  widget.onClick(index)
                }),
      ),
    );
   
  }
}
