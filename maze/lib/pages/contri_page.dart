import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:maze/components/select_time.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../firebase_auth_implementation/users_database.dart';
import 'dart:math';
import 'package:maze/model/line_report.dart';

final databaseReference = FirebaseDatabase.instance.ref();

class ContriPage extends StatefulWidget {
  final String lineNumber;
  final String stopCode;
  final String trip;

  const ContriPage(
      {super.key,
      required this.lineNumber,
      required this.stopCode,
      required this.trip});

  @override
  _ContriPageState createState() => _ContriPageState();
}

class _ContriPageState extends State<ContriPage> {
  late Future<String> _futureCurrentStop;
  final FirebaseDatabaseService _databaseService = FirebaseDatabaseService();
  late DateTime time;
  late int offlineEta;
  int eta = 0;

  bool _isWaiting = true;
  bool _itArrived = true;
  bool _outService = false;

  bool isWaiting = false;
  bool itArrived = false;
  bool outService = false;

  late List<LineReport> contributions = [];

  int watching = 0;

  late Timer timer;

  @override
  void initState() {
    super.initState();
    _cleanFirebaseLineReports();
    selectedDate = DateTime.now();
    _futureCurrentStop = _currentStop(widget.trip, widget.stopCode);
    _initializeContributions();
    timer = Timer.periodic(const Duration(seconds: 10), (Timer t) {
      setState(() {
        selectedDate = DateTime.now();
        _futureCurrentStop = _currentStop(widget.trip, widget.stopCode);
        _initializeContributions();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  Future<void> _initializeContributions() async {
    await _fetchContributions();
    await _fetchETA();
    setState(() {});
  }

  // Function to generate a random string
  String generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(
      length,
      (_) => chars.codeUnitAt(random.nextInt(chars.length)),
    ));
  }

  void sendData() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && (itArrived || outService)) {
        _databaseService.updateContributions(user.uid).then((_) {
            print("Contribution incremented after report submission.");
        }).catchError((error) {
            print("Failed to increment contribution: $error");
        });
    }
    String randomString = generateRandomString(6);

    LineReport report = LineReport(
        id: '${widget.lineNumber}_$randomString',
        hour: selectedDate.hour,
        minutes: selectedDate.minute,
        line: widget.lineNumber,
        stopCode: widget.stopCode,
        trip: widget.trip,
        isWaiting: isWaiting,
        itArrived: itArrived,
        outService: outService,
        uid: user?.uid,
        diff: offlineEta);

    databaseReference
        .child("lines_reports")
        .child('${widget.lineNumber}_$randomString')
        .set(report.toJson());
    isWaiting = false;
    itArrived = false;
    outService = false;
}


  void _handleWaiting(BuildContext context) {
    setState(() {
      if (_isWaiting) {
        isWaiting = true;
        _isWaiting = false;
        _outService = true;
        _itArrived = true;
        sendData();
      }
      selectedDate = DateTime.now();
      _futureCurrentStop = _currentStop(widget.trip, widget.stopCode);
      _fetchContributions();
    });
  }

  void _handleOutOfService(BuildContext context) {
    setState(() {
      if (_outService) {
        outService = true;
        _isWaiting = false;
        _itArrived = false;
        _outService = false;
        sendData();
      }
      selectedDate = DateTime.now();
      _futureCurrentStop = _currentStop(widget.trip, widget.stopCode);
      _fetchContributions();
    });
  }

  void _handleArrived(BuildContext context) {
    setState(() {
      if (_itArrived) {
        itArrived = true;
        _isWaiting = false;
        _itArrived = false;
        _outService = true;
        sendData();
      }
      selectedDate = DateTime.now();
      _futureCurrentStop = _currentStop(widget.trip, widget.stopCode);
      _fetchContributions();
    });
  }

  Future<void> _cleanFirebaseLineReports() async {
    // Query Firebase to get the reports for day lines
    DatabaseEvent event = await databaseReference.child("lines_reports").once();
    DataSnapshot snapshot = event.snapshot;

    // Now you can proceed with your logic using the DataSnapshot
    Map<dynamic, dynamic>? reports = snapshot.value as Map<dynamic, dynamic>?;

    // Ensure reports is not null before proceeding
    if (reports != null) {
      reports.forEach((key, value) {
        if (value["day"] != DateTime.now().day ||
            DateTime.now().hour - value["hour"] >= 2) {
          databaseReference.child("lines_reports").child(key).remove();
        }
      });
    }
  }

  Future<void> _fetchContributions() async {
    watching = 0;
    contributions.clear();
    try {
      DatabaseEvent event =
          await databaseReference.child("lines_reports").once();
      DataSnapshot snapshot = event.snapshot;
      dynamic values = snapshot.value;
      
      values.forEach((key, value) {
        if (key.startsWith('${widget.lineNumber}_')) {
          if (value != null && value['trip'] == widget.trip) {
            if (value['line'] == widget.lineNumber) {
              if (value['isWaiting']) {                
                if (value['uid'] == FirebaseAuth.instance.currentUser?.uid) {
                  _isWaiting = false;
                  _itArrived = true;
                  _outService = true;
                }
                watching++;
                contributions.add(LineReport(
                    id: key,
                    hour: value['hour'],
                    minutes: value['minutes'],
                    line: value['line'],
                    stopCode: value['stopCode'],
                    trip: value['trip'],
                    isWaiting: true,
                    itArrived: false,
                    outService: false,
                    uid: value['uid']));
              } else if (value['itArrived']) {
                if (value['uid'] == FirebaseAuth.instance.currentUser?.uid) {
                  _isWaiting = false;
                  _itArrived = false;
                  _outService = true;
                }
                contributions.add(LineReport(
                    id: key,
                    hour: value['hour'],
                    minutes: value['minutes'],
                    line: value['line'],
                    stopCode: value['stopCode'],
                    trip: value['trip'],
                    isWaiting: false,
                    itArrived: true,
                    outService: false,
                    uid: value['uid']));
              } else if (value['outService']) {
                if (value['uid'] == FirebaseAuth.instance.currentUser?.uid) {
                  _isWaiting = false;
                  _itArrived = false;
                  _outService = false;
                }
                contributions.add(LineReport(
                    id: key,
                    hour: value['hour'],
                    minutes: value['minutes'],
                    line: value['line'],
                    stopCode: value['stopCode'],
                    trip: value['trip'],
                    isWaiting: false,
                    itArrived: false,
                    outService: true,
                    uid: value['uid']));
              }
            }
          }
        }
      });
    } catch (error) {
      print('Failed to fetch contributions: $error');
    }
  }

  Future<void> _fetchETA() async {
    DateTime latestReportTime = DateTime.fromMicrosecondsSinceEpoch(0);

    try {
      DatabaseEvent event =
          await databaseReference.child("lines_reports").once();
      DataSnapshot snapshot = event.snapshot;
      dynamic values = snapshot.value;

      values.forEach((key, value) {
        if (key is String && key.startsWith('${widget.lineNumber}_')) {
          if (value != null && value['trip'] == widget.trip) {
            if (value['itArrived']) {
              DateTime reportTime = DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                  int.parse(value['hour'].toString()),
                  int.parse(value['minutes'].toString()));

              if (reportTime.isAfter(latestReportTime)) {
                latestReportTime = reportTime;
                eta = value['diff'];
              }
            }
          }
        }
      });
    } catch (error) {
      print('Failed to fetch contributions: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser?.uid == null) {
      _isWaiting = false;
      _itArrived = false;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: IconThemeData(color: Theme.of(context).focusColor),
        title: Text(
          "${widget.lineNumber}  ${widget.stopCode}",
          style: TextStyle(
              color: Theme.of(context).focusColor,
              fontSize: 30,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Arrives at',
                    style: TextStyle(
                      color: Theme.of(context).focusColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      FutureBuilder<String>(
                        future: _futureCurrentStop,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            String? current;
                            if (snapshot.data == '') {
                              current = " -- ";
                            } else {
                              current = snapshot.data;
                            }
                            return Text(
                              '$current',
                              style: TextStyle(
                                color: Theme.of(context).focusColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }
                        },
                      ),
                      Text(
                        '  $eta',
                        style: TextStyle(
                          color: Theme.of(context).highlightColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    watching.toString(),
                    style: TextStyle(
                      color: Theme.of(context).highlightColor,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    Icons.person,
                    color: Theme.of(context).highlightColor,
                    size: 45,
                  ),
                ],
              ),
            ],
          ),
        ),
        ListTile(
          leading: Icon(Icons.timer,
              color:
                  _isWaiting ? Theme.of(context).highlightColor : Colors.grey),
          title: Text(
            'Waiting for this bus',
            style: TextStyle(
              color:
                  _isWaiting ? Theme.of(context).highlightColor : Colors.grey,
              fontSize: 17,
            ),
          ),
          onTap: _isWaiting ? () => _handleWaiting(context) : null,
        ),
        ListTile(
          leading: Icon(Icons.directions_bus,
              color:
                  _outService ? Theme.of(context).highlightColor : Colors.grey),
          title: Text(
            "It's out of service",
            style: TextStyle(
              color:
                  _outService ? Theme.of(context).highlightColor : Colors.grey,
              fontSize: 17,
            ),
          ),
          onTap: _outService ? () => _handleOutOfService(context) : null,
        ),
        ListTile(
          leading: Icon(Icons.check_circle,
              color:
                  _itArrived ? Theme.of(context).highlightColor : Colors.grey),
          title: Text(
            'It arrived',
            style: TextStyle(
              color:
                  _itArrived ? Theme.of(context).highlightColor : Colors.grey,
              fontSize: 17,
            ),
          ),
          onTap: _itArrived ? () => _handleArrived(context) : null,
        ),
        const ListTile(),
        Expanded(
          child: ListView.builder(
            itemCount: contributions.length,
            itemBuilder: (context, index) {
              return contributions[index];
            },
          ),
        ),
      ]),
    );
  }

  Future<String> _currentStop(String trip, String code) async {
    String jsonString = await rootBundle.loadString('files/stop_times.json');
    List<dynamic> data = json.decode(jsonString);
    String f = "";

    for (var value in data) {
      if (value["t"] == trip && value['s'] == code) {
        String departureTime = value["d"];

        List<String> timeParts = departureTime.split(":");
        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1]);
        String aux = "";

        DateTime etaTime = DateTime(DateTime.now().year, DateTime.now().month,
            DateTime.now().day, hour, minute);

        if (etaTime.isAfter(DateTime.now())) {
          if (minute < 10 && hour >= 10) {
            aux = '$hour:0$minute';
          } else if (minute >= 10 && hour < 10) {
            aux = '0$hour:$minute';
          } else if (minute < 10 && hour < 10) {
            aux = '0$hour:0$minute';
          } else if (minute >= 10 && hour >= 10) {
            aux = '$hour:$minute';
          }
          offlineEta = DateTime.now().difference(etaTime).inMinutes;

          return aux;
        }
      }
    }

    return f;
  }
}
