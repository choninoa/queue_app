import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ke/providers/utilsProvider.dart';
import 'package:ke/utils/localizationsKE.dart';
import 'package:ke/utils/mapTypes.dart';
import 'package:ke/utils/rippleAnimation.dart';
import 'package:latlong/latlong.dart';
import 'package:mapbox_navigation/mapbox_navigation.dart';
import 'package:provider/provider.dart';

/*import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_mapbox_navigation/library.dart';

class NavigationPath extends StatefulWidget {
  @override
  _NavigationPathState createState() => _NavigationPathState();
}

class _NavigationPathState extends State<NavigationPath> {
  String _platformVersion = 'Unknown';
  String _instruction = "";
  final _origin = WayPoint(
      name: "Way Point 1",
      latitude: 38.9111117447887,
      longitude: -77.04012393951416);
  final _stop1 = WayPoint(
      name: "Way Point 2",
      latitude: 38.91113678979344,
      longitude: -77.03847169876099);
  final _stop2 = WayPoint(
      name: "Way Point 3",
      latitude: 38.91040213277608,
      longitude: -77.03848242759705);
  final _stop3 = WayPoint(
      name: "Way Point 4",
      latitude: 38.909650771013034,
      longitude: -77.03850388526917);
  final _stop4 = WayPoint(
      name: "Way Point 5",
      latitude: 38.90894949285854,
      longitude: -77.03651905059814);
  final _farAway = WayPoint(
      name: "Far Far Away", latitude: 36.1175275, longitude: -115.1839524);

  MapBoxNavigation _directions;
  MapBoxOptions _options;

  bool _arrived = false;
  bool _isMultipleStop = false;
  double _distanceRemaining, _durationRemaining;
  MapBoxNavigationViewController _controller;
  bool _routeBuilt = false;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
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
    var wayPoints = List<WayPoint>();
    wayPoints.add(_origin);
    wayPoints.add(_stop1);

    await _directions.startNavigation(
        wayPoints: wayPoints,
        options: MapBoxOptions(
            mode: MapBoxNavigationMode.drivingWithTraffic,
            simulateRoute: true,
            language: "en",
            units: VoiceUnits.metric));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Text('Running on: $_platformVersion\n'),
                    Container(
                      color: Colors.grey,
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: (Text(
                          "Full Screen Navigation",
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        )),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RaisedButton(
                          child: Text("Start A to B"),
                          onPressed: () async {
                            var wayPoints = List<WayPoint>();
                            wayPoints.add(_origin);
                            wayPoints.add(_stop1);

                            await _directions.startNavigation(
                                wayPoints: wayPoints,
                                options: MapBoxOptions(
                                    mode:
                                        MapBoxNavigationMode.drivingWithTraffic,
                                    simulateRoute: true,
                                    language: "en",
                                    units: VoiceUnits.metric));
                          },
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        RaisedButton(
                          child: Text("Start Multi Stop"),
                          onPressed: () async {
                            _isMultipleStop = true;
                            var wayPoints = List<WayPoint>();
                            wayPoints.add(_origin);
                            wayPoints.add(_stop1);
                            wayPoints.add(_stop2);
                            wayPoints.add(_stop3);
                            wayPoints.add(_stop4);
                            wayPoints.add(_origin);

                            await _directions.startNavigation(
                                wayPoints: wayPoints,
                                options: MapBoxOptions(
                                    mode: MapBoxNavigationMode.driving,
                                    simulateRoute: true,
                                    language: "en",
                                    allowsUTurnAtWayPoints: true,
                                    units: VoiceUnits.metric));
                          },
                        )
                      ],
                    ),
                    Container(
                      color: Colors.grey,
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: (Text(
                          "Embedded Navigation",
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        )),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RaisedButton(
                          child: Text(_routeBuilt && !_isNavigating
                              ? "Clear Route"
                              : "Build Route"),
                          onPressed: _isNavigating
                              ? null
                              : () {
                                  if (_routeBuilt) {
                                    _controller.clearRoute();
                                  } else {
                                    var wayPoints = List<WayPoint>();
                                    wayPoints.add(_origin);
                                    wayPoints.add(_stop1);
                                    wayPoints.add(_stop2);
                                    wayPoints.add(_stop3);
                                    wayPoints.add(_stop4);
                                    wayPoints.add(_origin);
                                    _isMultipleStop = wayPoints.length > 2;
                                    _controller.buildRoute(
                                        wayPoints: wayPoints);
                                  }
                                },
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        RaisedButton(
                          child: Text("Start "),
                          onPressed: _routeBuilt && !_isNavigating
                              ? () {
                                  _controller.startNavigation();
                                }
                              : null,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        RaisedButton(
                          child: Text("Cancel "),
                          onPressed: _isNavigating
                              ? () {
                                  _controller.finishNavigation();
                                }
                              : null,
                        )
                      ],
                    ),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          "Long-Press Embedded Map to Set Destination",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Container(
                      color: Colors.grey,
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: (Text(
                          _instruction == null || _instruction.isEmpty
                              ? "Banner Instruction Here"
                              : _instruction,
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        )),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 20.0, right: 20, top: 20, bottom: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text("Duration Remaining: "),
                              Text(_durationRemaining != null
                                  ? "${(_durationRemaining / 60).toStringAsFixed(0)} minutes"
                                  : "---")
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Text("Distance Remaining: "),
                              Text(_distanceRemaining != null
                                  ? "${(_distanceRemaining * 0.000621371).toStringAsFixed(1)} miles"
                                  : "---")
                            ],
                          ),
                        ],
                      ),
                    ),
                    Divider()
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.grey,
                child: MapBoxNavigationView(
                    options: _options,
                    onRouteEvent: _onEmbeddedRouteEvent,
                    onCreated:
                        (MapBoxNavigationViewController controller) async {
                      _controller = controller;
                      controller.initialize();
                    }),
              ),
            )
          ]),
        ),
      ),
    );
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
          await _controller.finishNavigation();
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
}
*/

