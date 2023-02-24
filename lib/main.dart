//import 'dart:html';
import 'dart:async';
import 'package:path/path.dart' as p;
//import 'package:path_provider/path_provider.dart';
import 'package:source_span/source_span.dart';
import 'package:intl/intl.dart';
import 'add.dart';
import 'rankings.dart';
import 'history.dart';
import 'profile.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:core';
import 'dart:collection';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
//import 'package:assets_audio_player/assets_audio_player.dart';

//AudioPlayer player = AudioPlayer();

void main() {
  runApp(const MyApp());
}

List<ParkingSpot> _parkingSpots = [
  ParkingSpot(
      destination: "Technopolis",
      exact: false,
      user: "alex",
      street: "Keleou",
      personal: false,
      disabled: false,
      date: DateTime(2022, 1, 1, 12),
      points: 23),
  ParkingSpot(
      destination: "New York",
      exact: false,
      street: "123 Main St",
      user: "george",
      personal: true,
      disabled: false,
      date: DateTime(2022, 1, 1, 12),
      points: 24),
  ParkingSpot(
      destination: "Chicago",
      street: "456 Park Ave",
      user: "maria",
      exact: false,
      personal: false,
      disabled: false,
      date: DateTime(2022, 1, 1, 12),
      points: 25),
  ParkingSpot(
      destination: "Los Angeles",
      street: "789 Sunset Blvd",
      personal: true,
      exact: false,
      user: "john",
      disabled: false,
      date: DateTime(2022, 1, 1, 12),
      points: 26),
  ParkingSpot(
      destination: "New York",
      street: "123 Main St",
      user: "maria",
      personal: true,
      disabled: false,
      exact: false,
      date: DateTime(2022, 1, 1, 12),
      points: 27),
  ParkingSpot(
      destination: "New York",
      street: "123 Main St",
      user: "maria",
      personal: true,
      exact: false,
      disabled: false,
      date: DateTime(2022, 1, 1, 12),
      points: 28),
  ParkingSpot(
      destination: "Chicago",
      street: "456 Park Ave dis.",
      personal: false,
      exact: false,
      user: "john",
      disabled: true,
      date: DateTime(2022, 1, 1, 12),
      points: 29),
  ParkingSpot(
      destination: "Los Angeles",
      street: "789 Sunset Blvd dis.",
      personal: true,
      exact: false,
      user: "alex",
      disabled: true,
      date: DateTime(2022, 1, 1, 12),
      points: 30),
  ParkingSpot(
      destination: "New York",
      street: "123 Main St dis.",
      personal: true,
      exact: false,
      user: "zoe",
      disabled: true,
      date: DateTime(2022, 1, 1, 12),
      points: 31),
  ParkingSpot(
      destination: "New York",
      street: "123 Main St",
      personal: true,
      exact: false,
      user: "angie",
      disabled: false,
      date: DateTime(2022, 1, 1, 12),
      points: 1),
  ParkingSpot(
      destination: "Chicago",
      street: "456 Park Ave",
      personal: false,
      exact: false,
      user: "peter",
      date: DateTime(2022, 1, 1, 12),
      disabled: false,
      points: 1),
  ParkingSpot(
      destination: "Los Angeles",
      street: "789 Sunset Blvd",
      personal: true,
      exact: false,
      user: "peter",
      date: DateTime(2022, 1, 1, 12),
      disabled: false,
      points: 34),
];
List<ParkingSpot> _filteredParkingSpots = [];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    _filteredParkingSpots.sort((b, a) => a.points.compareTo(b.points));
    //audioPlayer.setUrl('dukes.mp3');

    ///_parkingSpots.sort((b, a) => a.points.compareTo(b.points));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rapidpark',
      home: const ParkingSearchWidget(),
    );
  }
}

bool _disabled = false;

class ParkingSpot {
  int? id;
  String destination;
  String street;
  bool history;
  bool personal;
  bool disabled;
  int points;
  bool exact;
  bool isButtonVisible;
  DateTime date;
  String user;
  String? exactLocation;

  ParkingSpot(
      {this.id,
      this.exactLocation,
      required this.destination,
      required this.user,
      required this.street,
      this.history = false,
      required this.date,
      required this.personal,
      required this.disabled,
      required this.points,
      this.isButtonVisible = true,
      this.exact = false});

  ParkingSpot.fromMap(Map<String, dynamic> spot)
      : id = spot['id'],
        exactLocation = spot['exactLocation'],
        destination = spot['destination'],
        user = spot['user'],
        street = spot['street'],
        points = spot['points'],
        personal = spot['personal'] == 1 ? true : false,
        disabled = spot['disabled'] == 1 ? true : false,
        isButtonVisible = spot['isButtonVisible'] == 1 ? true : false,
        exact = spot['exact'] == 1 ? true : false,
        date = DateTime.parse(spot['date']),
        history = spot['history'] == 1 ? true : false;

