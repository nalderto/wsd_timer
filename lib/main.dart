import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayer/audioplayer.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(new TimerApp());
}

class TimerApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'WSD Timer',
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'WSD Timer'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String localFilePath;

  AudioPlayer audioPlayer = new AudioPlayer();

  Future<ByteData> loadAsset() async {
    return await rootBundle.load('assets/ding.mp3');
  }

  void playDing() async {
    final file = new File('${(await getTemporaryDirectory()).path}/ding.mp3');
    await file.writeAsBytes((await loadAsset()).buffer.asUint8List());
    await audioPlayer.play(file.path, isLocal: true);
  }

  static String startButtonText = "Start";
  static IconData startButtonIcon = Icons.play_arrow;

  bool isSnackBar = false;

  static Stopwatch stopwatch = new Stopwatch();
  String time = "0:00";
  static const halfSecond = const Duration(milliseconds: 500);
  void updateClock() {
    setState(() {
      time =
          "${stopwatch.elapsed.inMinutes.toString()}:${((stopwatch.elapsed.inSeconds)%60).toString().padLeft(2, "0")}";
    });

    if (currentRound == 6 || currentRound == 7) {
      if (stopwatch.elapsed.inSeconds == 1) {
        _scaffoldkey.currentState.showSnackBar(protectedTime);
      } else if (stopwatch.elapsed.inSeconds == 240) {
        _scaffoldkey.currentState.hideCurrentSnackBar();
        _scaffoldkey.currentState.showSnackBar(overtime);
      }
      return;
    }

    if (((stopwatch.elapsed.inSeconds == 1) || (stopwatch.elapsed.inSeconds == 420)) && !isSnackBar) {
      _scaffoldkey.currentState.showSnackBar(protectedTime);
      isSnackBar = true;
      if (stopwatch.elapsed.inSeconds == 420) {
        playDing();
      }
    } else if (((stopwatch.elapsed.inSeconds == 60) ||(stopwatch.elapsed.inSeconds == 480)) && isSnackBar) {
      _scaffoldkey.currentState.hideCurrentSnackBar();
      isSnackBar = false;
      if (stopwatch.elapsed.inSeconds == 60) {
        playDing();
      } else if (stopwatch.elapsed.inSeconds == 480 && stopwatch.isRunning) {
        playDing();
        isSnackBar = true;
        _scaffoldkey.currentState.showSnackBar(overtime);
      }
    }

    if (!stopwatch.isRunning &&
        isSnackBar == true &&
        stopwatch.elapsed.inSeconds > 480) {
      _scaffoldkey.currentState.hideCurrentSnackBar();
      isSnackBar = false;
    }
  }

  SnackBar protectedTime = new SnackBar(
    content: Text("Protected Time", style: TextStyle(fontSize: 24.0)),
    backgroundColor: Colors.orangeAccent,
    duration: Duration(seconds: 600),
  );
  SnackBar overtime = new SnackBar(
    content: Text(
      "Overtime",
      style: TextStyle(fontSize: 24.0),
    ),
    backgroundColor: Colors.red,
    duration: Duration(seconds: 600),
  );

  static const _roundNames = <String>[
    'Proposition 1',
    'Opposition 1',
    'Proposition 2',
    'Opposition 2',
    'Proposition 3',
    'Opposition 3',
    'Opposition Reply',
    'Proposition Reply',
  ];

  int currentRound = 0;

  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    new Timer.periodic(halfSecond, (Timer T) => updateClock());
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.

    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text(widget.title),
      ),
      key: _scaffoldkey,
      body: new Column(
        //mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          //Round Text
          new Container(
            padding: const EdgeInsets.all(32.0),
            child: new Text("${_roundNames[currentRound]}",
                style: TextStyle(color: Colors.blue, fontSize: 32.0)),
          ),
          //Timer Text
          new Container(
            padding: new EdgeInsets.only(bottom: 42.0, top: 10.0),
            child: new Text(
              "$time",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 98.0,
              ),
            ),
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              //Previous Button
              new RaisedButton(
                color: Colors.blue,
                textColor: Colors.white,
                shape: CircleBorder(),
                child: Icon(
                  Icons.arrow_left,
                  size: 48.0,
                ),
                onPressed: () {
                  print("Previous Button Pressed");
                  setState(() {
                    startButtonIcon = Icons.play_arrow;
                  });
                  stopwatch.reset();
                  stopwatch.stop();
                  updateClock();
                  _scaffoldkey.currentState.hideCurrentSnackBar();
                  setState(() {
                    if (currentRound > 0) {
                      currentRound--;
                    }
                  });
                },
              ),

              //Start/Pause Button
              new RaisedButton(
                onPressed: () {
                  print("Start Button Pressed");
                  if (!stopwatch.isRunning) {
                    setState(() {
                      startButtonIcon = Icons.pause;
                    });
                    stopwatch.start();
                  } else if (stopwatch.isRunning) {
                    setState(() {
                      startButtonIcon = Icons.play_arrow;
                    });
                    stopwatch.stop();
                  }
                },
                color: Colors.green,
                textColor: Colors.white,
                shape: CircleBorder(),
                child: Icon(startButtonIcon, size: 48.0),
              ),

              //Restart Button
              new RaisedButton(
                onPressed: () {
                  print("Restart Button Pressed");
                  stopwatch.reset();
                  stopwatch.stop();
                  updateClock();
                  _scaffoldkey.currentState.hideCurrentSnackBar();
                  setState(() {
                    currentRound = 0;
                    startButtonIcon = Icons.play_arrow;
                  });
                },
                color: Colors.red,
                textColor: Colors.white,
                shape: CircleBorder(),
                child: Icon(
                  Icons.refresh,
                  size: 48.0,
                ),
              ),

              //Next Button
              new RaisedButton(
                color: Colors.blue,
                textColor: Colors.white,
                shape: CircleBorder(),
                child: Icon(
                  Icons.arrow_right,
                  size: 48.0,
                ),
                onPressed: () {
                  print("Next Button Pressed");
                  setState(() {
                    startButtonIcon = Icons.play_arrow;
                  });
                  stopwatch.reset();
                  stopwatch.stop();
                  updateClock();
                  _scaffoldkey.currentState.hideCurrentSnackBar();
                  setState(() {
                    if (currentRound < 7) {
                      currentRound++;
                    }
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
