import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_mapbox_navigation/library.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:ke/pages/createStore.dart';
import 'package:ke/pages/navigationPath.dart';
import 'package:ke/persistence/models/storeModel.dart';
import 'package:ke/persistence/repositories/reservationRepository.dart';
import 'package:ke/persistence/repositories/storeRepository.dart';
import 'package:ke/providers/authServices.dart';
import 'package:ke/providers/currentPositionProvider.dart';
import 'package:ke/providers/utilsProvider.dart';
import 'package:ke/utils/apiCalls.dart';
import 'package:ke/utils/mapTypes.dart';
import 'package:ke/utils/nextEntryPreview.dart';
import 'package:ke/utils/notifications.dart';
import 'package:ke/utils/rippleAnimation.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ke/providers/apiServicesProvider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:ke/utils/localizationsKE.dart';
import 'dart:ui' as ui;

class MapPage extends StatefulWidget {
  MapPage({Key key, this.title, this.language, this.mapType}) : super(key: key);
  final String title;
  final String language;
  final MapTypes mapType;

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  ApiCalls apiCalls;
  StoreRepository repository;
  double searchBarPosition = 150;
  TextEditingController _typeAheadController;
  ReservationRepository reservationRepository;
  bool comprobationFinished = false;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime onlydate = DateTime.now();
  DateTime onlyhour;
  DateTime currentTime = DateTime.now().add(Duration(days: 1));
  int cantP = 1;
  bool gettingReservations = false;
  int availableReservations;
  Notifications notifications = new Notifications();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Completer<GoogleMapController> _controller = Completer();
  final Geolocator _geolocator = Geolocator();
  CameraPosition _initialLocation = CameraPosition(target: LatLng(0.0, 0.0));
  /*CameraPosition _initialLocation =
      CameraPosition(target: LatLng(20.9560264, -76.956977));*/
  GoogleMapController mapController;
  final startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();
  String _currentAddress = "";
  String _startAddress = '';
  String _destinationAddress = '';
  String _placeDistance;
  bool showTravelData = false;
  bool showReservationsInfo = false;
  int _remainingTime;
  String _arrivalTime;
  Geolocator geolocator = new Geolocator();
  Set<Marker> markers = {};
  AuthServices _auth;
  PolylinePoints polylinePoints;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  List<LatLng> auxPolylineCoordinates = [];
  BitmapDescriptor storeIcon;
  BitmapDescriptor currentLocationIcon;
  BitmapDescriptor destinationIcon;
  TextEditingController _search = new TextEditingController();
  List<DateAux> horariosDisponibles = new List();
  int currentPosition = 0;
  PageController _pageController;
  StoreModel currentStore;
  bool showAvailableReservations = false;
  bool justThisTime = true;
  bool currentStoreClose = false;
  StoreModel selectedMarkerId;
  bool loading = false;
  MapBoxNavigation _directions;
  MapBoxOptions _options;
  String _platformVersion = 'Unknown';
  final _origin =
      WayPoint(name: "Way Point 1", latitude: 20.955450, longitude: -76.958669);
  final _stop1 =
      WayPoint(name: "Way Point 2", latitude: 20.954899, longitude: -76.951309);
  bool _arrived = false;
  bool _isMultipleStop = false;
  double _distanceRemaining, _durationRemaining;
  MapBoxNavigationViewController _mapboxController;
  bool _routeBuilt = false;
  bool _isNavigating = false;
  String _instruction = "";
  TravelMode travelMode = TravelMode.driving;
  int simulatePosition = 0;
  double simulateBearing = 0;
  BitmapDescriptor sourceIcon2;
  UtilsProvider _utils;
  bool showfinding = true;

  Widget _textField({
    TextEditingController controller,
    String label,
    String hint,
    String initialValue,
    double width,
    Icon prefixIcon,
    Widget suffixIcon,
    Function(String) locationCallback,
  }) {
    return Container(
      width: width * 0.8,
      child: TextField(
        onChanged: (value) {
          locationCallback(value);
        },
        controller: controller,
        // initialValue: initialValue,
        decoration: new InputDecoration(
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.grey[400],
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.blue[300],
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.all(15),
          hintText: hint,
        ),
      ),
    );
  }

// For storing the current position
  Position _currentPosition;
  /*Position _currentPosition =
      new Position(latitude: 20.9560264, longitude: -76.956977);*/

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("Lenguaje: " + widget.language);
    _pageController = PageController(viewportFraction: 0.9);
    apiCalls =
        Provider.of<ApiServicesProvider>(context, listen: false).apiCalls;
    _getCurrentLocation();
    setMarkerIcons();
    _typeAheadController = new TextEditingController();
    var initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');
    var initializationSettingsIOs = IOSInitializationSettings();
    var initSetttings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOs);

    flutterLocalNotificationsPlugin.initialize(
      initSetttings,
      //onSelectNotification: onSelectNotification
    );
    initializeTimeZone();
    initialize();
    StreamSubscription positionStream =
        Geolocator().getPositionStream().listen((Position position) {
      setState(() {
        _currentPosition = position;
        updatePinOnMap();
      });
    });

    //scheduleNotification();
  }

  initializeTimeZone() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(DateTime.now().timeZoneName));
  }

  Future onSelectNotification(String payload) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return NewScreen(payload: payload);
    }));
  }

  Future<void> initialize() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    _directions = MapBoxNavigation(onRouteEvent: _onEmbeddedRouteEvent);
    _options = MapBoxOptions(
        //initialLatitude: 36.1175275,
        //initialLongitude: -115.1839524,
        zoom: 15.0,
        tilt: 0.0,
        bearing: 0.0,
        enableRefresh: false,
        alternatives: true,
        voiceInstructionsEnabled: true,
        bannerInstructionsEnabled: true,
        allowsUTurnAtWayPoints: true,
        mode: MapBoxNavigationMode.drivingWithTraffic,
        units: VoiceUnits.imperial,
        simulateRoute: false,
        animateBuildRoute: true,
        longPressDestinationEnabled: true,
        language: "en");

    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await _directions.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  startRoute() async {
    WayPoint current = WayPoint(
        name: "current",
        latitude: _currentPosition.latitude,
        longitude: _currentPosition.longitude);
    WayPoint store = WayPoint(
        name: "store",
        latitude: currentStore.latitude,
        longitude: currentStore.longitude);
    var wayPoints = List<WayPoint>();
    wayPoints.add(current);
    wayPoints.add(store);

    await _directions.startNavigation(
        wayPoints: wayPoints,
        options: MapBoxOptions(
            mode: MapBoxNavigationMode.drivingWithTraffic,
            simulateRoute: true,
            language: LocalizationsKE.of(context).locale.toString(),
            units: VoiceUnits.metric));
  }

  Future<void> _onEmbeddedRouteEvent(e) async {
    _distanceRemaining = await _directions.distanceRemaining;
    _durationRemaining = await _directions.durationRemaining;

    switch (e.eventType) {
      case MapBoxEvent.progress_change:
        var progressEvent = e.data as RouteProgressEvent;
        _arrived = progressEvent.arrived;
        if (progressEvent.currentStepInstruction != null)
          _instruction = progressEvent.currentStepInstruction;
        break;
      case MapBoxEvent.route_building:
      case MapBoxEvent.route_built:
        setState(() {
          _routeBuilt = true;
        });
        break;
      case MapBoxEvent.route_build_failed:
        setState(() {
          _routeBuilt = false;
        });
        break;
      case MapBoxEvent.navigation_running:
        setState(() {
          _isNavigating = true;
        });
        break;
      case MapBoxEvent.on_arrival:
        _arrived = true;
        if (!_isMultipleStop) {
          await Future.delayed(Duration(seconds: 3));
          await _mapboxController.finishNavigation();
        } else {}
        break;
      case MapBoxEvent.navigation_finished:
      case MapBoxEvent.navigation_cancelled:
        setState(() {
          _routeBuilt = false;
          _isNavigating = false;
        });
        break;
      default:
        break;
    }
    setState(() {});
  }

  getStores() {
    apiCalls.getStoresByCity().then((value) {
      setState(() {
        markers.clear();
        polylines.clear();
        repository = StoreRepository.fromJson(value);

        for (var i = 0; i < repository.stores.length; i++) {
          if (_currentPosition != null) {
            double dist = _coordinateDistance(
                repository.stores[i].latitude,
                repository.stores[i].longitude,
                _currentPosition.latitude,
                _currentPosition.longitude);
            dist *= 1000;
            print("DIST: " + dist.toString());
            repository.stores[i].distance = dist;
            if (dist < 20000) {
              //addStoreMarker(repository.stores[i]);
            }
          }
        }
        // repository.stores.sort((a, b) => a.distance.compareTo(b.distance));
      });
      if (_currentPosition != null) {
        Marker startMarker = Marker(
          markerId: MarkerId('currentPosition'),
          position: LatLng(
            _currentPosition.latitude,
            _currentPosition.longitude,
          ),
          icon: currentLocationIcon,
        );
        markers.add(startMarker);
      }
    });
  }

