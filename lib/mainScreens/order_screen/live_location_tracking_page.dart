import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/global/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:delivery_service_user/models/new_order.dart';

class LiveLocationTrackingPage extends StatefulWidget {
  final NewOrder order;

  const LiveLocationTrackingPage({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  _LiveLocationTrackingPageState createState() =>
      _LiveLocationTrackingPageState();
}

class _LiveLocationTrackingPageState extends State<LiveLocationTrackingPage> {
  late GoogleMapController mapController;
  BitmapDescriptor? userMarkerIcon;
  BitmapDescriptor? riderMarkerIcon;

  Marker? _userLocationMarker;
  Marker? _riderLocationMarker;

  PolylinePoints polylinePoints = PolylinePoints();
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};

  final String _mapStyle = '''
  [
    {
      "featureType": "poi",
      "stylers": [{"visibility": "off"}]
    },
    {
      "featureType": "road",
      "elementType": "labels",
      "stylers": [{"visibility": "off"}]
    },
    {
      "featureType": "transit",
      "stylers": [{"visibility": "off"}]
    },
    {
      "featureType": "administrative",
      "stylers": [{"visibility": "off"}]
    }
  ]
  ''';

  @override
  void initState() {
    super.initState();
    _initializeMarkers();
  }

  Future<void> _initializeMarkers() async {
    await _loadCustomIcons();
    _setMarkers();
    _fetchRiderLocation();
  }

  Future<void> _loadCustomIcons() async {
    userMarkerIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(96, 96)),
      'assets/custom_icons/custom_user_marker.png',
    );
    riderMarkerIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(96, 96)),
      'assets/custom_icons/custom_rider_marker.png',
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController.setMapStyle(_mapStyle);
    _centerCameraBetweenCoordinates();
  }

  void _setMarkers() {
    _userLocationMarker = Marker(
      markerId: const MarkerId('userLocation'),
      position: LatLng(
        widget.order.userLocation!.latitude,
        widget.order.userLocation!.longitude,
      ),
      icon: userMarkerIcon ?? BitmapDescriptor.defaultMarker,
    );
  }

  void _fetchRiderLocation() {
    FirebaseFirestore.instance
        .collection('active_orders')
        .doc(widget.order.orderID)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        final GeoPoint? riderLocation = data['riderLocation'];

        if (riderLocation != null) {
          setState(() {
            _riderLocationMarker = Marker(
              markerId: const MarkerId('riderLocation'),
              position: LatLng(riderLocation.latitude, riderLocation.longitude),
              icon: riderMarkerIcon ?? BitmapDescriptor.defaultMarker,
            );
            _createPolylines(
              LatLng(widget.order.userLocation!.latitude,
                  widget.order.userLocation!.longitude),
              LatLng(riderLocation.latitude, riderLocation.longitude),
            );
          });
          _centerCameraBetweenCoordinates();
        }
      }
    });
  }

  void _centerCameraBetweenCoordinates() {
    if (_riderLocationMarker == null || _userLocationMarker == null) return;

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        widget.order.userLocation!.latitude <
            _riderLocationMarker!.position.latitude
            ? widget.order.userLocation!.latitude
            : _riderLocationMarker!.position.latitude,
        widget.order.userLocation!.longitude <
            _riderLocationMarker!.position.longitude
            ? widget.order.userLocation!.longitude
            : _riderLocationMarker!.position.longitude,
      ),
      northeast: LatLng(
        widget.order.userLocation!.latitude >
            _riderLocationMarker!.position.latitude
            ? widget.order.userLocation!.latitude
            : _riderLocationMarker!.position.latitude,
        widget.order.userLocation!.longitude >
            _riderLocationMarker!.position.longitude
            ? widget.order.userLocation!.longitude
            : _riderLocationMarker!.position.longitude,
      ),
    );

    mapController.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50),
    );
  }

  Future<void> _createPolylines(LatLng startPoint, LatLng endPoint) async {
    polylineCoordinates.clear();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      apiKey, // Replace with your actual Google Maps API Key
      PointLatLng(startPoint.latitude, startPoint.longitude),
      PointLatLng(endPoint.latitude, endPoint.longitude),
    );

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
      _addPolyline();
    } else {
      print("Failed to fetch route: ${result.status}");
    }
  }

  void _addPolyline() {
    PolylineId id = const PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Color.fromARGB(255, 76, 201, 254),
      width: 5,
      points: polylineCoordinates,
    );
    setState(() {
      polylines[id] = polyline;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Delivery Tracking'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng(
            widget.order.userLocation!.latitude,
            widget.order.userLocation!.longitude,
          ),
          zoom: 14,
        ),
        markers: {
          if (_userLocationMarker != null) _userLocationMarker!,
          if (_riderLocationMarker != null) _riderLocationMarker!,
        },
        polylines: Set<Polyline>.of(polylines.values),
        myLocationEnabled: false,
        myLocationButtonEnabled: false,
      ),
    );
  }
}
