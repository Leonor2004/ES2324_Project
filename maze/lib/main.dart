import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:maze/components/map.dart';
import 'package:maze/components/navigation_bar.dart';
import 'package:maze/pages/favorites.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/lines.dart';
import 'pages/profile.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();

  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLight = (PlatformDispatcher.instance.platformBrightness == Brightness.light);

  bool isThemeLight() {
    return isLight;
  }

  void toggleTheme() {
    setState(() {
      isLight = !isLight;
    });
  }

  void _resetLineReports() {
    DatabaseReference databaseReference =
        FirebaseDatabase.instance.ref().child('your_node');

    databaseReference.onValue.listen((event) {
      Map<dynamic, dynamic>? values =
          event.snapshot.value as Map<dynamic, dynamic>?;
      if (values != null) {
        values.forEach((key, value) {
          int day = int.parse(value['day']);
          int month = int.parse(value['month']);
          int hour = int.parse(value['hour']);
          //int minutes = int.parse(value['minutes']);

          if (((day < DateTime.now().day) &&
                  (month == DateTime.now().month) &&
                  hour < 22) ||
              ((day == DateTime.now().day) &&
                  (month == DateTime.now().month) &&
                  hour < 3)) {
            databaseReference.child(key).remove();
          }
        });
      }
    }, onError: (error) {
      print('Failed to fetch data: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    _resetLineReports();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Maze',
      theme: ThemeData(
          highlightColor: const Color.fromARGB(255, 218, 71, 49),
          primaryColor: Colors.white,
          hintColor: const Color.fromRGBO(242, 243, 243, 1.0),
          fontFamily: 'CenturyGothic',
          focusColor: Colors.black),
      darkTheme: ThemeData(
          highlightColor: const Color.fromARGB(255, 218, 71, 49),
          primaryColor: const Color.fromRGBO(26, 26, 27, 1.0),
          hintColor: const Color.fromRGBO(42, 42, 43, 1.0),
          fontFamily: 'CenturyGothic',
          focusColor: Colors.white),
      themeMode: isLight ? ThemeMode.light : ThemeMode.dark,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  void _changePage(int index){
    setState(() {
      currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      key: scaffoldKey,
      bottomNavigationBar: BottomBar(changePage: _changePage,),
      body: [
        const Profile(),
        const MapScreen(),
        const Lines(),
        const Favorites()
      ][currentPage],
    );
  }
}
