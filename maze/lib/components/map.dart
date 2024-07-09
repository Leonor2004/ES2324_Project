import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:maze/auxiliaries/fetch_stops.dart';
import 'package:maze/components/search_bar_stops.dart';
import 'package:maze/main.dart';

List<Marker> markers = [];
LatLng mapPosition = const LatLng(41.1579, -8.6291);
double mapZoom = 13.0;
double mapRotation = 0;
MapController mapController = MapController();
StreamController<double?> alignPositionStreamController =
    StreamController<double?>();
AlignOnUpdate alignPositionOnUpdate = AlignOnUpdate.never;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  void initState() {
    super.initState();
    _initializeMap();
    _initializeLocator();
  }

  @override
  void dispose() {
    markers.clear();
    alignPositionStreamController.close();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    await fetchStops(context);
    setState(() {});
  }

  Future<void> _initializeLocator() async {
    setState(() {
      alignPositionStreamController = StreamController<double?>();
    });
  }

  void _refresh() {
    setState(
      () => alignPositionOnUpdate = AlignOnUpdate.never,
    );
  }

  @override
  Widget build(BuildContext context) {
    return markers.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : Stack(
            children: [
              FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: mapPosition, // Porto coordinates
                  initialZoom: mapZoom,
                  initialRotation: mapRotation,
                  maxZoom: 20.0,
                  minZoom: 11,
                  keepAlive: true,
                  cameraConstraint: CameraConstraint.contain(
                    bounds: LatLngBounds(
                      const LatLng(41.013498, -8.767652), // southwest
                      const LatLng(41.283688, -8.347762), // northeast
                    ),
                  ),
                  onPositionChanged: (position, hasGesture) {
                    mapZoom = mapController.camera.zoom;
                    mapPosition = mapController.camera.center;
                    mapRotation = mapController.camera.rotation;
                    if (hasGesture) {
                      setState(
                        () => alignPositionOnUpdate = AlignOnUpdate.never,
                      );
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: MyApp.of(context)!.isThemeLight()
                        ? 'http://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png'
                        : 'http://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
                    tileBounds: LatLngBounds(
                      const LatLng(41.013498, -8.767652), // southwest
                      const LatLng(41.283688, -8.347762), // northeast
                    ),
                  ),
                  MarkerClusterLayerWidget(
                    options: MarkerClusterLayerOptions(
                      maxClusterRadius: 30,
                      size: const Size(0, 0),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(30),
                      maxZoom: 15,
                      markers: markers,
                      builder: (context, markers) {
                        return const SizedBox();
                      },
                    ),
                  ),
                  CurrentLocationLayer(
                    alignPositionStream: alignPositionStreamController.stream,
                    alignPositionOnUpdate: alignPositionOnUpdate,
                    style: const LocationMarkerStyle(
                      marker: DefaultLocationMarker(),
                      markerSize: Size(20, 20),
                      markerDirection: MarkerDirection.heading,
                      showAccuracyCircle: false,
                      showHeadingSector: false,
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: FloatingActionButton(
                        backgroundColor: Theme.of(context).highlightColor,
                        onPressed: () {
                          setState(
                            () => alignPositionOnUpdate = AlignOnUpdate.always,
                          );
                          alignPositionStreamController.add(19);
                        },
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SearchBarStops(refresh: _refresh),
            ],
          );
  }
}
