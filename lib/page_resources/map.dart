import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:project_mobile_app/models/activityProvider.dart';
import 'package:provider/provider.dart';


/* Widget for displaying a map when viewing an activity 
or while your run is paused */
class myMap extends StatefulWidget {
  List<LatLng> route;
  myMap({super.key, required this.route});
  @override
  State<myMap> createState() => _myMapState();
}

class _myMapState extends State<myMap> {
  @override
  Widget build(BuildContext context) {
    LatLng center;
    double zoom = 11.00;
    /* Dictating where to put center focus on the run
    and how much too zoom  */
    if (widget.route.isNotEmpty) {
      double Lat =
          (widget.route[0].latitude - widget.route.last.latitude).abs();
      double Lng =
          (widget.route[0].longitude - widget.route.last.longitude).abs();
      if (Lat > 0.00001 || Lng > 0.00001) {
        zoom = 15.0;
      }
      if (Lng > 0.0001 || Lat > 0.0001) {
        zoom = 14.0;
      }
      if (Lng > 0.001 || Lat > 0.001) {
        zoom = 13.0;
      }
      if (Lng > 0.01 || Lat > 0.01) {
        zoom = 12.50;
      }
      if (Lng > 0.1 || Lat > 0.1) {
        zoom = 11.0;
      }
      if (Lng > 1 || Lng > 1) {
        zoom = 10.0;
      }
      Lat = (widget.route[0].latitude + widget.route.last.latitude) / 2;
      Lng = (widget.route[0].longitude + widget.route.last.longitude) / 2;
      center = LatLng(Lat, Lng);
    } else {
      zoom = 15.00;
      center = LatLng(59.617, 16.559);
    }

    return FlutterMap(
      options: MapOptions(
        center: center,
        zoom: zoom,
        pinchZoomWinGestures: MultiFingerGesture.pinchZoom
      ),
      nonRotatedChildren: [
        AttributionWidget.defaultWidget(
          source: 'OpenStreetMap contributors',
          onSourceTapped: null,
        ),
      ],
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        widget.route.isNotEmpty ?  MarkerLayer(
          markers: [
            /* Markers for displaying end and starting point */
            Marker(
              anchorPos: AnchorPos.exactly(Anchor(13, 3)),
              point: widget.route[0], 
              builder: ((context) => Container(
                child: Icon(
                  Icons.place_sharp, 
                  size: 30,
                ),
              ))
            ),
            Marker(
              anchorPos: AnchorPos.exactly(Anchor(22, 6)),
              point: widget.route.last, 
              builder: ((context) => Container(
                child: Icon(
                  Icons.assistant_photo_sharp, 
                  size: 30,
                ),
              ))
            )

          ],
        ) : MarkerLayer() , 
        PolylineLayer(
          polylineCulling: false,
          polylines: [
            Polyline(
              points: widget.route,
              /* drwaing the route of the choosen run on the map */
              color: Theme.of(context).primaryColor,
              strokeWidth: 4,
            ),
          ],
        ),
      ],
    );
  }
}
