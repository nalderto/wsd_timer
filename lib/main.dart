import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayer/audioplayer.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/services.dart';

void main() {
  //Only Works in Portait Mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(new TimerApp());
}

class TimerApp extends StatelessWidget {
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
  final String title;
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  //AudioPlayer Methods
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

  //Variables
  int currentRound = 0;
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  static String startButtonText = "Start";
  static IconData startButtonIcon = Icons.play_arrow;
  static IconData muteButtonIcon = Icons.volume_up;
  bool isSnackBar = false;
  bool isMuted = false;
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

  //Timer Methods
  static Stopwatch stopwatch = new Stopwatch();
  String time = "0:00";
  static const halfSecond = const Duration(milliseconds: 500);
  void updateClock() {
    setState(() {
      time = "${stopwatch.elapsed.inMinutes.toString()}:${((stopwatch.elapsed.inSeconds)%60).toString().padLeft(2, "0")}";
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
      if (stopwatch.elapsed.inSeconds == 420 && !isMuted) {
        playDing();
      }
    } else if (((stopwatch.elapsed.inSeconds == 60) ||(stopwatch.elapsed.inSeconds == 480)) && isSnackBar) {
      _scaffoldkey.currentState.hideCurrentSnackBar();
      isSnackBar = false;
      if (stopwatch.elapsed.inSeconds == 60) {
        if(!isMuted){
        playDing();
        }
      } else if (stopwatch.elapsed.inSeconds == 480 && stopwatch.isRunning) {
        if (!isMuted){
        playDing();
        }
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

  //SnackBars
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

  @override
  void initState() {
    super.initState();
    new Timer.periodic(halfSecond, (Timer T) => updateClock());
  }

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      key: _scaffoldkey,
      body: new Column(
        children: <Widget>[
          //Mute Button
          new Container(
            alignment: Alignment.topRight,
            padding: new EdgeInsets.only(top:16.0),
            child: new FlatButton(
            onPressed: (){
              setState(() {
                if(isMuted){
                  isMuted = false;
                  muteButtonIcon = Icons.volume_up;
                }
                else if (!isMuted){
                  isMuted = true;
                  muteButtonIcon = Icons.volume_off;
                }
              });
            },
            child: Icon(
              muteButtonIcon,
              size: 32.0,
            ),
            shape: CircleBorder(),
          ),
          ),

          //Round Text
          new Container(
            padding: const EdgeInsets.all(24.0),
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
                  isSnackBar = false;
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
                  isSnackBar = false;
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
                  isSnackBar = false;
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
