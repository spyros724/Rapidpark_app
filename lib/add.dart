//import 'dart:html';
import 'package:flutter/material.dart';
import 'history.dart';
import 'main.dart';
import 'profile.dart';
import 'rankings.dart';
import 'package:path/path.dart' as p;
import 'dart:core';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

class AddWidget extends StatefulWidget {
  final List<ParkingSpot> parkingspots;
  const AddWidget({Key? key, required this.parkingspots}) : super(key: key);

  @override
  _AddWidgetState createState() => _AddWidgetState();
}

bool _disabled = false;
bool position = true;
String _displayText = 'Inserts your current location to history';

class _AddWidgetState extends State<AddWidget> {
  AudioPlayer player = AudioPlayer();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<String> getCurrentLocation() async {
    // Check if the app has location permission
    PermissionStatus status = await Permission.location.status;
    if (status != PermissionStatus.granted) {
      // If the app does not have location permission, request it from the user
      status = await Permission.location.request();
      if (status != PermissionStatus.granted) {
        // If the user denies the permission request, return an error message
        return "Error getting location: User denied permission";
      }
    }

    // If the app has location permission, retrieve the current location
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      String latitude = position.latitude.toString();
      String longitude = position.longitude.toString();
      return "$latitude, $longitude";
    } catch (e) {
      return "Error getting location: $e";
    }
  }

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
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 55, 54, 54),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        title: Text('Rapidpark'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.accessible_forward,
                    color: Colors.black,
                    size: 30,
                  ),
                  Switch(
                    // thumb color (round icon)
                    activeColor: Color.fromARGB(255, 177, 57, 216),
                    activeTrackColor: Colors.black,
                    inactiveThumbColor: Colors.black,
                    inactiveTrackColor: Colors.grey,
                    splashRadius: 50.0,
                    value: _disabled,
                    onChanged: (value1) => setState(() {
                      setState(() {
                        _disabled = value1;
                      });
                    }),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(Icons.location_pin),
                  Switch(
                    activeColor: Color.fromARGB(255, 177, 57, 216),
                    activeTrackColor: Colors.black,
                    inactiveThumbColor: Colors.black,
                    inactiveTrackColor: Colors.grey,
                    splashRadius: 50.0,
                    value: position,
                    onChanged: (bool value) {
                      setState(() {
                        position = value;
                        _displayText = value
                            ? 'Inserts your current location to history'
                            : 'Exact location will not be stored to history';
                      });
                    },
                  ),
                  Text(_displayText),
                ],
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: const InputDecoration(
                      hintText: 'Destination',
                      border: OutlineInputBorder(borderSide: BorderSide())),
                  controller: _titleController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Destination cannot be empty!';
                    }
                    return null;
                  },
                )),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: const InputDecoration(
                      hintText: 'The street you parked',
                      border: OutlineInputBorder(borderSide: BorderSide())),
                  controller: _descriptionController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Street cannot be empty!';
                    }
                    return null;
                  },
                )),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    /// Κουμπί [ElevatedButton] ακύρωσης. Επειδή σε αυτή την
                    /// οθόνη (ViewEditTask) έχουμε έρθει μέσω Navigator.push()
                    /// από την TaskListScreen, θα επιστέψουμε με Navigator.pop()
                    /// για να μην υπερχειλίσουμε τη στοίβα.
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.black),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                                color: Color.fromARGB(255, 177, 57, 216)),
                          )),
                    ),

                    /// Κουμπί [ElevatedButton] υποβολής νέου task
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            /// Αρχικά ελέγχουμε αν τα στοιχεία της φόρμας
                            /// "παιρνούν" την επικύρωση (αν ο τίτλος δεν είναι
                            /// κενός)
                            if (_formKey.currentState!.validate()) {
                              String audioUrl = 'assets/audios/honk.mp3';
                              final ByteData data =
                                  await rootBundle.load(audioUrl);
                              // final Directory tempDir = Directory.systemTemp;
                              final Directory tempDir =
                                  await getTemporaryDirectory();
                              final File file =
                                  File('${tempDir.path}/audio1.mp3');
                              await file.writeAsBytes(data.buffer.asUint8List(),
                                  flush: true);
                              player.play(file.path, isLocal: true);

                              /// Αν ναι, δημιουργώ ένα νέο [Task] από τα στοι-
                              /// χεία της φόρμας
                              if (position) {
                                final parkingspot = ParkingSpot(
                                    destination: _titleController.text,
                                    street: _descriptionController.text,
                                    personal: true,
                                    disabled: _disabled,
                                    points: 0,
                                    isButtonVisible: false,
                                    date: DateTime.now(),
                                    user: 'me',
                                    exactLocation: await getCurrentLocation(),
                                    exact: true);
                                Navigator.pop(context, parkingspot);
                              } else {
                                final parkingspot = ParkingSpot(
                                    destination: _titleController.text,
                                    street: _descriptionController.text,
                                    personal: true,
                                    disabled: _disabled,
                                    points: 0,
                                    isButtonVisible: false,
                                    date: DateTime.now(),
                                    user: 'me',
                                    exact: false);
                                Navigator.pop(context, parkingspot);
                              }
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Color.fromARGB(255, 177, 57, 216)),
                          ),
                          child: const Text(
                            'Save',
                            style: TextStyle(color: Colors.black),
                          ),
                        )),
                  ],
                ))
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
        unselectedItemColor: Colors.white,
        selectedItemColor: Color.fromARGB(255, 177, 57, 216),
        onTap: _onItemTapped,
      ),
    );
  }
}