  /// Απεικόνιση στιγμιοτύπου της κλάσης [Task] σε εγγραφή της ΒΔ
  Map<String, dynamic> toMap() {
    /// Υποχρεωτικά πεδία. Η ΒΔ SQLite δεν έχει πεδίο boolean, οπότε το
    /// [completed] γίνεται ακέραιος (integer)
    final record = {
      'id': id,
      'exactLocation': exactLocation,
      'destination': destination,
      'user': user,
      'street': street,
      'points': points,
      'personal': personal ? 1 : 0,
      'disabled': disabled ? 1 : 0,
      'isButtonVisible': isButtonVisible ? 1 : 0,
      'exact': exact ? 1 : 0,
      'date': date.toString()
    };

    return record;
  }
}

class ParkingSearchWidget extends StatefulWidget {
  const ParkingSearchWidget({Key? key}) : super(key: key);

  @override
  _ParkingSearchWidgetState createState() => _ParkingSearchWidgetState();
  List<ParkingSpot> get parkingspots => _parkingSpots;
}

class _ParkingSearchWidgetState extends State<ParkingSearchWidget> {
  int _selectedIndex = 0;
  AudioPlayer player = AudioPlayer();
  final TextEditingController _searchController = TextEditingController();
  late SQLiteService sqLiteService;
  void _addToHistory(index) {
    _filteredParkingSpots[index].history = true;
    _filteredParkingSpots[index].date = DateTime.now();
  }

  Future<String> loadAsset() async {
    return await rootBundle.loadString('music/dukes.mp3');
  }

