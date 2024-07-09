import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:maze/auxiliaries/fetch_lines.dart';
import 'package:maze/model/line.dart';
import 'package:maze/pages/stop_page.dart';

class FavoriteStopItem extends StatelessWidget {
  final String stopId;

  const FavoriteStopItem({Key? key, required this.stopId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: Card(
        color: Theme.of(context).hintColor,
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        child: ListTile(
          dense: true,
          title: Text(
            stopId,
            style: TextStyle(
              color: Theme.of(context).focusColor,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: const Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StopPage(
                  stopId: stopId,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


class Favorites extends StatefulWidget {
  const Favorites({Key? key});

  @override
  _FavoritesState createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  late List<String> favoriteLineNumbers = [];
  late List<Line> favoriteLines = [];
  late List<String> favoriteStops = [];

  @override
  void initState() {
    super.initState();
    lines.clear();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      favoriteLines.clear();
      favoriteLineNumbers.clear();
    });
    await Future.wait([
      fetchLines(),
      _fetchFavoriteLineNumbers(),
      _fetchFavoriteStops(),
    ]);
    _filterFavoriteLines();
  }

  Future<void> _fetchFavoriteStops() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DatabaseEvent event = await FirebaseDatabase.instance
            .ref()
            .child('favorite_stops')
            .child(user.uid)
            .once();
        DataSnapshot snapshot = event.snapshot;
        Map<dynamic, dynamic>? values = snapshot.value as Map<dynamic, dynamic>?;

        if (values != null) {
          List<String> stopIDs = [];
          values.forEach((key, value) {
            if (value == true) {
              stopIDs.add(key.toString());
            }
          });
          setState(() {
            favoriteStops = stopIDs;
          });
        }
      } catch (error) {
        print("Error fetching favorite stops: $error");
      }
    }
  }

  Future<void> _fetchFavoriteLineNumbers() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DatabaseEvent event = await FirebaseDatabase.instance
            .ref()
            .child('favorites')
            .child(user.uid)
            .once();
        DataSnapshot snapshot = event.snapshot;
        Map<dynamic, dynamic>? values = snapshot.value as Map<dynamic, dynamic>?;

        if (values != null) {
          List<String> lineNumbers = [];
          values.forEach((key, value) {
            if (value == true) {
              lineNumbers.add(key.toString());
            }
          });
          setState(() {
            favoriteLineNumbers = lineNumbers;
          });
        }
      } catch (error) {
        print("Error fetching favorite line numbers: $error");
      }
    }
  }

  void _filterFavoriteLines() {
    favoriteLines = lines.where((line) => favoriteLineNumbers.contains(line.number)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(20.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).primaryColor,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                'Favorite Lines',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).focusColor,
                ),
              ),
            )
          ),
          Expanded(
            child: ListView.builder(
              itemCount: favoriteLines.length,
              itemBuilder: (context, index) {
                return Line(number: favoriteLines[index].number, from: favoriteLines[index].from, to: favoriteLines[index].to,);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                'Favorite Stops',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).focusColor,
                ),
              ),
            )
          ),
          Expanded(
            child: ListView.builder(
              itemCount: favoriteStops.length,
              itemBuilder: (context, index) {
                return FavoriteStopItem(stopId: favoriteStops[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}