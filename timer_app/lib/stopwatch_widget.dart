import 'package:flutter/material.dart';
import 'dart:async';
import 'time.dart';

class StopwatchWidget extends StatefulWidget{
  @override
  _StopwatchWidgetState createState() => _StopwatchWidgetState();
}


class _StopwatchWidgetState extends State<StopwatchWidget> {
  final textController = new TextEditingController();
  var time = new Time();
  final List<ValueChanged<Time>> timerListeners = <ValueChanged<Time>>[];
  List<String> laps = [];
  final Stopwatch stopwatch = new Stopwatch();
  final txtStyle = TextStyle(fontSize: 24,);
  Icon btnIcon = Icon(Icons.play_arrow);
  int hrs = 0;
  int mins = 0;
  int secs = 0;
  bool timerHasStarted = false;

  @override
  Widget build(BuildContext context) {
    String hours = hrs.toString().padLeft(2, '0');
    String minutes = mins.toString().padLeft(2, '0');
    String seconds = secs.toString().padLeft(2, '0');
    return new Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '$hours:$minutes:$seconds',
          style: txtStyle,
          textAlign: TextAlign.center,
        ),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:[
              IconButton(
                iconSize: 48,
                icon: Icon(Icons.control_point),
                onPressed: () {
                  _addLap();
                },
              ),
              IconButton(
                iconSize: 48,
                icon: btnIcon,
                onPressed: () {
                  _startTimer();
                },
              ),
            ]
        ),
        TextField(
          style: TextStyle(fontSize: 24),
          textAlign: TextAlign.center,
          controller:textController,
          enabled: false,
          decoration:InputDecoration.collapsed(hintText:null,border:InputBorder.none),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    timerListeners.add(onTick);
  }

  void onTick(Time time) {
    setState(() {
      hrs = time.hours;
      mins = time.minutes;
      secs = time.seconds;
    });
  }

  @override
  void dispose() {
    super.dispose();
    timerListeners.remove(onTick);
  }

  void _startTimer() {
    setState(() {
      if (stopwatch.isRunning) {
        stopwatch.stop();
        timerHasStarted = false;
        btnIcon = Icon(Icons.play_arrow);
      } else {
        stopwatch.start();
        timerHasStarted = true;
        btnIcon = Icon(Icons.pause);
        new Timer.periodic(new Duration(milliseconds: 250), updateTime);
      }
    });
  }

  void updateTime(Timer timer) {
    int milliseconds = stopwatch.elapsedMilliseconds;
    final int hundreths = (milliseconds / 10).truncate();
    final int seconds = (hundreths / 100).truncate();
    final int minutes = (seconds / 60).truncate();
    final int hours = (minutes / 60).truncate();

    Time newTime = new Time(
      hours: hours,
      minutes: minutes % 60,
      seconds: seconds % 60,
    );

    for (final listener in timerListeners) {
      listener(newTime);
    }

  }

  void _addLap() {
    setState(() {
      String hours = hrs.toString().padLeft(2, '0');
      String minutes = mins.toString().padLeft(2, '0');
      String seconds = secs.toString().padLeft(2, '0');
      laps.add('$hours:$minutes:$seconds');
      stopwatch.reset();
      textController.text = "";
      for(String lap in laps){
        textController.text += lap + '\n';
      }

    });

  }
}