  void _addParkingSpot() async {
    ParkingSpot? newSpot = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => AddWidget(parkingspots: widget.parkingspots)));
    if (newSpot != null) {
      /// Προσθήκη του νέου task στη βάση δεδομένων SQLite
      final newId = await sqLiteService.addParkingSpot(newSpot);

      /// Η συνάρτηση [addTask] μας επιστρέφει το πρωτεύων κλειδί της νέας
      /// εγγραφής, το οποίο το τοποθετούμε στο πεδίο id του task.
      newSpot.id = newId;

      /// Προσθήκη του νέου task στη λίστα των tasks και επανασχεδιασμός του
      /// [Stateful] widget
      _parkingSpots.add(newSpot);
      _filterParkingSpots();
      setState(() {});
    }
  }

  void _gotoprofile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              ParkingProfileWidget(parkingspots: widget.parkingspots)),
    );
  }

  void _onItemTapped(int index) async {
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
    Text(
      'Profile',
    ),
  ];

  @override
  void initState() {
    super.initState();
    //AudioPlayer audioPlayer = AudioPlayer();
    sqLiteService = SQLiteService();
    sqLiteService.initDB().whenComplete(() async {
      final spots = await sqLiteService.getSpots();
      setState(() {
        _parkingSpots.addAll(spots);
        _filteredParkingSpots = _parkingSpots;
      });
    });
  }

  _launchNavigation(String address) async {
    String url = 'https://www.google.com/maps/search/?api=1&query=' + address;
    await launch(url);
  }

  void _filterParkingSpots() {
    setState(() {
      _filteredParkingSpots = _parkingSpots
          .where((parkingSpot) =>
              parkingSpot.destination
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()) &&
              parkingSpot.disabled == _disabled)
          .toList();
      _filteredParkingSpots.sort((b, a) => a.points.compareTo(b.points));
    });
  }

  void _increasePoints(int index) {
    setState(() {
      _filteredParkingSpots[index].points += 1;
      _filteredParkingSpots[index].isButtonVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
        actions: [
          IconButton(
              onPressed: () {
                _gotoprofile();
              },
              icon: Icon(Icons.person))
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 50),
        child: Column(
          children: <Widget>[
            Container(
              width: 325,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 83, 78, 78),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.search,
                    color: Colors.black,
                    size: 30,
                  ),
                  SizedBox(
                    width: 275,
                    height: 50,
                    child: InkWell(
                      focusColor: Colors.grey,
                      highlightColor: Colors.grey,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          _filterParkingSpots();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
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
                      _filterParkingSpots();
                    });
                  }),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredParkingSpots.length,
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
                              "Destination: ${_filteredParkingSpots[index].destination}",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              "Address: ${_filteredParkingSpots[index].street}",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              "Points: ${_filteredParkingSpots[index].points}",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                onPressed: () async {
                                  //player.play('dukes.mp3', isLocal: true);

                                  //player.play('https://www.youtube.com/watch?v=iFPBhBRMyfw&ab_channel=CarFeatures');
                                  //player.play(
                                  //'https://drive.google.com/file/d/1SUtbGOspY4zNyB8a8pEBigVmz6xbcjNt/view?usp=sharing');

                                  _launchNavigation(
                                      _filteredParkingSpots[index].street);
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
                              Visibility(
                                visible:
                                    (!_filteredParkingSpots[index].personal &&
                                        _filteredParkingSpots[index]
                                            .isButtonVisible),
                                child: TextButton(
                                  onPressed: () async {
                                    _increasePoints(index);
                                    String audioUrl =
                                        'assets/audios/applause.mp3';
                                    final ByteData data =
                                        await rootBundle.load(audioUrl);
                                    // final Directory tempDir = Directory.systemTemp;
                                    final Directory tempDir =
                                        await getTemporaryDirectory();
                                    final File file =
                                        File('${tempDir.path}/audio2.mp3');
                                    await file.writeAsBytes(
                                        data.buffer.asUint8List(),
                                        flush: true);
                                    player.play(file.path, isLocal: true);
                                  },
                                  child: Container(
                                      decoration: BoxDecoration(
                                        color:
                                            Color.fromARGB(255, 177, 57, 216),
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.circular(40),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 10),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.workspace_premium_rounded,
                                            color: Colors.black,
                                            size: 20,
                                          ),
                                          Text(
                                            'Reward',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 13.0),
                                          ),
                                        ],
                                      )),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  _addToHistory(index);
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
                                          Icons.add_location_alt,
                                          color: Colors.black,
                                          size: 20,
                                        ),
                                        Text(
                                          'Add to history',
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
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _addParkingSpot,
        backgroundColor: Color.fromARGB(255, 177, 57, 216),
        tooltip: 'Add Task',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

/// SQLite
class SQLiteService {
  /// Αρχικοποίηση σύνδεσης με ΒΔ SQLite με όνομα todo.db η οποία βρίσκεται
  /// στη διαδρομή που αποθηκεύονται οι ΒΔ της εφαρμογής
  Future<Database> initDB() async {
    return openDatabase(
      p.join(await getDatabasesPath(), 'rapidpark.db'),

      /// Αν δεν υπάρχει η ΒΔ (πχ εκτελούμε πρώτη φορά την εφαρμογή), δημιούρ-
      /// γησέ την στο σύστημα αρχείων της συσκευής και κατόπιν άνοιξέ την
      onCreate: (db, version) async {
        //await db.execute('DROP TABLE spots;');
        return db.execute(
            'CREATE TABLE IF NOT EXISTS spots(id INTEGER PRIMARY KEY AUTOINCREMENT, destination TEXT, user TEXT, street TEXT, history INTEGER, personal INTEGER, disabled INTEGER, points INTEGER, isButtonVisible INTEGER, date TEXT, exactLocation TEXT, exact INTEGER)');

        //return db.execute(
        //"INSERT INTO spots (destination, user, street, history, personal, disabled, points, isButtonVisible, date) VALUES ('destination1', 'user1', 'street1', 1, 1, 0, 10, 1, '2021-01-01'), ('destination2', 'user2', 'street2', 0, 1, 1, 20, 0, '2021-02-01')");
      },
      version: 1,
    );
  }

  /// Ανάκτηση όλων των εγγραφών από τη ΒΔ
  Future<List<ParkingSpot>> getSpots() async {
    /// Σύνδεση με ΒΔ
    final db = await initDB();

    final List<Map<String, Object?>> queryResult = await db.query('spots');

    /// Μετατροπή τους από εγγραφές ΒΔ σε στιγμιότυπα κλάσης [Task]
    return queryResult.map((e) => ParkingSpot.fromMap(e)).toList();
  }

  /// Προσθήκη του [Task] [task] στη ΒΔ. Επιστρέφει την τιμή πρωτεύοντως κλειδιού
  /// της νέας εγγραφής
  Future<int> addParkingSpot(ParkingSpot spot) async {
    /// Σύνδεση με ΒΔ
    final db = await initDB();

    /// Σε περίπτωση που για κάποιο λόγο υπάρχει πανομοίτυπη εγγραφή στη ΒΔ
    /// αντικατέστησε την με την τρέχουσα
    return db.insert('spots', spot.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /* Διαγραφή task με [id] από τη ΒΔ
  Future<void> deleteSParkingpot(final id) async {
    /// Σύνδεση με ΒΔ
    final db = await initDB();

    /// Παράμετρος [where] καθορίζει με ποια κριτήρια θα αφαιρεθούν εγγραφές
    /// από τη ΒΔ (αυτή που έχει το πεδίο id ίσο με την τιμή που περνάμε ως
    /// παράμετρο στη [whereArgs]
    await db.delete('spots', where: 'id = ?', whereArgs: [id]);
  }

  // Ενημέρωση της κατάστασης ολοκλήρωσης της εγγραφής
  Future<void> updateCompleted(Task task) async {
    /// Σύνδεση με ΒΔ
    final db = await initDB();

    await db.update('tasks', {'completed': task.completed ? 1 : 0},
        where: 'id = ?',
        whereArgs: [task.id],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
  */
  /* Διαγραφή όλων των ολοκληρωμένων εγγραφών tasks από τη ΒΔ
  Future<void> deleteCompleted() async {
    /// Σύνδεση με ΒΔ
    final db = await initDB();

    /// Παράμετρος [where] καθορίζει με ποια κριτήρια θα αφαιρεθούν εγγραφές
    /// από τη ΒΔ (αυτές που έχουν το πεδίο completed true, δηλαδή 1)
    await db.delete('tasks', where: 'completed = 1');
  }*/

  /* Διαγραφή όλων των εγγραφών tasks από τη ΒΔ
  Future<void> deleteAll() async {
    /// Σύνδεση με ΒΔ
    final db = await initDB();

    await db.delete('tasks');
  }*/
}
