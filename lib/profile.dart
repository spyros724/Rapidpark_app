//import 'dart:html';
import 'package:flutter/material.dart';
import 'main.dart';
import 'rankings.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:core';
import 'package:geolocator/geolocator.dart';

class ParkingProfileWidget extends StatefulWidget {
  final List<ParkingSpot> parkingspots;
  const ParkingProfileWidget({Key? key, required this.parkingspots})
      : super(key: key);

  @override
  _ParkingProfileWidgetState createState() => _ParkingProfileWidgetState();
}

class _ParkingProfileWidgetState extends State<ParkingProfileWidget> {
  int _selectedIndex = 0;
  void _onItemTapped(int index) async {
    if (index == 0) {
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ParkingSearchWidget()),
      );
    }
    if (index == 1) {
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ParkingRankingsWidget(parkingspots: widget.parkingspots)),
      );
    }
    if (index == 2) {
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ParkingProfileWidget(parkingspots: widget.parkingspots)),
      );
    }
  }

  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Search',
    ),
    Text(
      'Rankings',
    ),
    Text(
      'History',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    Map<String, int> userPoints = Map<String, int>();

    for (final spot in widget.parkingspots) {
      if (spot.points != null && spot.user == 'me') {
        userPoints['me'] = (userPoints['me'] ?? 0) + spot.points;
      }
    }

    var sortedUserPoints = userPoints.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 55, 54, 54),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        title: Text('Rapidpark'),
      ),
      body: Padding(
          padding: EdgeInsets.only(top: 50),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            color: Colors.black,
            child: ListTile(
              leading: CircleAvatar(
                child: Text('A'),
              ),
              title: Text(
                'Anastasia Grey',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                '${userPoints['me']} points',
                style: TextStyle(color: Colors.white),
              ),
            ),
          )),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color.fromARGB(255, 2, 2, 2),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_border_outlined),
            label: 'Rankings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            label: 'History',
          ),
        ],
        currentIndex: _selectedIndex,
        unselectedItemColor: Colors.white,
        selectedItemColor: Color.fromARGB(255, 177, 57, 216),
        onTap: _onItemTapped,
      ),
    );
  }
}
