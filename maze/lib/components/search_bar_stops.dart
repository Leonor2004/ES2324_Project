import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:maze/auxiliaries/fetch_stops.dart';
import 'package:maze/model/stop.dart';
import 'package:maze/components/map.dart';
import 'package:maze/components/select_time.dart';

List<Stop> stopCodes = [];

class SearchBarStops extends StatefulWidget {
  const SearchBarStops({super.key, required this.refresh});

  final void Function() refresh;

  @override
  SearchBarStopsState createState() => SearchBarStopsState();
}

class SearchBarStopsState extends State<SearchBarStops> {
  late Timer timer;

  @override
  void initState() {
    super.initState();
    fetchStopCodes(context);
    timer = Timer.periodic(const Duration(seconds: 30), (Timer t) {
      if (selectedDate != DateTime.now() && !changed) {
        setState(() {
          selectedDate = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    stopCodes.clear();
    timer.cancel();
    super.dispose();
  }

  List<Stop> filteredSuggestions = [];

  List<Stop> getSuggestionsBasedOnQuery(String query) {
    return stopCodes
        .where((item) =>
            item.code.toLowerCase().contains(query) ||
            item.name.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return SearchAnchor(
        viewBackgroundColor: Theme.of(context).hintColor,
        dividerColor: Theme.of(context).hintColor,
        headerHintStyle: TextStyle(color: Theme.of(context).focusColor),
        headerTextStyle: TextStyle(color: Theme.of(context).focusColor),
        builder: (BuildContext context, SearchController controller) {
          return Padding(
            padding: const EdgeInsets.only(top: 40, left: 15, right: 15),
            child: SearchBar(
              backgroundColor:
                  MaterialStateProperty.all(Theme.of(context).hintColor),
              controller: controller,
              onTap: () {
                controller.openView();
              },
              onChanged: (_) {
                controller.openView();
              },
              leading: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: SvgPicture.asset('images/maze.svg',
                    color: Theme.of(context).focusColor, height: 40),
              ),
              trailing: <Widget>[
                PopupMenuButton(
                  color: Theme.of(context).hintColor,
                  icon: Icon(Icons.access_time,
                      color: Theme.of(context).focusColor),
                  itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                    PopupMenuItem(
                      onTap: () => selectDate(context),
                      child: Text(
                        "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}",
                        style: TextStyle(color: Theme.of(context).focusColor),
                      ),
                    ),
                    PopupMenuItem(
                      onTap: () => selectTime(context),
                      child: Text(
                        '${selectedDate.hour}:${selectedDate.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(color: Theme.of(context).focusColor),
                      ),
                    ),
                    PopupMenuItem(
                      onTap: () => resetTime(),
                      child: Text(
                        'Reset Time',
                        style: TextStyle(color: Theme.of(context).focusColor),
                      ),
                    ),
                  ],
                ),
              ],
              hintText: 'Search',
              hintStyle: MaterialStatePropertyAll(
                  TextStyle(color: Theme.of(context).focusColor)),
              textStyle: MaterialStatePropertyAll(
                  TextStyle(color: Theme.of(context).focusColor)),
            ),
          );
        },
        suggestionsBuilder:
            (BuildContext context, SearchController controller) {
          String query = controller.text.toLowerCase();
          filteredSuggestions = getSuggestionsBasedOnQuery(query);

          return List.generate(filteredSuggestions.length, (int index) {
            final Stop item = filteredSuggestions[index];
            return ListTile(
              title: Text(
                "${item.code} - ${item.name}",
                style: TextStyle(color: Theme.of(context).focusColor),
              ),
              onTap: () {
                mapController.move(LatLng(item.lat, item.lon), 19.0);
                widget.refresh();
                Navigator.pop(context);
                FocusScope.of(context).unfocus();
              },
            );
          });
        });
  }
}
