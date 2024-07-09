import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:maze/model/stop.dart';
import 'package:maze/components/bottom_sheet.dart';
import 'package:maze/components/map.dart';
import 'package:maze/components/search_bar_stops.dart';

Map<String, String> stops = {};

Future<void> fetchStops(BuildContext context) async {
  String jsonString = await rootBundle.loadString('files/stops.json');
  Map<String, dynamic> data = json.decode(jsonString);

  data.forEach((key, value) {
    double lat = double.parse(value["stop_lat"]);
    double lon = double.parse(value["stop_lon"]);
    stops[key] = value["stop_name"];
    markers.add(
      Marker(
          point: LatLng(lat, lon),
          width: 30.0,
          height: 30.0,
          rotate: true,
          child: IconButton(
              icon: Icon(Icons.directions_bus,
                  color: Theme.of(context).highlightColor),
              onPressed: () {
                showModalBottomSheet(
                  backgroundColor: Theme.of(context).hintColor,
                  context: context,
                  builder: (BuildContext context) {
                    return BusScheduleModal(
                      stopID: key,
                      value: value,
                    );
                  },
                );
              })),
    );
  });
}

Future<void> fetchStopCodes(BuildContext context) async {
  String jsonString = await rootBundle.loadString('files/stops.json');
  Map<String, dynamic> data = json.decode(jsonString);

  data.forEach((key, value) {
    double lat = double.parse(value["stop_lat"]);
    double lon = double.parse(value["stop_lon"]);
    stopCodes.add(
      Stop(code: key, lat: lat, lon: lon, name: value["stop_name"]),
    );
  });
}
