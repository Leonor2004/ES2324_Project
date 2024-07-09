import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:maze/pages/contri_page.dart';
import 'package:maze/components/select_time.dart';
import 'package:maze/pages/login.dart';

class StopPage extends StatefulWidget {
  final String stopId;

  const StopPage({super.key, required this.stopId});

  @override
  _StopPageState createState() => _StopPageState();
}

class _StopPageState extends State<StopPage> {
  late Timer timer;
  late Future<List<Map<String, dynamic>>> busSchedule;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    busSchedule = getBusSchedule(widget.stopId);
    timer = Timer.periodic(const Duration(seconds: 30), (Timer t) {
      if (!changed) selectedDate = DateTime.now();
      setState(() {});
    });
    checkFavorite();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Future<void> checkFavorite() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final String uid = user.uid;
      DatabaseReference favoritesRef = FirebaseDatabase.instance.ref().child('favorite_stops').child(uid);

      try {
        DataSnapshot snapshot = await favoritesRef.child(widget.stopId).once().then((event) => event.snapshot);
        setState(() {
          isFavorite = snapshot.value != null;
        });
      } catch (error) {
        print("Error checking favorite: $error");
        setState(() {
          isFavorite = false;
        });
      }
    } else {
      setState(() {
        isFavorite = false;
      });
    }
  }

  void _toggleFavorite() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        isFavorite = !isFavorite;
      });

      final String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        if (isFavorite) {
          saveFavoriteStopToFirebase(uid, widget.stopId);
        } else {
          removeFavoriteStopFromFirebase(uid, widget.stopId);
        }
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Login Required'),
            content: const Text('Please log in to add to favorites.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                  );
                },
                child: const Text('Log In'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: IconThemeData(color: Theme.of(context).focusColor),
        title: Text(
          widget.stopId,
          style: TextStyle(
            color: Theme.of(context).focusColor,
            fontSize: 30,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Theme.of(context).highlightColor : Theme.of(context).focusColor,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.only(bottom: 40, left: 20, right: 20),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: busSchedule,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              List<Map<String, dynamic>> buses = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20,),
                  Expanded(
                    child: ListView.builder(
                      itemCount: buses.length,
                      itemBuilder: (context, index) {
                        var bus = buses[index];
                        DateTime scheduledArrivalTime =
                            _parseTimeString(bus["departure"]);
                        Duration remainingTime =
                            scheduledArrivalTime.difference(selectedDate);
                        String formattedArrivalTime =
                            DateFormat('HH:mm').format(scheduledArrivalTime);

                        if (remainingTime.inMinutes < 120) {
                          Duration currentRemainingTime =
                              scheduledArrivalTime.difference(DateTime.now());
                          String remainingText =
                              currentRemainingTime.inMinutes == 0
                                  ? 'Passing'
                                  : '${currentRemainingTime.inMinutes} min';
                          String toAppear = formattedArrivalTime;
                          if (currentRemainingTime.inMinutes < 60) {
                            toAppear = remainingText;
                          }
                          return ListTile(
                            leading: SizedBox(
                              width: 30,
                              child: SvgPicture.asset(
                                'images/stcp.svg',
                                color: Theme.of(context).focusColor,
                              ),
                            ),
                            title: Text(
                              bus["bus_number"],
                              style: TextStyle(
                                color: Theme.of(context).focusColor,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: Text(
                              toAppear,
                              style: TextStyle(
                                  color: Theme.of(context).focusColor,
                                  fontSize: 15),
                            ),
                            onTap: () {
                              if (!changed) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ContriPage(
                                        lineNumber: bus["bus_number"],
                                        stopCode: widget.stopId,
                                        trip: bus["trip"]),
                                  ),
                                );
                              }
                            },
                          );
                        } else {
                          return Container(); //empty container if remainingMinutes > 120
                        }
                      },
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> getBusSchedule(String stopId) async {
    String jsonString = await rootBundle.loadString('files/stop_times.json');
    List<dynamic> data = json.decode(jsonString);

    DateTime generousDate = selectedDate.subtract(const Duration(minutes: 10));

    List<Map<String, dynamic>> schedule = data
        .where((bus) =>
            bus["s"] == stopId &&
            _isAfterCurrentTime(bus["t"], bus["d"], generousDate))
        .map((bus) {
      String busNumber = bus["t"].split("_")[0]; // Extract bus number
      return {"bus_number": busNumber, "departure": bus["d"], "trip": bus["t"]};
    }).toList();

    schedule.sort((a, b) => a["departure"].compareTo(b["departure"]));

    return schedule.take(10).toList();
  }

  bool _isAfterCurrentTime(
      String tripId, String arrivalTimeString, DateTime selectedDate) {
    String day;
    if (selectedDate.weekday == 6) {
      day = 'S';
    } else if (selectedDate.weekday == 7) {
      day = 'D';
    } else {
      day = 'U';
    }

    if (day != tripId.split("_")[2]) return false;
    List<String> parts = arrivalTimeString.split(':');
    DateTime arrivalTime = DateTime(selectedDate.year, selectedDate.month,
        selectedDate.day, int.parse(parts[0]), int.parse(parts[1]));

    return arrivalTime.isAfter(selectedDate);
  }

  DateTime _parseTimeString(String timeString) {
    List<String> parts = timeString.split(':');
    return DateTime(selectedDate.year, selectedDate.month, selectedDate.day,
        int.parse(parts[0]), int.parse(parts[1]));
  }
}

void saveFavoriteStopToFirebase(String uid, String stopID) {
  DatabaseReference favoritesRef = FirebaseDatabase.instance.ref().child('favorite_stops').child(uid);
  favoritesRef.child(stopID).set(true);
}

void removeFavoriteStopFromFirebase(String uid, String stopID) {
  DatabaseReference favoritesRef = FirebaseDatabase.instance.ref().child('favorite_stops').child(uid);
  favoritesRef.child(stopID).remove();
}
