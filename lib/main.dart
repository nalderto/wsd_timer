import 'package:flutter/material.dart';
import 'dart:async';

void main() => runApp(new TimerApp());

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

  static String startButtonText = "Start";
  static IconData startButtonIcon = Icons.play_arrow;

  static Stopwatch stopwatch = new Stopwatch();
  String time = "0:00";
  static const second = const Duration(seconds:1);
  void updateClock(){
    setState(() {
      time = "${stopwatch.elapsed.inMinutes.toString()}:${((stopwatch.elapsed.inSeconds)%60).toString().padLeft(2, "0")}";
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    new Timer.periodic(second, (Timer T) => updateClock());
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text(widget.title),
      ),

      body: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Text(
            "$time",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 98.0,
            ),
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              new RaisedButton(
                onPressed: () {
                  print("Start Button Pressed");
                  if(!stopwatch.isRunning){
                    startButtonIcon = Icons.pause;
                    stopwatch.start();
                  }
                  else if(stopwatch.isRunning){
                    startButtonIcon = Icons.play_arrow;
                    stopwatch.stop();
                  }
                },
                color: Colors.green,
                textColor: Colors.white,
                shape: CircleBorder(),
                child: Icon(startButtonIcon, size: 48.0),
              ),
              new RaisedButton(
                onPressed: () {
                  print("Restart Button Pressed");
                  stopwatch.reset();
                },
                color: Colors.red,
                textColor: Colors.white,
                shape: CircleBorder(),
                child: Icon(
                  Icons.refresh,
                  size: 48.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}