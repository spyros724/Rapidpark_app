//import 'dart:html';
import 'package:flutter/material.dart';
import 'main.dart';
import 'history.dart';
import 'profile.dart';
import 'package:path/path.dart' as p;
import 'dart:core';
import 'dart:collection';
import 'package:url_launcher/url_launcher.dart';

class ParkingRankingsWidget extends StatefulWidget {
  final List<ParkingSpot> parkingspots;
  const ParkingRankingsWidget({Key? key, required this.parkingspots})
      : super(key: key);

  @override
  _ParkingRankingsWidgetState createState() => _ParkingRankingsWidgetState();
}

class _ParkingRankingsWidgetState extends State<ParkingRankingsWidget> {
  int _selectedIndex = 1;

/*
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
*/

  void _onItemTapped(int index) async {
    if (index == 0) {
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ParkingSearchWidget()),
      );
    }

    if (index == 2) {
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ParkingHistoryWidget(parkingspots: widget.parkingspots)),
      );
    }
  }

  void _gotoprofile() async {
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) =>
              ParkingProfileWidget(parkingspots: widget.parkingspots)),
    );
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
    // Create a map of user to total points
    Map<String, int> userPoints = Map<String, int>();

    for (final spot in widget.parkingspots) {
      if (spot.points != null) {
        userPoints[spot.user] = (userPoints[spot.user] ?? 0) + spot.points;
      }
    }

    var sortedUserPoints = userPoints.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // sort the map by descending order of points
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 55, 54, 54),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        leading: IconButton(
            onPressed: () {
              launch('https://open.spotify.com/');
            },
            icon: Icon(Icons.library_music_outlined)),
        title: Text('Rapidpark'),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 50),
        child: ListView.builder(
          itemCount: sortedUserPoints.length,
          itemBuilder: (context, index) {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              color: Colors.black,
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(sortedUserPoints[index].key[0]),
                ),
                title: Text(
                  sortedUserPoints[index].key,
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  '${sortedUserPoints[index].value} points',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
          },
        ),
      ),
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
