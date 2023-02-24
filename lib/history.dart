//import 'dart:html';
import 'package:flutter/material.dart';
import 'main.dart';
import 'rankings.dart';
import 'profile.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:core';
import 'package:geolocator/geolocator.dart';

List<ParkingSpot> _filteredhistoryParkingSpots = [];

class ParkingHistoryWidget extends StatefulWidget {
  final List<ParkingSpot> parkingspots;
  const ParkingHistoryWidget({Key? key, required this.parkingspots})
      : super(key: key);

  @override
  _ParkingHistoryWidgetState createState() => _ParkingHistoryWidgetState();
}

class _ParkingHistoryWidgetState extends State<ParkingHistoryWidget> {
  int _selectedIndex = 2;

  void _addParkingSpot() {}

  bool _personal = true;

  /*void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }*/

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
  }

  void _gotoprofile() async {
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) =>
              ParkingProfileWidget(parkingspots: widget.parkingspots)),
    );
  }

  _launchNavigation(String address) async {
    String url = 'https://www.google.com/maps/search/?api=1&query=' + address;
    await launch(url);
  }

  void _filterhistoryparkingSpots() {
    setState(() {
      _filteredhistoryParkingSpots = widget.parkingspots
          .where((parkingSpot) =>
              parkingSpot.personal == _personal || parkingSpot.history)
          .toList();

      _filteredhistoryParkingSpots.sort((b, a) => a.date.compareTo(b.date));
    });
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
    _filterhistoryparkingSpots();
    return Scaffold(
      /*
      setState(() {
        setState(() {
          _filterarkingspots();
        });
      }),
      */
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
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(20),
              child: Text("History",
                  style: TextStyle(fontSize: 30, color: Colors.white)),
            ),
            Container(
              width: 325,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 83, 78, 78),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(40),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredhistoryParkingSpots.length,
                itemBuilder: (context, index) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    color: Colors.black,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              "Destination: ${_filteredhistoryParkingSpots[index].destination}",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              "Address: ${_filteredhistoryParkingSpots[index].street}",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              "Points: ${_filteredhistoryParkingSpots[index].points}",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                onPressed: () {
                                  if (_filteredhistoryParkingSpots[index]
                                      .exact) {
                                    _launchNavigation(
                                        _filteredhistoryParkingSpots[index]
                                            .exactLocation!);
                                  } else {
                                    _launchNavigation(
                                        _filteredhistoryParkingSpots[index]
                                            .street);
                                  }
                                },
                                child: Container(
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 177, 57, 216),
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 10),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.navigation_rounded,
                                          color: Colors.black,
                                          size: 20,
                                        ),
                                        Text(
                                          'Navigate',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 13.0),
                                        ),
                                      ],
                                    )),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
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
