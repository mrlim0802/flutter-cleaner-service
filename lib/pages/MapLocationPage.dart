// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:geocoder/geocoder.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';

class MapLocationPage extends StatefulWidget {
  const MapLocationPage({Key? key}) : super(key: key);

  @override
  State<MapLocationPage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MapLocationPage> {
  GoogleMapController? googleMapController;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Position? position;
  String? addressLocation;

  void getMarkers(double lat, double long) {
    MarkerId markerId = MarkerId(lat.toString() + long.toString());
    Marker _marker = Marker(
        markerId: markerId,
        position: LatLng(lat, long),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
        infoWindow: InfoWindow(snippet: 'Address'));
    setState(() {
      markers[markerId] = _marker;
    });
  }

  void getCurrentLocation() async {
    Position currentLocation =
        await GeolocatorPlatform.instance.getCurrentPosition();
    setState(() {
      position = currentLocation;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appbar
      appBar: AppBar(
        leading: BackButton(onPressed: (() {
          Navigator.of(context).pop();
        })),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      // end appbar

      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              height: 90.h,
              child: GoogleMap(
                onTap: ((tap) async {
                  final coordinated =
                      new geo.Coordinates(tap.latitude, tap.longitude);
                  var address = await geo.Geocoder.local
                      .findAddressesFromCoordinates(coordinated);
                  var firstAddress = address.first;
                  getMarkers(tap.latitude, tap.longitude);
                  await FirebaseFirestore.instance
                      .collection('booking_list')
                      .add({
                    'latitude': tap.latitude,
                    'longitude': tap.longitude,
                    'Address': firstAddress.addressLine,
                  });
                  setState(() {
                    addressLocation = firstAddress.addressLine;
                  });
                }),
                mapType: MapType.hybrid,
                compassEnabled: true,
                trafficEnabled: true,
                onMapCreated: (GoogleMapController controller) {
                  setState(() {
                    googleMapController = controller;
                  });
                },
                initialCameraPosition: CameraPosition(
                    target: LatLng(position!.latitude, position!.longitude),
                    zoom: 15.0),
                markers: Set<Marker>.of(markers.values),
              ),
            ),
            Text('address:${addressLocation}')
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}