// For controlling the view of the Map

  void updatePinOnMap() async {
    setState(() {
      var pinPosition =
          LatLng(_currentPosition.latitude, _currentPosition.longitude);
      markers.removeWhere((m) => m.markerId.value == 'sourcePin');
      Marker startMarker = Marker(
        markerId: MarkerId('currentPosition'),
        position: LatLng(
          _currentPosition.latitude,
          _currentPosition.longitude,
        ),
        icon: currentLocationIcon,
      );
      markers.add(startMarker);
    });
  }

  _getCurrentLocation() async {
    await _geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        // Store the position in the variable
        _currentPosition = position;
        showfinding = false;
        print('CURRENT POS: $_currentPosition');

        // For moving the camera to current location
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 18.0,
            ),
          ),
        );
      });
      getStores();
      // await _getAddress();
    }).catchError((e) {
      print(e);
    });
  }

  _getAddress(LatLng latLng) async {
    try {
      // Places are retrieved using the coordinates
      List<Placemark> p = await _geolocator.placemarkFromCoordinates(
          latLng.latitude, latLng.longitude);
      // Taking the most probable result
      Placemark place = p[0];

      setState(() {
        // Structuring the address
        _currentAddress =
            "${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";
        print("CURRENT: " + _currentAddress);
        // Update the text of the TextField
        startAddressController.text = _currentAddress;

        // Setting the user's present location as the starting address
        _startAddress = _currentAddress;
      });
    } catch (e) {
      print(e);
    }
  }

  cleanMarkers() {
    //print("Clean: " + selectedMarkerId.toMap().toString());
    /* if (selectedMarkerId != null) {
      Marker newMarker = Marker(
          markerId: MarkerId('${selectedMarkerId.id}'),
          position: LatLng(
            selectedMarkerId.latitude,
            selectedMarkerId.longitude,
          ),
          icon: storeIcon,
          onTap: () {
            _calculateDistance(_currentPosition, selectedMarkerId);
          });
      setState(() {
        markers.removeWhere(
            (element) => element.markerId == MarkerId(selectedMarkerId.id));
        markers.add(newMarker);
      });
    }*/
    setState(() {
      markers.clear();
      polylines.clear();
      /* for (var i = 0; i < repository.stores.length; i++) {
        if (repository.stores[i].distance < 20000)
          addStoreMarker(repository.stores[i]);
      }*/
      Marker startMarker = Marker(
        markerId: MarkerId('currentPosition'),
        position: LatLng(
          _currentPosition.latitude,
          _currentPosition.longitude,
        ),
        icon: currentLocationIcon,
      );
      markers.add(startMarker);
    });
  }

  changeTravelMode(TravelMode mode) {
    setState(() {
      travelMode = mode;
      _calculateDistance(_currentPosition, currentStore);

      PolylineId id = PolylineId('poly');
      Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.indigo,
        points: polylineCoordinates,
        width: 8,
      );
      polylines[id] = polyline;
    });
  }

  Future<Uint8List> getBytesFromCanvas(int width, int height) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = Colors.indigo;
    final Radius radius = Radius.circular(20.0);
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(0.0, 0.0, width.toDouble(), height.toDouble()),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        paint);

    TextPainter painter = TextPainter(textDirection: ui.TextDirection.ltr);
    painter.text = TextSpan(
      children: <TextSpan>[
        TextSpan(
            text: LocalizationsKE.of(context).reservar,
            style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                decoration: TextDecoration.underline)),
      ],
    );
    painter.layout();
    painter.paint(
        canvas,
        Offset((width * 0.5) - painter.width * 0.5,
            (height * 0.5) - painter.height * 0.5));
    final img = await pictureRecorder.endRecording().toImage(width, height);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return data.buffer.asUint8List();
  }

  Future<bool> _calculateDistance(
      Position startCoordinates, StoreModel storeModel) async {
    print("YESS");
    try {
      // Retrieving placemarks from addresses
      /* List<Placemark> startPlacemark =
          await _geolocator.placemarkFromAddress(_startAddress);
      List<Placemark> destinationPlacemark =
          await _geolocator.placemarkFromAddress(_destinationAddress);*/
      setState(() {
        polylineCoordinates.clear();
        auxPolylineCoordinates.clear();
        polylines.clear();
      });
      //  if (startPlacemark != null && destinationPlacemark != null) {

      // Use the retrieved coordinates of the current position,
      // instead of the address if the start position is user's
      // current position, as it results in better accuracy.
      /* Position startCoordinates = _startAddress == _currentAddress
            ? Position(
                latitude: _currentPosition.latitude,
                longitude: _currentPosition.longitude)
            : startPlacemark[0].position;
        Position destinationCoordinates = destinationPlacemark[0].position;*/

      /* String text = LocalizationsKE.of(context).hora +
            horariosDisponibles[0].text +
            "\n" +
            LocalizationsKE.of(context).disponibles +
            (storeModel.bunchClients -
                    availableByDate(horariosDisponibles[0].dateTime))
                .toString();*/
      final Uint8List markerIcon = await getBytesFromCanvas(200, 60);
      Marker newMarker = Marker(
          markerId: MarkerId('${storeModel.id}'),
          position: LatLng(
            storeModel.latitude,
            storeModel.longitude,
          ),
          //icon: BitmapDescriptor.fromBytes(markerIcon),
          icon: destinationIcon,
          infoWindow: InfoWindow(title: storeModel.name),
          onTap: () {
            setState(() {
              // showAvailableReservations = true;
              showReservationsInfo = !showReservationsInfo;
              showTravelData = !showTravelData;
            });
          });
      Marker offsetMarker = Marker(
        markerId: MarkerId('offset${storeModel.id}'),
        position: LatLng(
          storeModel.latitude,
          storeModel.longitude,
        ),
        anchor: Offset(0.5, -0.2),
        /*infoWindow: InfoWindow(
            title: store.name,
            snippet: store.address,
          ),*/
        onTap: () => giveMeAvailableTimes(currentStore),
        icon: BitmapDescriptor.fromBytes(markerIcon),
      );
      // Destination Location Marker
      setState(() {
        markers.removeWhere(
            (element) => element.markerId == MarkerId(storeModel.id));
        markers.removeWhere((element) =>
            element.markerId == MarkerId("offset" + storeModel.id));
        markers.add(offsetMarker);
        markers.add(newMarker);
      });

      // Adding the markers to the list

      print('START COORDINATES: $startCoordinates');
      print(
          'DESTINATION COORDINATES: ${storeModel.latitude},${storeModel.longitude}');

      Position _northeastCoordinates;
      Position _southwestCoordinates;

      // Calculating to check that
      // southwest coordinate <= northeast coordinate
      // Calculating to check that
// southwest coordinate <= northeast coordinate
      Position destinationCoordinates = new Position(
          latitude: storeModel.latitude, longitude: storeModel.longitude);
      if (startCoordinates.latitude <= destinationCoordinates.latitude) {
        _southwestCoordinates = startCoordinates;
        _northeastCoordinates = destinationCoordinates;
      } else {
        _southwestCoordinates = destinationCoordinates;
        _northeastCoordinates = startCoordinates;
      }

      print("southWest" + _southwestCoordinates.toJson().toString());
      print("NorthEast" + _northeastCoordinates.toJson().toString());

// Accommodate the two locations within the
// camera view of the map
      mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            northeast: LatLng(
              _southwestCoordinates.latitude,
              _southwestCoordinates.longitude,
            ),
            southwest: LatLng(
              _northeastCoordinates.latitude,
              _northeastCoordinates.longitude,
            ),
          ),
          100.0, // padding
        ),
      );
      /* mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(storeModel.latitude, storeModel.longitude),
              zoom: 15.0,
              bearing: 75),
        ),
      );*/

      // Accomodate the two locations within the
      // camera view of the map

      // Calculating the distance between the start and the end positions
      // with a straight path, without considering any route
      // double distanceInMeters = await Geolocator().bearingBetween(
      //   startCoordinates.latitude,
      //   startCoordinates.longitude,
      //   destinationCoordinates.latitude,
      //   destinationCoordinates.longitude,
      // );

      await _createPolylines(startCoordinates, destinationCoordinates);

      double totalDistance = 0.0;

      // Calculating the total distance by adding the distance
      // between small segments
      for (int i = 0; i < polylineCoordinates.length - 1; i++) {
        totalDistance += _coordinateDistance(
          polylineCoordinates[i].latitude,
          polylineCoordinates[i].longitude,
          polylineCoordinates[i + 1].latitude,
          polylineCoordinates[i + 1].longitude,
        );
      }

      setState(() {
        _placeDistance = totalDistance.toStringAsFixed(2);
        showTravelData = true;
        var fos = new DateFormat.jm();

        loading = false;
        if (travelMode == TravelMode.walking) {
          _remainingTime = ((totalDistance / 7) * 60).round().toInt();
          DateTime arrival =
              DateTime.now().add(Duration(minutes: _remainingTime));
          _arrivalTime = fos.format(arrival);
          print("total " + totalDistance.toString());
        } else {
          _remainingTime = ((totalDistance / 50) * 60).round().toInt();
          DateTime arrival =
              DateTime.now().add(Duration(minutes: _remainingTime));
          _arrivalTime = fos.format(arrival);
        }
        if (_remainingTime < 1)
          setState(() {
            _remainingTime = 1;
            DateTime arrival =
                DateTime.now().add(Duration(minutes: _remainingTime));
            _arrivalTime = fos.format(arrival);
          });

        /*  if (comprobationFinished) {
            for (var i = 0; i < horariosDisponibles.length; i++) {
              setState(() {
                if (DateTime.now()
                        .difference(horariosDisponibles[i].dateTime)
                        .inMinutes <
                    _remainingTime) {
                  horariosDisponibles.removeAt(i);
                }
              });
            }
          }*/
        print('REMAINING: $_remainingTime km');
        print('DISTANCE: $_placeDistance km');
      });

      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  simulateRoutes() async {
    print("simualste?" + polylineCoordinates.length.toString());
    CameraPosition cPosition = CameraPosition(
      zoom: 18,
      target: LatLng(polylineCoordinates[simulatePosition].latitude,
          polylineCoordinates[simulatePosition].longitude),
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));

    setState(() {
      var pinPosition = LatLng(polylineCoordinates[simulatePosition].latitude,
          polylineCoordinates[simulatePosition].longitude);
      markers.removeWhere((m) => m.markerId.value == 'simulatePin');
      markers.add(Marker(
          markerId: MarkerId('simulatePin'),
          onTap: () {
            setState(() {
              //pinPillPosition = 0;
            });
          },
          position: pinPosition,
          anchor: Offset(0.5, 0.5),
          rotation: simulateBearing,
          icon: destinationIcon));
      simulatePosition++;
    });
  }

  // Formula for calculating distance between two coordinates
  // https://stackoverflow.com/a/54138876/11910277
  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  // Create the polylines for showing the route between two places
  _createPolylines(Position start, Position destination) async {
    polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyAE5AzL0hosNySVTjx2Hvlxq26H7E8Mb-Q", // Google Maps API Key
      PointLatLng(start.latitude, start.longitude),
      PointLatLng(destination.latitude, destination.longitude),
      travelMode: travelMode,
    );
    print("Resultado coordenadas:" + result.errorMessage);

    if (result.points.isNotEmpty) {
      setState(() {
        result.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });

        PolylineId id = PolylineId('poly');
        Polyline polyline = Polyline(
          polylineId: id,
          color: widget.mapType == MapTypes.REGULAR ? Colors.red : Colors.white,
          points: polylineCoordinates,
          width: 8,
        );
        polylines[id] = polyline;
      });
      /* Timer.periodic(
          Duration(seconds: 5),
          (Timer t) => simulatePosition > 0
              ? Geolocator()
                  .bearingBetween(
                      polylineCoordinates[simulatePosition - 1].latitude,
                      polylineCoordinates[simulatePosition - 1].longitude,
                      polylineCoordinates[simulatePosition].latitude,
                      polylineCoordinates[simulatePosition].longitude)
                  .then((value) {
                  if (simulatePosition == polylineCoordinates.length) {
                    t.cancel();
                  }
                  setState(() {
                    simulateBearing = value;
                    print("este es el bearing: " + value.toString());
                    simulateRoutes();
                  });
                })
              : simulateRoutes());*/
    }
  }

  void confirmationReservationDialog(context, title, text) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          contentPadding: EdgeInsets.all(10),
          titlePadding: EdgeInsets.all(0),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Container(
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              //color: Colors.indigo
            ),
            child: Center(
                child: Text(LocalizationsKE.of(context).booked,
                    style: TextStyle(color: Colors.indigo, fontSize: 25))),
          ),
          content: Container(
            height: MediaQuery.of(context).size.height / 4,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(LocalizationsKE.of(context).entry,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        )),
                    Text(
                      text,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      currentStore.name,
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 15,
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 2 - 40,
                      child: AutoSizeText(
                        currentStore.address,
                        maxLines: 3,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Center(
                  child: Container(
                    // width: 120,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.indigo),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        startRoute();
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Center(
                            child: AutoSizeText(
                          LocalizationsKE.of(context).navegar,
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        )),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  void deleteStore(context, String id) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          contentPadding: EdgeInsets.all(10),
          titlePadding: EdgeInsets.all(0),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Container(
            height: 50,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                color: Colors.indigo),
            child: Center(
                child: Text(
              "Vitual KE",
              style: TextStyle(color: Colors.white),
            )),
          ),
          content: Container(
            height: MediaQuery.of(context).size.height / 5,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Desea eliminar esta tienda?",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15), color: Colors.grey),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Center(
                      child: Text(
                    LocalizationsKE.of(context).cancelar,
                    style: TextStyle(color: Colors.white),
                  )),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15), color: Colors.red),
              child: GestureDetector(
                onTap: () => apiCalls.deleteStore(id).then((value) {
                  getStores();
                  Navigator.pop(context);
                }),
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Center(
                      child: Text(
                    LocalizationsKE.of(context).aceptar,
                    style: TextStyle(color: Colors.white),
                  )),
                ),
              ),
            ),
          ],
        ),
      );

  void createStore(context, double latitude, double longitude) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          contentPadding: EdgeInsets.all(10),
          titlePadding: EdgeInsets.all(0),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Container(
            height: 50,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                color: Colors.indigo),
            child: Center(
                child: Text(
              "Vitual KE",
              style: TextStyle(color: Colors.white),
            )),
          ),
          content: Container(
            height: MediaQuery.of(context).size.height - 100,
            width: MediaQuery.of(context).size.width,
            child: CreateStore(
              latitude: latitude,
              longitude: longitude,
              direccion: _currentAddress,
            ),
          ),
        ),
      ).then((value) {
        setState(() {
          markers.clear();
        });
        getStores();
      });

  getAvailabeReservations(Map<String, dynamic> query) {
    /* Map<String, dynamic> query = {
        "idStore": currentStore.id,
        "idUser": _auth.currentUser.user.id,
        "day": horariosDisponibles[currentPosition].dateTime
      };*/
    apiCalls.getReservations(query: query).then((value) {
      setState(() {
        reservationRepository = ReservationRepository.fromJson(value);
      });
    });
  }

  giveMeAvailableTimes(StoreModel store) {
    print("give me available");
    setState(() {
      loading = true;
      showTravelData = false;
      comprobationFinished = false;
    });
    DateTime open = DateTime.parse(store.openAt).toUtc();
    bool storeClose = false;
    int pos = 0;
    DateTime close = DateTime.parse(store.closedAt).toUtc();
    close = new DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        close.hour,
        close.minute,
        close.second,
        close.millisecond,
        close.microsecond);
    setState(() {
      horariosDisponibles.clear();
    });
    print(close.toIso8601String());
    if (DateTime.now().hour > close.hour) {
      currentStoreClose = true;
    } else if (DateTime.now().hour == close.hour &&
        DateTime.now().minute > close.minute) {
      currentStoreClose = true;
    } else {
      currentStoreClose = false;
    }
    var fos = new DateFormat.jm();
    String hour = fos.format(close);
    String openhour = fos.format(open);
    String distance = "";
    DateTime foo = open;
    foo = new DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        foo.hour,
        foo.minute,
        foo.second,
        foo.millisecond,
        foo.microsecond);
    while (foo.isBefore(close)) {
      String hour2 = fos.format(foo);
      DateTime until = foo.add(Duration(minutes: store.estimateMinutes));
      String untilhour = fos.format(until);
      DateAux dateAux = new DateAux(text: hour2, dateTime: foo);
      print(hour2);
      if (foo.hour > DateTime.now().hour) {
        print("hora mayor");
        horariosDisponibles.add(dateAux);
      } else if (foo.hour == DateTime.now().hour) {
        if (foo.minute > DateTime.now().minute)
          horariosDisponibles.add(dateAux);
      }

      foo = until;
    }
    if (!currentStoreClose) {
      Map<String, dynamic> query = {
        "idStore": store.id,
        "idUser": _auth.currentUser.user.id,
        "day": DateTime.now()
      };
      apiCalls.getReservations(query: query).then((value) {
        setState(() {
          int a = 0;
          reservationRepository = ReservationRepository.fromJson(value);

          loading = false;
          for (var i = 0; i < horariosDisponibles.length; i++) {
            for (int i = 0;
                i < reservationRepository.reservations.length;
                i++) {
              DateTime d =
                  DateTime.parse(reservationRepository.reservations[i].date)
                      .toUtc();
              if (d.toLocal() == horariosDisponibles[i].dateTime.toLocal()) {
                a++;
              }
            }
            int remaining = currentStore.bunchClients - a;
            if (remaining <= 0) {
              setState(() {
                horariosDisponibles.removeAt(i);
              });
            } else {
              break;
            }
          }
          setState(() {
            /* if (_remainingTime != null)
              for (var i = 0; i < horariosDisponibles.length; i++) {
                if (DateTime.now()
                        .difference(horariosDisponibles[i].dateTime)
                        .inMinutes <
                    _remainingTime) {
                  horariosDisponibles.removeAt(i);
                }
              }*/
            comprobationFinished = true;
          });
        });
      });
    } else {
      setState(() {
        comprobationFinished = true;
        loading = false;
      });
    }
  }

  selectReservationDialog(context, StoreModel store) {
    print("mierda");
    DateTime open = DateTime.parse(store.openAt).toUtc();
    bool storeClose = false;
    int pos = 0;
    DateTime close = DateTime.parse(store.closedAt).toUtc();
    close = new DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        close.hour,
        close.minute,
        close.second,
        close.millisecond,
        close.microsecond);
    print(close.toIso8601String());
    if (DateTime.now().hour > close.hour) {
      storeClose = true;
    } else if (DateTime.now().hour == close.hour &&
        DateTime.now().minute > close.minute) {
      storeClose = true;
    }
    var fos = new DateFormat.jm();
    String hour = fos.format(close);
    String openhour = fos.format(open);
    String distance = "";
    DateTime foo = open;
    foo = new DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        foo.hour,
        foo.minute,
        foo.second,
        foo.millisecond,
        foo.microsecond);
    List<DateAux> availableTimes = new List();
    while (foo.isBefore(close)) {
      String hour2 = fos.format(foo);
      DateTime until =
          foo.add(Duration(minutes: store.estimateMinutes)).toUtc();
      String untilhour = fos.format(until);
      DateAux dateAux = new DateAux(text: hour2, dateTime: foo);
      print(hour2);
      if (foo.hour > DateTime.now().hour) {
        print("hora mayor");
        availableTimes.add(dateAux);
      } else if (foo.hour == DateTime.now().hour) {
        if (foo.minute > DateTime.now().minute) availableTimes.add(dateAux);
      }

      foo = until;
    }

    /*  for (var i = 0; i < availableTimes.length; i++) {
      Map<String, dynamic> query = {
        "idStore": store.id,
        "idUser": _auth.currentUser.user.id,
        "day": availableTimes[i].dateTime
      };

      if(reservationRepository!=null){
      if (store.bunchClients - getAvailabeReservations(query) > 0) {
        pos = i;
        break;
      }
      }
    }*/

    print(availableTimes.length);
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: EdgeInsets.all(0),
        contentPadding: EdgeInsets.all(10),
        titlePadding: EdgeInsets.all(0),
        elevation: 0,
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setBottom) {
          return Container(
            //  height: MediaQuery.of(context).size.height / 2,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    children: [
                      Container(
                          height: MediaQuery.of(context).size.height / 5,
                          child: Image.asset("assets/images/shopping.png")),
                      Container(
                          padding: EdgeInsets.all(10),
                          height: MediaQuery.of(context).size.height / 5,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                width:
                                    MediaQuery.of(context).size.width / 2 - 20,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AutoSizeText(
                                      store.name,
                                      maxLines: 1,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AutoSizeText(
                                          "Prochaine entree",
                                          maxLines: 1,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        availableTimes.length > 0
                                            ? AutoSizeText(
                                                DateFormat.MMMEd(
                                                            LocalizationsKE.of(
                                                                    context)
                                                                .locale
                                                                .toString())
                                                        .format(
                                                            availableTimes[pos]
                                                                .dateTime) +
                                                    "- ${availableTimes[0].text}",
                                                maxLines: 1,
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )
                                            : AutoSizeText("Hast manana")
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                height: MediaQuery.of(context).size.height / 8,
                                width:
                                    MediaQuery.of(context).size.width / 2 - 20,
                                padding: EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: storeClose
                                        ? Colors.red
                                        : Colors.blue[200]),
                                child: Center(
                                  child: Icon(
                                    storeClose
                                        ? CupertinoIcons.lock
                                        : Icons.storefront,
                                    color: Colors.white,
                                    size: 60,
                                  ),
                                ),
                              ),
                            ],
                          ))
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Stack(
                  children: [
                    Center(
                      child: Align(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            bottomSheetStores(context, null);
                          },
                          child: Container(
                            height: 80,
                            width: MediaQuery.of(context).size.width / 2,
                            margin: EdgeInsets.only(left: 40, right: 40),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [Colors.indigo, Colors.blue],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter),
                              border:
                                  Border.all(color: Colors.black, width: 0.0),
                              borderRadius:
                                  BorderRadius.all(Radius.elliptical(120, 50)),
                            ),
                            child: Center(
                                child: Text('Planifier',
                                    style: TextStyle(color: Colors.white))),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 20,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 40,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10)),
                          child: Center(
                              child: Text(
                            LocalizationsKE.of(context).cancelar,
                            style: TextStyle(color: Colors.white),
                          )),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 20,
                      child: GestureDetector(
                        onTap: () {
                          apiCalls
                              .createReservation(
                                  store.id,
                                  _auth.user.user.id.toString(),
                                  store.name,
                                  availableTimes[0].dateTime.toUtc().toString(),
                                  1)
                              .then((value) {
                            DateTime reservation =
                                DateTime.parse(value['date']).toLocal();
                            DateAux aux =
                                DateAux(text: "SUCCESS", dateTime: reservation);
                            Navigator.pop(context, aux);
                            Duration differenceTo = reservation.difference(
                                DateTime.now().subtract(Duration(minutes: 1)));
                            print(differenceTo.toString());
                            notifications.scheduleNotification(
                              id: value['_id'],
                              title: LocalizationsKE.of(context).recuerda,
                              body: LocalizationsKE.of(context)
                                      .recordatorioreserva +
                                  store.name +
                                  LocalizationsKE.of(context).alas +
                                  reservation.hour.toString() +
                                  ":" +
                                  reservation.minute.toString() +
                                  ".",
                              duration: differenceTo,
                            );
                          });
                        },
                        child: Container(
                          height: 40,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: storeClose ? Colors.grey : Colors.green,
                              borderRadius: BorderRadius.circular(10)),
                          child: Center(
                              child: Text(
                            LocalizationsKE.of(context).reservar,
                            style: TextStyle(color: Colors.white),
                          )),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          );
        }),
      ),
    );
  }

  createReservations(DateTime time) {
    setState(() {
      loading = true;
    });
    apiCalls
        .createReservation(currentStore.id, _auth.user.user.id.toString(),
            currentStore.name, time.toUtc().toString(), 1)
        .then((value) {
      setState(() {
        loading = false;
        comprobationFinished = false;
      });
      if (value != null) {
        DateTime reservation = DateTime.parse(value['date']).toLocal();
        DateAux aux = DateAux(text: "SUCCESS", dateTime: reservation);

        Duration differenceTo = reservation
            .difference(DateTime.now().subtract(Duration(minutes: 1)));
        print(differenceTo.toString());
        notifications.scheduleNotification(
          id: value['_id'],
          title: LocalizationsKE.of(context).recuerda,
          body: LocalizationsKE.of(context).recordatorioreserva +
              currentStore.name +
              LocalizationsKE.of(context).alas +
              reservation.hour.toString() +
              ":" +
              reservation.minute.toString() +
              ".",
          duration: differenceTo,
        );
        /*Navigator.pop(
                                                                        context,
                                                                        aux);*/
        setState(() {
          showAvailableReservations = false;
          //horariosDisponibles = new List();
          var formatter = new DateFormat('dd/MM/yyyy');
          var fos = new DateFormat.jm();
          String hour = fos.format(reservation);
          String date = formatter.format(reservation);
          confirmationReservationDialog(context, "", "$hour");
        });
      } else {
        confirmationReservationDialog(context, "ERROR", "");
      }
    });
  }

  int availableByDate(DateTime thisDate) {
    int a = 0;
    print("currentTime: " + thisDate.toString());

    for (int i = 0; i < reservationRepository.reservations.length; i++) {
      DateTime d =
          DateTime.parse(reservationRepository.reservations[i].date).toUtc();
      print("Reservations: " + d.toString());
      if (d.toLocal() == thisDate.toLocal()) {
        a++;
      }
    }

    return a;
  }

  void setMarkerIcons() async {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: 2.0),
            //"assets/images/storePin_${widget.language}.png")
            widget.mapType == MapTypes.REGULAR
                ? 'assets/images/pinmapKe.png'
                : 'assets/images/pinmapKeWhite.png')
        .then((onValue) {
      setState(() {
        storeIcon = onValue;
      });
    });
    BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.0),
            'assets/images/taxipin2.png')
        .then((onValue) {
      setState(() {
        sourceIcon2 = onValue;
      });
    });
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: 2.0),
            widget.mapType == MapTypes.REGULAR
                ? 'assets/images/YourHerePinWhite.png'
                : 'assets/images/YourHerePin.png')
        .then((onValue) {
      setState(() {
        currentLocationIcon = onValue;
      });
    });
    /*BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.0),
            'assets/images/goalyellow.png')
        .then((onValue) {
      setState(() {
        destinationIcon = onValue;
      });
    });*/
    /* BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.0),
            'assets/images/goalindigo.png')
        .then((onValue) {
      setState(() {
        destinationIcon = onValue;
      });
    });*/
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: 2.0),
            widget.mapType == MapTypes.REGULAR
                ? 'assets/images/pinmapKe.png'
                : 'assets/images/pinmapKeWhite.png')
        .then((onValue) {
      setState(() {
        destinationIcon = onValue;
      });
    });
    /*BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.0),
            'assets/images/flag.png')
        .then((onValue) {
      setState(() {
        destinationIcon = onValue;
      });
    });*/
  }

  addStoreMarker(StoreModel store) async {
    final Uint8List markerIcon = await getBytesFromCanvas(200, 60);
    setState(() {
      _remainingTime = null;
      Marker startMarker = Marker(
        markerId: MarkerId('${store.id}'),
        position: LatLng(
          store.latitude,
          store.longitude,
        ),
        infoWindow: InfoWindow(
          title: store.name,
          snippet: store.address,
        ),
        icon: storeIcon,
        draggable: true,
        onDragEnd: (value) {
          deleteStore(context, store.id);
        },
        /*  onTap: () {
            //bottomSheetStores(context, store);
            mapController.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: LatLng(store.latitude, store.longitude),
                  zoom: 18,
                ),
              ),
            );
            cleanMarkers();
            setState(() {
              loading = true;
              selectedMarkerId = store;
            });
            giveMeAvailableTimes(store);
            _calculateDistance(_currentPosition, store);
          }
          */
      );
      Marker offsetMarker = Marker(
          markerId: MarkerId('offset${store.id}'),
          position: LatLng(
            store.latitude,
            store.longitude,
          ),
          anchor: Offset(0.5, -0.2),
          /*infoWindow: InfoWindow(
            title: store.name,
            snippet: store.address,
          ),*/
          icon: BitmapDescriptor.fromBytes(markerIcon),
          draggable: true,
          onDragEnd: (value) {
            deleteStore(context, store.id);
          },
          onTap: () {
            //bottomSheetStores(context, store);
            mapController.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: LatLng(store.latitude, store.longitude),
                  zoom: 18,
                ),
              ),
            );
            cleanMarkers();
            setState(() {
              loading = true;
              selectedMarkerId = store;
              currentStore = store;
            });
            // giveMeAvailableTimes(store);
            _calculateDistance(_currentPosition, store);
          });
      markers.add(startMarker);
      markers.add(offsetMarker);
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    _auth = Provider.of<AuthServices>(context);
    _utils = Provider.of<UtilsProvider>(context);
    CurrentPositionProvider _current =
        Provider.of<CurrentPositionProvider>(context);
    if (_current.showCurrent()) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _getCurrentLocation();
        _current.setCurrent(false);
      });
    }
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        body: Container(
            height: MediaQuery.of(context).size.height - 55,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                /*Image.asset(
                  "assets/images/maps.png",
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                ),*/
                GoogleMap(
                  markers: markers != null ? Set<Marker>.from(markers) : null,
                  initialCameraPosition: _initialLocation,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  mapType: MapType.normal,
                  mapToolbarEnabled: true,
                  zoomGesturesEnabled: true,
                  zoomControlsEnabled: false,
                  polylines: Set<Polyline>.of(polylines.values),
                  onMapCreated: (GoogleMapController controller) async {
                    mapController = controller;
                    if (_utils.showCurrent() != MapTypes.REGULAR) {
                      String style = await DefaultAssetBundle.of(context)
                          .loadString(_utils.showCurrent() == MapTypes.RED
                              ? "assets/maps/mapstyle.json"
                              : "assets/maps/mapstyleblue.json");
                      controller.setMapStyle(style);
                    }
                  },
                  onTap: (position) {
                    setState(() {
                      _placeDistance = "";
                      showTravelData = false;
                      comprobationFinished = false;
                      polylineCoordinates.clear();
                      cleanMarkers();
                    });
                  },
                  onLongPress: (position) async {
                    setState(() {
                      loading = true;
                    });
                    await _getAddress(position).then((value) {
                      setState(() {
                        loading = false;
                      });
                      createStore(
                          context, position.latitude, position.longitude);
                    });
                  },
                ),
                showfinding
                    ? Positioned(
                        child: RipplesAnimation(
                            color: _utils.showCurrent() == MapTypes.RED
                                ? Colors.red
                                : Colors.indigo,
                            child: Container()),
                      )
                    : Container(),
                showfinding
                    ? Positioned(
                        top: width / 2 - 90,
                        left: width / 2 - 90,
                        child: Container(
                          height: 180,
                          width: 180,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                          child: Column(
                            children: [
                              Image.asset(
                                "assets/images/KE-logo.png",
                                height: 100,
                                width: 100,
                              ),
                              Container(
                                  width: 120,
                                  //height: 20,
                                  padding: EdgeInsets.all(5),
                                  child: AutoSizeText(
                                    LocalizationsKE.of(context).keisfindingyou,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold),
                                  ))
                            ],
                          ),
                        ),
                      )
                    : Container(),
                AnimatedPositioned(
                  top: showfinding
                      ? MediaQuery.of(context).size.width - 20
                      : searchBarPosition,
                  duration: Duration(milliseconds: 200),
                  child: Container(
                      margin: EdgeInsets.only(right: 10, left: 10),
                      height: 75,
                      padding: EdgeInsets.only(left: 10),
                      width: MediaQuery.of(context).size.width - 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        color: _utils.showCurrent() == MapTypes.REGULAR
                            ? Colors.indigo
                            : Colors.white,
                      ),
                      child: Center(
                        child: TypeAheadField(
                          textFieldConfiguration: TextFieldConfiguration(
                              onTap: () => _typeAheadController.clear(),
                              controller: _typeAheadController,
                              style: TextStyle(color: Colors.black),
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(top: 22),
                                  hintText: searchBarPosition == 50
                                      ? ""
                                      : LocalizationsKE.of(context).search,
                                  hintStyle: TextStyle(
                                      fontSize: 25,
                                      color: _utils.showCurrent() ==
                                              MapTypes.REGULAR
                                          ? Colors.grey
                                          : Colors.grey),
                                  prefixIcon: Icon(Icons.search, size: 35),
                                  suffixIcon: Container(
                                    width: 100,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(40),
                                        color: Colors.blue),
                                    child: Center(
                                        child: AutoSizeText(
                                            LocalizationsKE.of(context).go,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 30))),
                                  ),
                                  border: InputBorder.none)),

                          //errorBuilder: (context, error) => Text("Error"),
                          hideSuggestionsOnKeyboardHide: false,
                          hideOnError: true,

                          loadingBuilder: (context) => Center(
                            child: CircularProgressIndicator(),
                          ),
                          suggestionsCallback: (pattern) {
                            setState(() {
                              searchBarPosition = 50;
                            });
                            if (pattern.length > 0) {
                              return repository.stores.where((element) =>
                                  element.name
                                      .toLowerCase()
                                      .contains(pattern.toLowerCase()));
                            }
                            return null;
                          },
                          itemBuilder: (context, suggestion) {
                            StoreModel store = suggestion;
                            bool storeClose = false;
                            String distance = "";
                            DateTime open =
                                DateTime.parse(store.openAt).toUtc();
                            DateTime close =
                                DateTime.parse(store.closedAt).toUtc();
                            if (DateTime.now().hour > close.hour) {
                              storeClose = true;
                            } else if (DateTime.now().hour == close.hour &&
                                DateTime.now().minute > close.minute) {
                              storeClose = true;
                            }
                            var fos = new DateFormat.jm();
                            String hour = fos.format(close);
                            String openhour = fos.format(open);
                            double dist = _coordinateDistance(
                                store.latitude,
                                store.longitude,
                                _currentPosition.latitude,
                                _currentPosition.longitude);
                            print("AQUI" + dist.toString());
                            dist *= 1000;
                            if (dist > 1000) {
                              print("Distancia: " + distance);
                              distance =
                                  (dist / 1000).toStringAsFixed(1) + "km";
                            } else {
                              distance = dist.floor().toString() + "m";
                            }
                            return store.distance < 20000
                                ? ListTile(
                                    leading: Container(
                                      height: 40,
                                      width: 40,
                                      padding: EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          color: storeClose
                                              ? Colors.red
                                              : Colors.blue[200]),
                                      child: Center(
                                        child: Icon(
                                          storeClose
                                              ? CupertinoIcons.lock
                                              : Icons.storefront,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    title: Text(suggestion.name != null
                                        ? suggestion.name
                                        : ""),
                                    subtitle: Container(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          AutoSizeText(store.address,
                                              maxLines: 1,
                                              style: TextStyle(
                                                  color: Colors.black)),
                                          AutoSizeText(
                                              '${LocalizationsKE.of(context).abierto} $openhour ${LocalizationsKE.of(context).to} $hour',
                                              maxLines: 1,
                                              style: TextStyle(
                                                  color: Colors.green)),
                                        ],
                                      ),
                                    ),
                                    trailing: Container(
                                      width: 60,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          AutoSizeText("Distancia",
                                              maxLines: 1),
                                          AutoSizeText(
                                            distance,
                                            maxLines: 1,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container();
                          },
                          onSuggestionSelected: (suggestion) {
                            String distance = "";
                            double dist = _coordinateDistance(
                                suggestion.latitude,
                                suggestion.longitude,
                                _currentPosition.latitude,
                                _currentPosition.longitude);
                            dist *= 1000;
                            if (dist > 1000) {
                              distance =
                                  (dist / 1000).toStringAsFixed(1) + "km";
                            } else {
                              distance = dist.floor().toString() + "m";
                            }
                            /* mapController.animateCamera(
                              CameraUpdate.newCameraPosition(
                                CameraPosition(
                                  target: LatLng(suggestion.latitude,
                                      suggestion.longitude),
                                  zoom: 18.0,
                                ),
                              ),
                            );*/
                            cleanMarkers();
                            setState(() {
                              _typeAheadController.text =
                                  suggestion.name + "  " + distance;
                              loading = true;
                              selectedMarkerId = suggestion;
                              currentStore = suggestion;
                              //markers.add(startMarker);
                              //markers.add(offsetMarker);
                            });
                            // giveMeAvailableTimes(store);
                            _calculateDistance(_currentPosition, suggestion)
                                .then((value) =>
                                    mapController.showMarkerInfoWindow(
                                        MarkerId('${currentStore.id}')));
                          },
                          hideOnEmpty: true,
                        ),
                      )),
                ),
                AnimatedPositioned(
                    top: comprobationFinished ? 50 : -500,
                    right: 5,
                    left: 5,
                    duration: Duration(milliseconds: 300),
                    child: Container(
                      //height: 100,
                      //padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.indigo),
                      child: currentStoreClose
                          ? Container(
                              child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      showAvailableReservations = false;
                                      horariosDisponibles = new List();
                                      _placeDistance = null;
                                      showTravelData = false;
                                      comprobationFinished = false;
                                    });
                                  },
                                  child: Container(
                                    child: Container(
                                      width: 80,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 2),
                                      decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(5))),
                                      child: Center(
                                        child: Icon(Icons.close_outlined,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 80,
                                  width: 80,
                                  padding: EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: Colors.red),
                                  child: Center(
                                    child: Icon(
                                      CupertinoIcons.lock,
                                      color: Colors.white,
                                      size: 60,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  LocalizationsKE.of(context).tiendacerrada,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                controlPlanificar(false)
                              ],
                            ))
                          : NextEntryPreview(
                              store: currentStore != null ? currentStore : null,
                              distance: _placeDistance != null
                                  ? _placeDistance + " KM"
                                  : "",
                              time: _remainingTime != null
                                  ? _remainingTime.toString() + " min"
                                  : "",
                              horariosDisponibles: comprobationFinished
                                  ? horariosDisponibles
                                  : null,
                              createReservation: createReservations,
                              travelMode: changeTravelMode,
                            ),
                      /* Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                    4 -
                                                20,
                                        child: Image.asset(
                                          "assets/images/supermarket.jpg",
                                          height: 60,
                                          width: 60,
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          currentStore != null
                                              ? Text(currentStore.name,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                  ))
                                              : Container(),
                                          comprobationFinished
                                              ? Container(
                                                  width: MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          2 -
                                                      20,
                                                  child: Text(
                                                    LocalizationsKE.of(context)
                                                            .proximaentrada +
                                                        horariosDisponibles[0]
                                                            .text +
                                                        "\n" +
                                                        LocalizationsKE.of(
                                                                context)
                                                            .disponibles +
                                                        (currentStore
                                                                    .bunchClients -
                                                                availableByDate(
                                                                    horariosDisponibles[
                                                                            0]
                                                                        .dateTime))
                                                            .toString(),
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                )
                                              : CircularProgressIndicator(),
                                          _placeDistance != null
                                              ? Text(
                                                  LocalizationsKE.of(context)
                                                          .distancia +
                                                      " " +
                                                      _placeDistance +
                                                      " KM",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                )
                                              : Container()
                                        ],
                                      ),
                                      Container(
                                              width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      4 -
                                                  20,
                                              child: Container(
                                                padding: EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      width: 4,
                                                      color: Colors.white),
                                                ),
                                                child: Center(
                                                    child: RichText(
                                                  text: TextSpan(children: [
                                                    TextSpan(
                                                      text: _remainingTime != null
                                          ? "  " +
                                                          _remainingTime
                                                              .toString():"  -",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    TextSpan(
                                                      text: "\nMIN",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ]),
                                                )),
                                              ),
                                            )
                                         
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            color:
                                                travelMode == TravelMode.walking
                                                    ? Colors.green
                                                    : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        child: IconButton(
                                            icon: Icon(Icons.directions_walk,
                                                color: Colors.white),
                                            onPressed: () {
                                              setState(() {
                                                travelMode = TravelMode.walking;
                                                _calculateDistance(
                                                    _currentPosition,
                                                    currentStore);

                                                PolylineId id =
                                                    PolylineId('poly');
                                                Polyline polyline = Polyline(
                                                  polylineId: id,
                                                  color: Colors.indigo,
                                                  points: polylineCoordinates,
                                                  width: 8,
                                                );
                                                polylines[id] = polyline;
                                              });
                                            }),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            color:
                                                travelMode == TravelMode.driving
                                                    ? Colors.green
                                                    : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        child: IconButton(
                                            icon: Icon(Icons.directions_bus,
                                                color: Colors.white),
                                            onPressed: () {
                                              setState(() {
                                                travelMode = TravelMode.driving;
                                                _calculateDistance(
                                                    _currentPosition,
                                                    currentStore);

                                                PolylineId id =
                                                    PolylineId('poly');
                                                Polyline polyline = Polyline(
                                                  polylineId: id,
                                                  color: Colors.indigo,
                                                  points: polylineCoordinates,
                                                  width: 8,
                                                );
                                                polylines[id] = polyline;
                                              });
                                            }),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          createReservations(
                                              horariosDisponibles[0].dateTime);
                                        },
                                        child: Container(
                                            width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2 -
                                                20,
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.green,
                                            ),
                                            child: Center(
                                              child: Text(
                                                  LocalizationsKE.of(context)
                                                      .reservar,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  )),
                                            )),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            showAvailableReservations = true;
                                          });
                                        },
                                        child: Container(
                                            width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2 -
                                                20,
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.blue,
                                            ),
                                            child: Center(
                                              child: AutoSizeText(
                                                  LocalizationsKE.of(context)
                                                      .otroshorarios,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  )),
                                            )),
                                      ),
                                    ],
                                  )
                                ],
                              )*/
                    )),
                currentStore != null
                    ? AnimatedPositioned(
                        bottom: showTravelData ? 60 : -100,
                        child: Container(
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(.15),
                                      offset: Offset(1, 1),
                                      blurRadius: 8,
                                      spreadRadius: 1)
                                ],
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15)),
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            padding: EdgeInsets.all(10),
                            width: MediaQuery.of(context).size.width - 20,
                            //height: 80,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(currentStore.name,
                                        style: TextStyle(
                                            color: Colors.blue, fontSize: 20)),
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width -
                                                90,
                                        child: AutoSizeText(
                                          currentStore.address,
                                          maxLines: 1,
                                        )),
                                    Text(LocalizationsKE.of(context)
                                            .arrivaltime +
                                        "$_arrivalTime")
                                  ],
                                ),
                                IconButton(
                                    icon: Container(
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius:
                                                BorderRadius.circular(4)),
                                        child: Icon(Icons.arrow_forward,
                                            color: Colors.white)),
                                    onPressed: () =>
                                        giveMeAvailableTimes(currentStore)),
                              ],
                            )),
                        duration: Duration(milliseconds: 300))
                    : Container(),
                showAvailableReservations
                    ? Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.black.withOpacity(0.5),
                        child: currentStoreClose
                            ? Container(
                                child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        showAvailableReservations = false;
                                        horariosDisponibles = new List();
                                      });
                                    },
                                    child: Container(
                                      child: Container(
                                        width: 80,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 5, vertical: 2),
                                        decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(5))),
                                        child: Center(
                                          child: Icon(Icons.close_outlined,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 80,
                                    width: 80,
                                    padding: EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: Colors.red),
                                    child: Center(
                                      child: Icon(
                                        CupertinoIcons.lock,
                                        color: Colors.white,
                                        size: 60,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    LocalizationsKE.of(context).tiendacerrada,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  controlPlanificar(false)
                                ],
                              ))
                            : horariosDisponibles.length == 0
                                ? Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : Container(
                                    height: MediaQuery.of(context).size.height,
                                    width: MediaQuery.of(context).size.width,
                                    //padding: EdgeInsets.symmetric(horizontal: 10),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              2,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: PageView.builder(
                                              itemCount:
                                                  horariosDisponibles.length,
                                              controller: _pageController,
                                              onPageChanged: (page) {
                                                setState(() {
                                                  currentPosition = page;
                                                });
                                              },
                                              itemBuilder: (context, index) {
                                                return Stack(
                                                  children: [
                                                    Container(
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 10),
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      20)),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Container(
                                                              child: Image.asset(
                                                                  "assets/images/shopping.png")),
                                                          Container(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(10),
                                                              child: Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceAround,
                                                                children: [
                                                                  Container(
                                                                    width: MediaQuery.of(context).size.width /
                                                                            2 -
                                                                        20,
                                                                    child:
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        AutoSizeText(
                                                                          currentStore
                                                                              .name,
                                                                          maxLines:
                                                                              1,
                                                                          style:
                                                                              TextStyle(fontWeight: FontWeight.bold),
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              20,
                                                                        ),
                                                                        Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            AutoSizeText(
                                                                              LocalizationsKE.of(context).proximaentrada,
                                                                              maxLines: 1,
                                                                              style: TextStyle(fontWeight: FontWeight.bold),
                                                                            ),
                                                                            horariosDisponibles.length > 0
                                                                                ? AutoSizeText(
                                                                                    DateFormat.MMMEd(LocalizationsKE.of(context).locale.toString()).format(horariosDisponibles[index].dateTime) + "- ${horariosDisponibles[index].text}",
                                                                                    maxLines: 1,
                                                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                                                  )
                                                                                : AutoSizeText("")
                                                                          ],
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  InkWell(
                                                                    onTap: () {
                                                                      apiCalls
                                                                          .createReservation(
                                                                              currentStore.id,
                                                                              _auth.user.user.id.toString(),
                                                                              currentStore.name,
                                                                              horariosDisponibles[index].dateTime.toUtc().toString(),
                                                                              1)
                                                                          .then((value) {
                                                                        if (value !=
                                                                            null) {
                                                                          DateTime
                                                                              reservation =
                                                                              DateTime.parse(value['date']).toLocal();
                                                                          DateAux
                                                                              aux =
                                                                              DateAux(text: "SUCCESS", dateTime: reservation);

                                                                          Duration
                                                                              differenceTo =
                                                                              reservation.difference(DateTime.now().subtract(Duration(minutes: 1)));
                                                                          print(
                                                                              differenceTo.toString());
                                                                          notifications
                                                                              .scheduleNotification(
                                                                            id: value['_id'],
                                                                            title:
                                                                                LocalizationsKE.of(context).recuerda,
                                                                            body: LocalizationsKE.of(context).recordatorioreserva +
                                                                                currentStore.name +
                                                                                LocalizationsKE.of(context).alas +
                                                                                reservation.hour.toString() +
                                                                                ":" +
                                                                                reservation.minute.toString() +
                                                                                ".",
                                                                            duration:
                                                                                differenceTo,
                                                                          );
                                                                          /*Navigator.pop(
                                                                        context,
                                                                        aux);*/
                                                                          setState(
                                                                              () {
                                                                            showAvailableReservations =
                                                                                false;
                                                                            /*horariosDisponibles =
                                                                                new List();*/
                                                                            var formatter =
                                                                                new DateFormat('dd/MM/yyyy');
                                                                            var fos =
                                                                                new DateFormat.jm();
                                                                            String
                                                                                hour =
                                                                                fos.format(reservation);
                                                                            String
                                                                                date =
                                                                                formatter.format(reservation);
                                                                            confirmationReservationDialog(
                                                                                context,
                                                                                "",
                                                                                "${LocalizationsKE.of(context).reservationsuccess} $date - $hour.");
                                                                          });
                                                                        } else {
                                                                          confirmationReservationDialog(
                                                                              context,
                                                                              "ERROR",
                                                                              "");
                                                                        }
                                                                      });
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              10),
                                                                      decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.circular(
                                                                              4),
                                                                          color:
                                                                              Colors.green[400]),
                                                                      child:
                                                                          Column(
                                                                        children: [
                                                                          Icon(
                                                                            Icons.check_circle_outline,
                                                                            color:
                                                                                Colors.white,
                                                                            size:
                                                                                60,
                                                                          ),
                                                                          Text(
                                                                            LocalizationsKE.of(context).reservar,
                                                                            style:
                                                                                TextStyle(color: Colors.white),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ))
                                                        ],
                                                      ),
                                                    ),
                                                    Positioned(
                                                      top: 5,
                                                      right: 15,
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            showAvailableReservations =
                                                                false;
                                                            /* horariosDisponibles =
                                                                new List();*/
                                                          });
                                                        },
                                                        child: Container(
                                                          height: 40,
                                                          width: 40,
                                                          decoration: BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .black,
                                                                  width: 3),
                                                              color: Colors
                                                                  .indigo),
                                                          child: Center(
                                                            child: Icon(
                                                                Icons
                                                                    .close_outlined,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                );
                                              }),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        controlPlanificar(true),
                                      ],
                                    ),
                                  ),
                      )
                    : Container(),
                Positioned(
                  top: 10,
                  left: 20,
                  child: showTravelData || comprobationFinished
                      ? IconButton(
                          icon: Icon(Icons.arrow_back,
                              color: Colors.white, size: 30),
                          onPressed: () {
                            setState(() {
                              _typeAheadController.clear();
                              _placeDistance = "";
                              showTravelData = false;
                              comprobationFinished = false;
                              polylineCoordinates.clear();
                              cleanMarkers();
                            });
                          })
                      : Container(),
                ),
                loading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : Container(),
              ],
            )),
      ),
    );
  }

  Widget controlPlanificar(bool showControl) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: Stack(
        children: [
          Center(
            child: Align(
              child: GestureDetector(
                onTap: () {
                  //Navigator.pop(context);
                  bottomSheetStores(context, currentStore);
                },
                child: Container(
                  height: 80,
                  width: MediaQuery.of(context).size.width / 2,
                  margin: EdgeInsets.only(left: 40, right: 40),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.indigo, Colors.blue],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter),
                    borderRadius: BorderRadius.all(Radius.elliptical(120, 50)),
                  ),
                  child: Center(
                      child: Text(LocalizationsKE.of(context).planificar,
                          style: TextStyle(color: Colors.white))),
                ),
              ),
            ),
          ),
          showControl
              ? Positioned(
                  left: 0,
                  top: 20,
                  child: GestureDetector(
                    onTap: () => _pageController.animateToPage(
                        currentPosition - 1,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.ease),
                    child: Container(
                      height: 40,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(
                          child: Text(
                        LocalizationsKE.of(context).anterior,
                        style: TextStyle(color: Colors.white),
                      )),
                    ),
                  ),
                )
              : Container(),
          showControl
              ? Positioned(
                  right: 0,
                  top: 20,
                  child: GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(currentPosition + 1,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.ease);
                    },
                    child: Container(
                      height: 40,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(
                          child: Text(
                        LocalizationsKE.of(context).siguiente,
                        style: TextStyle(color: Colors.white),
                      )),
                    ),
                  ),
                )
              : Container()
        ],
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    //mapController.dispose();
    super.dispose();
  }

  void bottomSheetStores(BuildContext context, StoreModel thisStore) {
    var res = showModalBottomSheet(
        isScrollControlled: true,
        barrierColor: Colors.transparent,
        isDismissible: true,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(40.0)),
        ),
        enableDrag: true,
        context: context,
        backgroundColor: Colors.white,
        builder: (BuildContext bc) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setBottom) {
            return Container(
              child: GestureDetector(
                onVerticalDragStart: (_) {},
                child: Container(
                    //padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                    /*height: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).size.height / 5,*/
                    height: MediaQuery.of(context).size.height - 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Stack(
                          children: [
                            IgnorePointer(
                              ignoring: true,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.indigo,
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(40.0)),
                                  /* image: DecorationImage(
                                image: AssetImage("assets/images/selectdate.png")
                              )*/
                                ),
                              ),
                            ),
                            Positioned(
                              top: 35,
                              left: 20,
                              child: Text(
                                LocalizationsKE.of(context).reservar,
                                style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                            Positioned(
                                top: 20,
                                right: 20,
                                child: Container(
                                  child: IconButton(
                                      icon: Icon(
                                        CupertinoIcons.arrow_down_circle_fill,
                                        size: 40,
                                        color: Colors.white,
                                      ),
                                      onPressed: () => Navigator.pop(context)),
                                ))
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        repository != null
                            ? thisStore != null
                                ? Container()
                                : Center(
                                    child: Text(
                                    repository.stores.length.toString() +
                                        " " +
                                        LocalizationsKE.of(context).tiendas,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ))
                            : Center(
                                child: CircularProgressIndicator(),
                              ),
                        Expanded(
                            child: repository != null
                                ? Container(
                                    margin: EdgeInsets.only(top: 20),
                                    child: ListView.builder(
                                        physics: BouncingScrollPhysics(),
                                        itemCount: thisStore != null
                                            ? 1
                                            : repository.stores.length,
                                        itemBuilder: (context, index) {
                                          bool storeClose = false;
                                          DateTime thisDate;
                                          StoreModel store = thisStore != null
                                              ? thisStore
                                              : repository.stores[index];
                                          DateTime open =
                                              DateTime.parse(store.openAt)
                                                  .toUtc();

                                          DateTime close =
                                              DateTime.parse(store.closedAt)
                                                  .toUtc();
                                          if (DateTime.now().hour >
                                              close.hour) {
                                            storeClose = true;
                                          } else if (DateTime.now().hour ==
                                                  close.hour &&
                                              DateTime.now().minute >
                                                  close.minute) {
                                            storeClose = true;
                                          }
                                          var fos = new DateFormat.jm();
                                          String hour = fos.format(close);
                                          String openhour = fos.format(open);
                                          String distance = "";
                                          DateTime foo = open;
                                          close = new DateTime(
                                              currentTime.year,
                                              currentTime.month,
                                              currentTime.day,
                                              close.hour,
                                              close.minute,
                                              close.second,
                                              close.millisecond,
                                              close.microsecond);
                                          foo = new DateTime(
                                              currentTime.year,
                                              currentTime.month,
                                              currentTime.day,
                                              foo.hour,
                                              foo.minute,
                                              foo.second,
                                              foo.millisecond,
                                              foo.microsecond);
                                          List<DateAux> availableTimes =
                                              new List();
                                          while (foo.isBefore(close)) {
                                            String hour2 = fos.format(foo);
                                            /*print("HORAA: " +
                                                foo.hour.toString());
                                            print("AHORAAA: " +
                                                DateTime.now().hour.toString());*/
                                            DateTime until = foo.add(Duration(
                                                minutes:
                                                    store.estimateMinutes));
                                            String untilhour =
                                                fos.format(until);
                                            DateAux dateAux = new DateAux(
                                                text: hour2, dateTime: foo);
                                            /*  if (foo.year ==
                                                    DateTime.now().year &&
                                                foo.month ==
                                                    DateTime.now().month &&
                                                foo.day == DateTime.now().day) {
                                              print("IS EQUAL");
                                              if (foo.hour >
                                                  DateTime.now().hour) {
                                                availableTimes.add(dateAux);
                                              } else if (foo.hour ==
                                                  DateTime.now().hour) {
                                                if (foo.minute >
                                                    DateTime.now().minute)
                                                  availableTimes.add(dateAux);
                                              }
                                              /*else {
                                                availableTimes.add(dateAux);
                                              }*/
                                            } else {
                                              print("IS NOT EQUAL");
*/
                                            availableTimes.add(dateAux);
                                            //}
                                            foo = until;
                                          }
                                          /*   if (!(foo.year ==
                                                  DateTime.now().year &&
                                              foo.month ==
                                                  DateTime.now().month &&
                                              foo.day == DateTime.now().day)) {
                                                print("set new ");
                                            currentTime = new DateTime(
                                              currentTime.year,
                                              currentTime.month,
                                              currentTime.day,
                                              availableTimes[0].dateTime.hour,
                                              availableTimes[0].dateTime.minute,
                                              availableTimes[0].dateTime.second,
                                            );
                                          }*/

                                          double dist = _coordinateDistance(
                                              store.latitude,
                                              store.longitude,
                                              _currentPosition.latitude,
                                              _currentPosition.longitude);
                                          print(dist);
                                          if (dist > 1000) {
                                            print("Distancia: " + distance);
                                            distance = (dist / 1000)
                                                    .toStringAsFixed(1) +
                                                "km";
                                          } else {
                                            dist *= 1000;
                                            distance =
                                                dist.floor().toString() + "m";
                                          }
                                          /* if (thisDate == null ||
                                              (thisDate.month ==
                                                      DateTime.now().month &&
                                                  thisDate.day ==
                                                      DateTime.now().day)) {
                                            if (close.hour >
                                                DateTime.now().hour) {
                                              print("OPEN: " + foo.toString());
                                              while (foo.isBefore(close)) {
                                                String hour2 = fos.format(foo);
                                                print("HORAA: " +
                                                    foo.hour.toString());
                                                print("AHORAAA: " +
                                                    DateTime.now()
                                                        .hour
                                                        .toString());
                                                DateTime until = foo.add(
                                                    Duration(
                                                        minutes: store
                                                            .estimateMinutes));
                                                String untilhour =
                                                    fos.format(until);
                                                DateAux dateAux = new DateAux(
                                                    text: hour2, dateTime: foo);
                                                if (foo.hour >
                                                    DateTime.now().hour) {
                                                  availableTimes.add(dateAux);
                                                } else if (foo.hour ==
                                                    DateTime.now().hour) {
                                                  if (foo.minute >
                                                      DateTime.now().minute)
                                                    availableTimes.add(dateAux);
                                                }
                                                foo = until;
                                              }

                                              thisDate = DateTime(
                                                  DateTime.now().year,
                                                  DateTime.now().month,
                                                  DateTime.now().day,
                                                  availableTimes[0]
                                                      .dateTime
                                                      .hour,
                                                  availableTimes[0]
                                                      .dateTime
                                                      .minute,
                                                  availableTimes[0]
                                                      .dateTime
                                                      .second);

                                              double dist = _coordinateDistance(
                                                  store.latitude,
                                                  store.longitude,
                                                  _currentPosition.latitude,
                                                  _currentPosition.longitude);
                                              print(dist);
                                              if (dist > 1000) {
                                                print("Distancia: " + distance);
                                                distance = (dist / 1000)
                                                        .toStringAsFixed(1) +
                                                    "km";
                                              } else {
                                                dist *= 1000;
                                                distance =
                                                    dist.floor().toString() +
                                                        "m";
                                              }
                                            } else {
                                              storeClose = true;
                                            }
                                          } else {
                                            while (foo.isBefore(close)) {
                                              String hour2 = fos.format(foo);

                                              DateTime until = foo.add(Duration(
                                                  minutes:
                                                      store.estimateMinutes));
                                              String untilhour =
                                                  fos.format(until);
                                              DateAux dateAux = new DateAux(
                                                  text: hour2, dateTime: foo);

                                              availableTimes.add(dateAux);

                                              foo = until;
                                            }
                                          }*/
                                          int selectedTile;
                                          if (thisStore != null &&
                                              justThisTime) {
                                            currentTime = new DateTime(
                                              currentTime.year,
                                              currentTime.month,
                                              currentTime.day,
                                              availableTimes[0].dateTime.hour,
                                              availableTimes[0].dateTime.minute,
                                              availableTimes[0].dateTime.second,
                                              availableTimes[0]
                                                  .dateTime
                                                  .millisecond,
                                              availableTimes[0]
                                                  .dateTime
                                                  .microsecond,
                                            );
                                            /* Map<String, dynamic> query = {
                                              "idStore": currentStore.id,
                                              "idUser":
                                                  _auth.currentUser.user.id,
                                              "day": currentTime.toString()
                                            };
                                            apiCalls
                                                .getReservations(query: query)
                                                .then((value) {
                                              reservationRepository =
                                                  ReservationRepository
                                                      .fromJson(value);
                                              availableReservations = store
                                                      .bunchClients -
                                                  availableByDate(currentTime);
                                            });*/
                                            availableReservations =
                                                store.bunchClients;
                                            print(
                                                "Entre esta cantidad de veces");
                                            justThisTime = false;
                                          }

                                          return Container(
                                            margin: EdgeInsets.only(
                                                bottom: 10, top: 10),
                                            child: Theme(
                                              data: ThemeData(
                                                  accentColor: Colors.black,
                                                  dividerColor:
                                                      Colors.transparent),
                                              child: ExpansionTile(
                                                  key: Key(index.toString()),
                                                  initiallyExpanded:
                                                      thisStore != null
                                                          ? true
                                                          : false,
                                                  onExpansionChanged: (value) {
                                                    currentTime = DateTime(
                                                            DateTime.now().year,
                                                            DateTime.now()
                                                                .month,
                                                            DateTime.now().day,
                                                            availableTimes[0]
                                                                .dateTime
                                                                .hour,
                                                            availableTimes[0]
                                                                .dateTime
                                                                .minute,
                                                            availableTimes[0]
                                                                .dateTime
                                                                .second)
                                                        .add(Duration(days: 1));

                                                    print("CURRENTIME ONTAP:" +
                                                        currentTime.toString());
                                                    if (value) {
                                                      setState(() {
                                                        selectedTile = index;
                                                        print(selectedTile
                                                            .toString());
                                                        gettingReservations =
                                                            true;
                                                        availableReservations =
                                                            null;
                                                      });
                                                      Map<String, dynamic>
                                                          query = {
                                                        "idStore": store.id,
                                                        "idUser": _auth
                                                            .currentUser
                                                            .user
                                                            .id,
                                                        "day": currentTime
                                                            .toString()
                                                      };
                                                      apiCalls
                                                          .getReservations(
                                                              query: query)
                                                          .then((value) {
                                                        setState(() {
                                                          setBottom(() {
                                                            print("ONTAP:" +
                                                                value
                                                                    .toString());
                                                            reservationRepository =
                                                                ReservationRepository
                                                                    .fromJson(
                                                                        value);
                                                          });
                                                        });
                                                        setState(() {
                                                          setBottom(() {
                                                            gettingReservations =
                                                                false;
                                                            availableReservations = store
                                                                    .bunchClients -
                                                                availableByDate(
                                                                    currentTime);
                                                            print("AVAILABLE:" +
                                                                availableReservations
                                                                    .toString());
                                                          });
                                                        });
                                                        print("Reservations: " +
                                                            value.toString());
                                                      });
                                                    } else {
                                                      setState(() {
                                                        setBottom(() {
                                                          selectedTile = -1;
                                                        });
                                                      });
                                                    }
                                                  },
                                                  leading: Container(
                                                    height: 40,
                                                    width: 40,
                                                    padding: EdgeInsets.all(2),
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                        color: storeClose
                                                            ? Colors.red
                                                            : Colors.blue[200]),
                                                    child: Center(
                                                      child: Icon(
                                                        storeClose
                                                            ? CupertinoIcons
                                                                .lock
                                                            : Icons.storefront,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                  title: Text(
                                                    store.name,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  subtitle: Container(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        AutoSizeText(
                                                            store.address,
                                                            maxLines: 1,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black)),
                                                        AutoSizeText(
                                                            '${LocalizationsKE.of(context).abierto} $openhour ${LocalizationsKE.of(context).to} $hour',
                                                            maxLines: 1,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .green)),
                                                      ],
                                                    ),
                                                  ),
                                                  trailing: Container(
                                                    width: 60,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        AutoSizeText(
                                                            "Distancia",
                                                            maxLines: 1),
                                                        AutoSizeText(
                                                          distance,
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 18),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Colors.grey[200],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      20)),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width -
                                                                MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    2.5,
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height /
                                                                3.5,
                                                            child:
                                                                CupertinoTheme(
                                                              data:
                                                                  CupertinoThemeData(
                                                                textTheme:
                                                                    CupertinoTextThemeData(
                                                                  dateTimePickerTextStyle: TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      color: Colors
                                                                          .black),
                                                                ),
                                                              ),
                                                              child:
                                                                  CupertinoDatePicker(
                                                                key: Key(
                                                                    "cupertino"),
                                                                minimumDate: new DateTime(
                                                                        DateTime.now()
                                                                            .year,
                                                                        DateTime.now()
                                                                            .month,
                                                                        DateTime.now()
                                                                            .day,
                                                                        00,
                                                                        00,
                                                                        00,
                                                                        00,
                                                                        00)
                                                                    .add(Duration(
                                                                        days:
                                                                            1)),
                                                                initialDateTime: DateTime(
                                                                        DateTime.now()
                                                                            .year,
                                                                        DateTime.now()
                                                                            .month,
                                                                        DateTime.now()
                                                                            .day,
                                                                        00,
                                                                        00,
                                                                        00,
                                                                        00,
                                                                        00)
                                                                    .add(Duration(
                                                                        days:
                                                                            1)),
                                                                onDateTimeChanged:
                                                                    (DateTime
                                                                        newdate) {
                                                                  setState(() {
                                                                    setBottom(
                                                                        () {
                                                                      setState(
                                                                          () {
                                                                        setBottom(
                                                                            () {
                                                                          currentTime = DateTime(
                                                                              newdate.year,
                                                                              newdate.month,
                                                                              newdate.day,
                                                                              currentTime.hour,
                                                                              currentTime.minute,
                                                                              currentTime.second);
                                                                        });
                                                                      });
                                                                      print("CurrentTimePicker:" +
                                                                          currentTime
                                                                              .toString());
                                                                      /*  Map<String,
                                                                              dynamic>
                                                                          query =
                                                                          {
                                                                        "idStore": repository
                                                                            .stores[index]
                                                                            .id,
                                                                        "idUser": _auth
                                                                            .currentUser
                                                                            .user
                                                                            .id,
                                                                        "day": currentTime
                                                                            .toString()
                                                                      };*/
                                                                      Map<String,
                                                                              dynamic>
                                                                          query =
                                                                          {
                                                                        "idStore":
                                                                            currentStore.id,
                                                                        "idUser": _auth
                                                                            .currentUser
                                                                            .user
                                                                            .id,
                                                                        "day": currentTime
                                                                            .toString()
                                                                      };

                                                                      apiCalls
                                                                          .getReservations(
                                                                              query:
                                                                                  query)
                                                                          .then(
                                                                              (value) {
                                                                        setState(
                                                                            () {
                                                                          setBottom(
                                                                              () {
                                                                            reservationRepository =
                                                                                ReservationRepository.fromJson(value);
                                                                            availableReservations =
                                                                                store.bunchClients - availableByDate(currentTime);
                                                                            gettingReservations =
                                                                                false;
                                                                          });
                                                                        });
                                                                      });
                                                                    });
                                                                  });
                                                                },
                                                                minimumYear:
                                                                    2020,
                                                                maximumYear:
                                                                    2050,
                                                                mode:
                                                                    CupertinoDatePickerMode
                                                                        .date,
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height /
                                                                3.5,
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                3.5,
                                                            child:
                                                                CupertinoTheme(
                                                              data:
                                                                  CupertinoThemeData(
                                                                textTheme:
                                                                    CupertinoTextThemeData(
                                                                  pickerTextStyle: TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      color: Colors
                                                                          .black),
                                                                ),
                                                              ),
                                                              child:
                                                                  CupertinoPicker(
                                                                magnification:
                                                                    2.35 / 2.1,
                                                                children:
                                                                    availableTimes
                                                                        .map((e) =>
                                                                            Container(
                                                                              padding: EdgeInsets.only(top: 5),
                                                                              child: Text(e.text),
                                                                            ))
                                                                        .toList(),
                                                                itemExtent: 32,
                                                                onSelectedItemChanged:
                                                                    (int
                                                                        indexs) {
                                                                  setState(() {
                                                                    setBottom(
                                                                        () {
                                                                      currentTime = DateTime(
                                                                          currentTime
                                                                              .year,
                                                                          currentTime
                                                                              .month,
                                                                          currentTime
                                                                              .day,
                                                                          availableTimes[indexs]
                                                                              .dateTime
                                                                              .hour,
                                                                          availableTimes[indexs]
                                                                              .dateTime
                                                                              .minute,
                                                                          availableTimes[indexs]
                                                                              .dateTime
                                                                              .second);

                                                                      print("DENTROPicker: " +
                                                                          currentTime
                                                                              .toString());
                                                                      /*availableReservations = repository
                                                                              .stores[index]
                                                                              .bunchClients -
                                                                          availableByDate(currentTime);*/
                                                                      availableReservations = currentStore
                                                                              .bunchClients -
                                                                          availableByDate(
                                                                              currentTime);
                                                                    });
                                                                  });
                                                                  print("Hora cambiada: " +
                                                                      currentTime
                                                                          .toString());
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          bottom: 10, top: 10),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Column(
                                                            children: [
                                                              Text(LocalizationsKE
                                                                      .of(context)
                                                                  .disponibles),
                                                              Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        top: 5),
                                                                height: 45,
                                                                width: 75,
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            5),
                                                                decoration: BoxDecoration(
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                          color: Colors.black.withOpacity(
                                                                              .15),
                                                                          offset: Offset(1,
                                                                              1),
                                                                          blurRadius:
                                                                              8,
                                                                          spreadRadius:
                                                                              1)
                                                                    ],
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            15),
                                                                    color: Colors
                                                                        .white),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceEvenly,
                                                                  children: [
                                                                    Icon(
                                                                      CupertinoIcons
                                                                          .person_2_alt,
                                                                      color: Colors
                                                                          .blue,
                                                                    ),
                                                                    availableReservations ==
                                                                            null
                                                                        ? CupertinoActivityIndicator()
                                                                        : Text(
                                                                            availableReservations
                                                                                .toString(),
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            width: 20,
                                                          ),
                                                          GestureDetector(
                                                            onTap: () {
                                                              print("ANTES:" +
                                                                  currentTime
                                                                      .toUtc()
                                                                      .toString());
                                                              if (currentTime
                                                                  .toUtc()
                                                                  .isAfter(DateTime
                                                                          .now()
                                                                      .toUtc())) {
                                                                print("LOCAL:" +
                                                                    currentTime
                                                                        .toUtc()
                                                                        .toString());
                                                                print("SIN:" +
                                                                    currentTime
                                                                        .toString());
                                                                apiCalls
                                                                    .createReservation(
                                                                        store
                                                                            .id,
                                                                        _auth
                                                                            .user
                                                                            .user
                                                                            .id
                                                                            .toString(),
                                                                        store
                                                                            .name,
                                                                        currentTime
                                                                            .toUtc()
                                                                            .toString(),
                                                                        cantP)
                                                                    .then(
                                                                        (value) {
                                                                  DateTime
                                                                      reservation =
                                                                      DateTime.parse(
                                                                              value['date'])
                                                                          .toLocal();
                                                                  DateAux aux = DateAux(
                                                                      text:
                                                                          "SUCCESS",
                                                                      dateTime:
                                                                          reservation);
                                                                  justThisTime =
                                                                      true;

                                                                  Duration
                                                                      differenceTo =
                                                                      reservation.difference(DateTime
                                                                              .now()
                                                                          .subtract(
                                                                              Duration(minutes: 1)));
                                                                  print(differenceTo
                                                                      .toString());
                                                                  cantP = 1;
                                                                  notifications
                                                                      .scheduleNotification(
                                                                    id: value[
                                                                        '_id'],
                                                                    title: LocalizationsKE.of(
                                                                            context)
                                                                        .recuerda,
                                                                    body: LocalizationsKE.of(context).recordatorioreserva +
                                                                        repository
                                                                            .stores[
                                                                                index]
                                                                            .name +
                                                                        LocalizationsKE.of(context)
                                                                            .alas +
                                                                        reservation
                                                                            .hour
                                                                            .toString() +
                                                                        ":" +
                                                                        reservation
                                                                            .minute
                                                                            .toString() +
                                                                        ".",
                                                                    duration:
                                                                        differenceTo,
                                                                  );
                                                                  Navigator.pop(
                                                                      context,
                                                                      aux);
                                                                });
                                                              } else {
                                                                confirmationReservationDialog(
                                                                    context,
                                                                    "",
                                                                    LocalizationsKE.of(
                                                                            context)
                                                                        .errordate);
                                                              }
                                                            },
                                                            child: Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      top: 18),
                                                              height: 50,
                                                              width: 100,
                                                              decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .blue,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              15)),
                                                              child: Center(
                                                                child: Text(
                                                                  LocalizationsKE.of(
                                                                          context)
                                                                      .reservar,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 20,
                                                          ),
                                                          Column(
                                                            children: [
                                                              Text(LocalizationsKE
                                                                      .of(context)
                                                                  .personas),
                                                              Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        top: 5),
                                                                height: 45,
                                                                width: 80,
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            5),
                                                                decoration: BoxDecoration(
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                          color: Colors.black.withOpacity(
                                                                              .15),
                                                                          offset: Offset(1,
                                                                              1),
                                                                          blurRadius:
                                                                              8,
                                                                          spreadRadius:
                                                                              1)
                                                                    ],
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            15),
                                                                    color: Colors
                                                                        .white),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceEvenly,
                                                                  children: [
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          setBottom(
                                                                              () {
                                                                            if (cantP >
                                                                                1) {
                                                                              cantP -= 1;
                                                                            }
                                                                          });
                                                                        });
                                                                      },
                                                                      child: Text(
                                                                          "-",
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 23)),
                                                                    ),
                                                                    SizedBox(
                                                                      width: 5,
                                                                    ),
                                                                    Text(
                                                                        cantP
                                                                            .toString(),
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontSize: 18)),
                                                                    SizedBox(
                                                                      width: 5,
                                                                    ),
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          setBottom(
                                                                              () {
                                                                            if (availableReservations - cantP >
                                                                                0)
                                                                              cantP += 1;
                                                                          });
                                                                        });
                                                                      },
                                                                      child: Text(
                                                                          "+",
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 18)),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  ]),
                                            ),
                                          );
                                        }),
                                  )
                                : Center(
                                    child: CircularProgressIndicator(),
                                  )),
                      ],
                    )),
              ),
            );
          });
        }).then((value) {
      if (value != null) {
        justThisTime = true;
        if (value.text == "SUCCESS") {
          currentTime = DateTime.now();
          var formatter = new DateFormat('dd/MM/yyyy');
          var fos = new DateFormat.jm();
          String hour = fos.format(value.dateTime);
          String date = formatter.format(value.dateTime);
          confirmationReservationDialog(context, "",
              "${LocalizationsKE.of(context).reservationsuccess} $date - $hour.");
        } else {
          confirmationReservationDialog(
              context, "ERROR", LocalizationsKE.of(context).reservationsuccess);
        }
      } else {
        setState(() {
          currentTime = DateTime.now();
        });
        print("IS NULL");
      }
    });
  }

  String aux(DateTime date) {
    date.add(Duration(days: 1));
    DateTime d = new DateTime(
        date.year, date.month, date.day, date.hour, date.minute, 00, 00, 00);
    return d.toString();
  }
}

class NewScreen extends StatelessWidget {
  String payload;

  NewScreen({
    @required this.payload,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(payload),
      ),
    );
  }
}

class DateAux {
  String text;
  DateTime dateTime;
  DateAux({this.text, this.dateTime});
}
