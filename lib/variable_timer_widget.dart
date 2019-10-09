import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:audioplayers/audio_cache.dart';
import 'time.dart';

class VariableTimerWidget extends StatefulWidget{
  @override
  _VariableTimerWidgetState createState() => _VariableTimerWidgetState();
}


class _VariableTimerWidgetState extends State<VariableTimerWidget> {
  final audioPath = "quick-alarm.WAV";
  Future<AudioPlayer> ap;
  final timeController = new TextEditingController();
  final textController = new TextEditingController();
  var time = new Time();
  final List<ValueChanged<Time>> timerListeners = <ValueChanged<Time>>[];
  List<String> times = [];
  int currentLoopLocation = 0;
  final Stopwatch stopwatch = new Stopwatch();
  final regExp = new RegExp(
    r"\d{2}",
  );
  final txtStyle = TextStyle(fontSize: 24,);
  Icon btnIcon = Icon(Icons.play_arrow);
  int hrs = 0;
  int mins = 0;
  int secs = 0;
  bool timerHasStarted = false;
  bool repeat = false;
  AudioCache audioCache = new AudioCache();
  bool timerHasFinished = false;

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
                  _addVarTime();
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
        CheckboxListTile(
          title: Text("Repeat times"),
          value:repeat,
          onChanged: (bool value){
            setState(() {
              repeat = value ? true : false;
            });
          },
        ),
        TextField(
          style: TextStyle(fontSize: 24),
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          controller:timeController,
          onSubmitted: (text){
            _addVarTime();
          },
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
      if(timerHasFinished){
        ap.then((value){
          value.stop();
        });
        timerHasFinished = false;
      }
      if (stopwatch.isRunning) {
        stopwatch.stop();
        timerHasStarted = false;
        currentLoopLocation = 0;
        btnIcon = Icon(Icons.play_arrow);
      } else {
        _setNewTime();
        stopwatch.start();
        timerHasStarted = true;
        btnIcon = Icon(Icons.pause);
        new Timer.periodic(new Duration(milliseconds: 250), updateTime);
      }
    });
  }

  void updateTime(Timer timer){
    int milliseconds = stopwatch.elapsedMilliseconds;
    final int seconds = (milliseconds / 1000).truncate();
    if(seconds >= 1){
      time.seconds = time.seconds - seconds;
      if(time.seconds < 0){
        time.seconds = 59;
        time.minutes--;
      }if(time.minutes < 0){
        time.minutes = 59;
        time.hours--;
      }
      stopwatch.reset();


      Time newTime = new Time(
        hours:time.hours,
        minutes:time.minutes,
        seconds:time.seconds,
      );
      if(time.seconds == 0 && time.minutes == 0 && time.hours == 0){
        if(!_setNewTime()){
          if(repeat){
            //call time again to refresh timer;
            ap = audioCache.play(audioPath);
            currentLoopLocation = 0;
            _setNewTime();

          }else {
            ap = audioCache.loop(audioPath);
            timerHasFinished = true;
            timer.cancel();
          }
        }


      }
      for (final listener in timerListeners) {
        listener(newTime);
      }
    }

  }

  bool _setNewTime(){
    if(currentLoopLocation < times.length){
      if(currentLoopLocation != 0){
        ap = audioCache.play(audioPath);
      }
      var regValues = regExp.allMatches(times[currentLoopLocation]);
      List<String> timerList = [];
      for(var i in regValues){
        String x = i.group(0);
        timerList.add(x);
      }

      int hours = int.parse(timerList[0]);
      int minutes = int.parse(timerList[1]);
      int seconds = int.parse(timerList[2]);
      time = new Time(hours:hours,minutes:minutes,seconds:seconds);
      currentLoopLocation++;
      return true;
    }else{
      return false;
    }

  }

  void _addVarTime() {
    setState(() {
      var regValues = regExp.allMatches(timeController.text.padLeft(6, '0'));
      List<String> timerList = [];
      for(var i in regValues){
        String x = i.group(0);
        timerList.add(x);
      }

      String hours = timerList[0];
      String minutes = timerList[1];
      String seconds = timerList[2];
      times.add('$hours:$minutes:$seconds');
      textController.text = "";
      for(String time in times){
        textController.text += time + '\n';
      }
    });
  }
}