class Navigateate extends StatefulWidget {
  Position initialPosition;
  Position destinationPosition;
  String language;
  String route;
  Navigateate(
      {this.initialPosition,
      this.destinationPosition,
      this.language,
      this.route});
  @override
  _NavigateateState createState() => _NavigateateState();
}

class _NavigateateState extends State<Navigateate> {
  MapViewController controller;
  var mapBox = MapboxNavigation();
  var isLoading = false;
  var isRouteInProgress = false;
  bool noyet = true;
  bool mapready=false;

  @override
  void initState() {
    super.initState();
    mapBox.init();

    mapBox.getMapBoxEventResults().onData((data) {
      printWrapped("Event: ${data.eventName}, Data: ${data.data}");

      var event = MapBoxEventProvider.getEventType(data.eventName);

      if (event == MapBoxEvent.map_ready) {
        
        if(!mapready)
        controller.buildRoute(
          originLat: widget.initialPosition != null
              ? widget.initialPosition.latitude
              : 20.955108,
          originLong: widget.initialPosition != null
              ? widget.initialPosition.longitude
              : -76.9654117,
          destinationLat: widget.destinationPosition != null
              ? widget.destinationPosition.latitude
              : 20.955033,
          destinationLong: widget.destinationPosition != null
              ? widget.destinationPosition.longitude
              : -76.951786,
        );
        setState(() {
          mapready=true;
        });
      } 

       if (event == MapBoxEvent.navigation_running) {
        setState(() {
          noyet = false;
        });
      } else if (event == MapBoxEvent.route_building) {
        setState(() {
          isLoading = true;
        });

        print("Building route..");
      } else if (event == MapBoxEvent.route_build_failed) {
        setState(() {
          isLoading = false;
        });

        print("Route building failed.");
      } else if (event == MapBoxEvent.route_built) {
        setState(() {
          isLoading = false;
         controller.startNavigation();
        });

        var routeResponse = MapBoxRouteResponse.fromJson(jsonDecode(data.data));

        controller
            .getFormattedDistance(routeResponse.routes.first.distance)
            .then((value) => print("Route Distance: $value"));

        controller
            .getFormattedDuration(routeResponse.routes.first.duration)
            .then((value) => print("Route Duration: $value"));
      } else if (event == MapBoxEvent.progress_change) {
        setState(() {
          isRouteInProgress = true;
        });

        var progressEvent = MapBoxProgressEvent.fromJson(jsonDecode(data.data));

        controller
            .getFormattedDistance(progressEvent.legDistanceRemaining)
            .then((value) => print("Leg Distance Remaining: $value"));

        controller
            .getFormattedDistance(progressEvent.distanceTraveled)
            .then((value) => print("Distance Travelled: $value"));

        controller
            .getFormattedDuration(progressEvent.legDurationRemaining)
            .then((value) => print("Leg Duration Remaining: $value"));

        print("Instruction: ${progressEvent.currentStepInstruction},"
            "Current Direction: ${progressEvent.currentDirection}");
      } else if (event == MapBoxEvent.milestone_event) {
        var mileStoneEvent =
            MapBoxMileStoneEvent.fromJson(jsonDecode(data.data));

        controller
            .getFormattedDistance(mileStoneEvent.distanceTraveled)
            .then((value) => print("Distance Travelled: $value"));
      } else if (event == MapBoxEvent.speech_announcement) {
        var speechEvent = MapBoxEventData.fromJson(jsonDecode(data.data));
        print("Speech Text: ${speechEvent.data}");
      } else if (event == MapBoxEvent.banner_instruction) {
        var bannerEvent = MapBoxEventData.fromJson(jsonDecode(data.data));
        print("Banner Text: ${bannerEvent.data}");
      } else if (event == MapBoxEvent.navigation_cancelled) {
        setState(() {
          isRouteInProgress = false;
          print("Canceled aqui");
          // Navigator.pop(context);
          //Navigator.pop(context);
        });
      } else if (event == MapBoxEvent.navigation_finished) {
        setState(() {
          isRouteInProgress = false;
          print("Finished aqui");
          // Navigator.pop(context);
          // Navigator.pop(context);
        });
      } else if (event == MapBoxEvent.on_arrival) {
        setState(() {
          isRouteInProgress = false;
        });
      } else if (event == MapBoxEvent.user_off_route) {
        var locationData = MapBoxLocation.fromJson(jsonDecode(data.data));
        print("User has off-routed: Location: ${locationData.toString()}");
      } else if (event == MapBoxEvent.faster_route_found) {
        var routeResponse = MapBoxRouteResponse.fromJson(jsonDecode(data.data));

        controller
            .getFormattedDistance(routeResponse.routes.first.distance)
            .then(
                (value) => print("Faster route found: Route Distance: $value"));

        controller
            .getFormattedDuration(routeResponse.routes.first.duration)
            .then(
                (value) => print("Faster route found: Route Duration: $value"));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    UtilsProvider _utils = Provider.of<UtilsProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          MapBoxMapView(onMapViewCreated: _onMapViewCreated),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: noyet
                ? Stack(
                    //crossAxisAlignment: CrossAxisAlignment.center,
                    //mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: RipplesAnimation(
                            color: _utils.showCurrent() == MapTypes.RED
                                ? Colors.red
                                : Colors.indigo,
                            child: Container()),
                      ),
                      Center(
                        child: Container(
                          height: 180,
                          width: 180,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                          child: Image.asset(
                            "assets/images/KE-logo.png",
                            height: 100,
                            width: 100,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          "We are finding the best route for you.",
                          style: TextStyle(
                              fontSize: 25,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "We hope you enjoy your ride, go to the store to check your reservation.",
                        style: TextStyle(
                            fontSize: 25,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.green),
                            child: Center(
                              child: Text(
                                "Continuar",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      )
                      /* Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            RaisedButton(
                                child: Text("Add Marker"),
                                color: Colors.blue,
                                textColor: Colors.white,
                                onPressed: () async {
                                  await controller.addMarker(
                                      latitude: 33.569126,
                                      longitude: 73.1231471);
                                  await controller.moveCameraToPosition(
                                      latitude: 33.569126,
                                      longitude: 73.1231471);
                                }),
                            RaisedButton(
                                child: Text("Move Camera"),
                                color: Colors.blue,
                                textColor: Colors.white,
                                onPressed: () async {
                                  await controller.moveCameraToPosition(
                                      latitude: 33.6392443,
                                      longitude: 73.278358);
                                })
                          ],
                        ),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            RaisedButton(
                                child: Text("Build Route"),
                                color: Colors.blue,
                                textColor: Colors.white,
                                onPressed: () async {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  await controller
                                      .buildRoute(
                                          originLat: 20.955108,
                                          originLong: -76.9654117,
                                          destinationLat: 20.955033,
                                          destinationLong: -76.951786,
                                          zoom: 9.5)
                                      .then((value) async {
                                    print("ya cargo");
                                    await controller.startNavigation(
                                        shouldSimulateRoute: true);
                                  });
                                }),
                            RaisedButton(
                                child: Text("Navigate"),
                                color: Colors.blue,
                                textColor: Colors.white,
                                onPressed: () async {
                                  await controller.startNavigation(
                                      shouldSimulateRoute: true);
                                }),
                            RaisedButton(
                                child: Text("Navigate Embedded"),
                                color: Colors.blue,
                                textColor: Colors.white,
                                onPressed: () async {
                                  await controller
                                      .startEmbeddedNavigation(
                                    zoom: 18.0,
                                    tilt: 90.0,
                                    bearing: 50.0,
                                    shouldSimulateRoute: true,
                                  );
                                })
                          ],
                        ),
                        InkWell(
                          onTap: () async {
                            await controller.startNavigation(
                                shouldSimulateRoute: true);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.blue),
                            child: Center(
                              child: Text(
                                "Start Navigation",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        )*/
                    ],
                  ),
          ),
          isLoading
              ? Align(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator())
              : Container(),
        ],
      ),
    );
  }

  void _onMapViewCreated(MapViewController controller) async {
    this.controller = controller;
    
    await controller.showMap(MapBoxOptions(
        initialLat: widget.initialPosition != null
            ? widget.initialPosition.latitude
            : 20.951,
        initialLong: widget.initialPosition != null
            ? widget.initialPosition.longitude
            : -76.961,
        enableRefresh: true,
        alternatives: true,
        zoom: 13.0,
        tilt: 0.0,
        bearing: 0.0,
        clientAppName: "Virtual KE",
        voiceInstructions: true,
        bannerInstructions: true,
        continueStraight: false,
        profile: "driving-traffic",
        language: widget.language,
        testRoute: "",
        debug: false));
  }

  String _prettyPrintJson(String input) {
    JsonDecoder _decoder = JsonDecoder();
    JsonEncoder _encoder = JsonEncoder.withIndent('  ');
    var object = _decoder.convert(input);
    var prettyString = _encoder.convert(object);
    prettyString.split('\n').forEach((element) => print(element));
    return prettyString;
  }

  void printWrapped(String text) {
    final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }
}
