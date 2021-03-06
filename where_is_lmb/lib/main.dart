import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:math' as math;

import 'package:location/location.dart';

void main() => runApp(MyApp());

double _sigmaX = 5.0; // from 0-10
double _sigmaY = 5.0; // from 0-10
double _opacity = 0.1; // from 0-1.0

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double _direction = 0.0;
  double _phonedirection = 0.0;
  int _distance = 0;

  List<double> _position = [0, 0];

  @override
  initState() {
    super.initState();

    FlutterCompass.events.listen((double phonedirection) {
      setState(() {
        _phonedirection = phonedirection;
        doCalcul();
        print("change");
      });
    });

    Location().onLocationChanged().listen((LocationData currentLocation) {
      if (_position[0].compareTo(currentLocation.latitude) != 0 ||
          _position[1].compareTo(currentLocation.longitude) != 0) {
        setState(() {
          print("${{_position[1]}} ${{currentLocation.longitude}} ${{
            _position[1] != currentLocation.longitude
          }}");
          _position[0] = currentLocation.latitude;
          _position[1] = currentLocation.longitude;
          doCalcul();
        });
      }
    });

    doCalcul();
  }

  doCalcul() async {
    final double lat1 = _position[0] * math.pi / 180;
    final double lon1 = _position[1] * math.pi / 180;

    final double lat2 = 45.8326 * math.pi / 180; // Mont
    final double lon2 = 6.8652 * math.pi / 180; // Mont

    // ---------------- CALCUL Direction vers mtbl -------------

    var y = math.sin(lon2 - lon1) * math.cos(lat2);
    var x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(lon2 - lon1);
    var brng = math.atan2(y, x) * 180 / math.pi;
    // Passer de -180, + 180 a 0, 360
    var direction = (brng + 360) % 360;

    setState(() {
      _direction = direction;
    });

    // ------------- CALCUL DISTANCE d ------------------

    double R = 6371e3; // metres
    double g1 = lat1 ;
    double g2 = lat2;
    var dg = (lat2 - lat1) ;
    var dl = (lon2 - lon1);
    var a = math.sin(dg / 2) * math.sin(dg / 2) +
        math.cos(g1) * math.cos(g2) * math.sin(dl / 2) * math.sin(dl / 2);
    var c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    var _distanceRes = R * c;
    print(_distanceRes);
    print(lat1);
    print(lon1);

    setState(() {
      _distance = (_distanceRes/1000).floor();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return MaterialApp(
      home: Scaffold(
       
        body: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/mtbl.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: _sigmaX, sigmaY: _sigmaY),
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  alignment: AlignmentDirectional.topCenter,
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: Transform.rotate(
                          angle: (360 - _phonedirection + _direction) %
                              360 *
                              math.pi /
                              180,
                          child: Image.asset(
                            "assets/images/arrow.png",
                            width: MediaQuery.of(context).size.width,
                          ),
                        ),
                      ),
                      Text("Vous etes à $_distance km du Mont Blanc", style: TextStyle(color: Colors.white),),
                      // Row(
                      //   children: <Widget>[
                      //     Text("$_direction"),
                      //     Text("$_phonedirection"),
                      //     Text("lat : ${{_position[0]}}, long : ${{
                      //       _position[1]
                      //     }}"),
                      //     Text("${{
                      //       (360 - _phonedirection + _direction) % 360
                      //     }}"),
                      //   ],
                      // )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
