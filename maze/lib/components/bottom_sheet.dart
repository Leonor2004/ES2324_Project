import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:maze/auxiliaries/fetch_times.dart';
import 'package:maze/components/select_time.dart';
import 'package:maze/pages/contri_page.dart';
import 'dart:async';

import 'package:maze/pages/login.dart';

class BusScheduleModal extends StatefulWidget {
  final String stopID;
  final dynamic value;
  const BusScheduleModal({Key? key, required this.stopID, required this.value}) : super(key: key);

  @override
  __BusScheduleModalState createState() => __BusScheduleModalState();
}

class __BusScheduleModalState extends State<BusScheduleModal> {
  late Future<List<Map<String, dynamic>>> busSchedule;
  late Timer timer;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    busSchedule = getBusSchedule(widget.stopID);
    if (!changed) selectedDate = DateTime.now();
    timer = Timer.periodic(const Duration(seconds: 30), (Timer t) {
      setState(() {
        if (!changed) selectedDate = DateTime.now();
        busSchedule = getBusSchedule(widget.stopID);
      });
    });
    checkFavorite();
  }

  Future<void> checkFavorite() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final String uid = user.uid;
      DatabaseReference favoritesRef = FirebaseDatabase.instance.ref().child('favorite_stops').child(uid);

      try {
        DataSnapshot snapshot = await favoritesRef.child(widget.stopID).once().then((event) => event.snapshot);
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


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: busSchedule,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else {
          List<dynamic> buses = snapshot.data as List<dynamic>;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.value["stop_name"],
                          style: TextStyle(
                            color: Theme.of(context).focusColor,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.value["stop_code"] + " | " + widget.value["zone_id"],
                          style: TextStyle(
                            color: Theme.of(context).highlightColor,
                            fontSize: 20,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_outline,
                            color: isFavorite ? Theme.of(context).highlightColor : Theme.of(context).focusColor,
                          ),
                          onPressed: () {
                            _toggleFavorite();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(5),
                  itemCount: buses.length,
                  itemBuilder: (context, index) {
                    var bus = buses[index];
                    DateTime scheduledArrivalTime =
                    _parseTimeString(bus["departure"]);
                    String formattedArrivalTime =
                    DateFormat('HH:mm').format(scheduledArrivalTime);

                    Duration remainingTime =
                    scheduledArrivalTime.difference(selectedDate);

                    if (remainingTime.inMinutes < 120) {
                      String remainingText = remainingTime.inMinutes == 0
                          ? 'Passing'
                          : '${remainingTime.inMinutes} min';
                      String toAppear =
                      (remainingTime.inMinutes < 60 && !changed)
                          ? remainingText
                          : formattedArrivalTime;
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
                                  stopCode: widget.stopID,
                                  trip: bus["trip"]),
                              ),
                            );
                          }
                        },
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }

  DateTime _parseTimeString(String timeString) {
    List<String> parts = timeString.split(':');
    return DateTime(selectedDate.year, selectedDate.month, selectedDate.day,
        int.parse(parts[0]), int.parse(parts[1]));
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
          saveFavoriteStopToFirebase(uid, widget.stopID);
        } else {
          removeFavoriteStopFromFirebase(uid, widget.stopID);
        }
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).hintColor,
            title: Text('Login Required', style: TextStyle(color: Theme.of(context).focusColor),),
            content: Text('Please log in to add to favorites.', style: TextStyle(color: Theme.of(context).focusColor),),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Login()),
                  );
                },
                child: Text('Log In', style: TextStyle(color: Theme.of(context).focusColor),),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel', style: TextStyle(color: Theme.of(context).focusColor),),
              ),
            ],
          );
        },
      );
    }
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
