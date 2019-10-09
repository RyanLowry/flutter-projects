import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:audioplayers/audio_cache.dart';
import 'time.dart';

class TimerWidget extends StatefulWidget{
  @override
  _TimerWidgetState createState() => _TimerWidgetState();
}


class _TimerWidgetState extends State<TimerWidget>{
  final audioPath = "quick-alarm.WAV";
  Future<AudioPlayer> ap;
  final textController = new TextEditingController();
  var time = new Time();
  final List<ValueChanged<Time>> timerListeners = <ValueChanged<Time>>[];
  final Stopwatch stopwatch = new Stopwatch();
  final regExp = new RegExp(
    r"\d{2}",
  );
  final txtStyle = TextStyle(fontSize:24,);
  Icon btnIcon = Icon(Icons.play_arrow);
  int hrs = 0;
  int mins = 0;
  int secs = 0;
  bool timerHasStarted = false;
  AudioCache audioCache = new AudioCache();
  bool timerWentOff = false;



  @override
  Widget build(BuildContext context) {
    String hours = hrs.toString().padLeft(2,'0');
    String minutes = mins.toString().padLeft(2,'0');
    String seconds = secs.toString().padLeft(2,'0');
    return new Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children:[
        !timerHasStarted ? TextField(
          decoration: new InputDecoration(hintText: "00:00:00"),
          controller: textController,
          keyboardType: TextInputType.number,
          style: txtStyle,
          textAlign: TextAlign.center,
          maxLength: 6,
          onChanged: (text){
            var regValues = regExp.allMatches(text.padLeft(6, '0'));

            List<int> timerList = [];
            for(var i in regValues){
              String x = i.group(0);
              timerList.add(int.parse(x));
            }

            time.hours = timerList[0];
            time.minutes = timerList[1];
            time.seconds = timerList[2];
          },
          onSubmitted: (text){
            var regValues = regExp.allMatches(text.padLeft(6, '0'));

            List<int> timerList = [];
            for(var i in regValues){
              String x = i.group(0);
              timerList.add(int.parse(x));
            }

            time.hours = timerList[0];
            time.minutes = timerList[1];
            time.seconds = timerList[2];


          },

        ):
        Text(
          '$hours:$minutes:$seconds',
          style:txtStyle,
          textAlign: TextAlign.center,
        ),
        IconButton(
          iconSize: 48,
          icon:btnIcon,
          onPressed: (){
            _startTimer();
          },
        )
      ],
    );
  }
  @override
  void initState() {
    super.initState();
    timerListeners.add(onTick);

  }

  void onTick(Time time){
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
      if(timerWentOff){
        ap.then((value){
          value.stop();
        });
        timerWentOff = false;
      }
      if(stopwatch.isRunning){
        stopwatch.stop();
        timerHasStarted = false;
        btnIcon = Icon(Icons.play_arrow);
        String hours = hrs.toString().padLeft(2,"0");
        String minutes = mins.toString().padLeft(2,"0");
        String seconds = secs.toString().padLeft(2,"0");
        textController.text = "$hours$minutes$seconds";

      }else{
        stopwatch.start();
        timerHasStarted = true;
        btnIcon = Icon(Icons.pause);
        new Timer.periodic(new Duration(milliseconds:250), updateTime);
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

        ap = audioCache.loop(audioPath);
        timerWentOff = true;
        timer.cancel();
      }
      for (final listener in timerListeners) {
        listener(newTime);
      }
    }

  }
}