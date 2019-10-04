import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).primaryColor;
    Widget buttonSection = Container(
      margin:const EdgeInsets.only(top:20),
      child:Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTimerColumn(color, Icons.access_alarm, 'Timer'),
          _buildTimerColumn(color, Icons.access_time, 'Stopwatch'),
          _buildTimerColumn(color, Icons.add_alarm, 'Incremental'),
        ],
      ),
    );


    return MaterialApp(
      title: 'Timer',

      home: Scaffold(
        appBar: AppBar(
          title: Text('Welcome to Flutter'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buttonSection,
            VariableTimerWidget(),
            Text(""),
          ],
        ),
      ),
    );
  }

  Column _buildTimerColumn(Color col, IconData icon, String label){
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children : [
        Icon(icon,color:col),
        Container(
          margin: const EdgeInsets.only(top:8),
          child: Text(
            label,
            style:TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color:col,

            ),
          ),
        ),
      ],
    );
  }
}

class Time{
  int hours;
  int minutes;
  int seconds;

  Time({
    this.hours,
    this.minutes,
    this.seconds,
  });
}

class TimerWidget extends StatefulWidget{
  @override
  _TimerWidgetState createState() => _TimerWidgetState();
}


class _TimerWidgetState extends State<TimerWidget>{
  final textController = new TextEditingController();
  var time = new Time();
  //TODO: Handle single Time changes;
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
            var test = regExp.allMatches(text.padLeft(6, '0'));

            List<int> timerList = [];
            for(var i in test){
              String x = i.group(0);
              timerList.add(int.parse(x));
            }

            time.hours = timerList[0];
            time.minutes = timerList[1];
            time.seconds = timerList[2];
          },
          onSubmitted: (text){
            var test = regExp.allMatches(text.padLeft(6, '0'));

            List<int> timerList = [];
            for(var i in test){
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
      if(stopwatch.isRunning){
        stopwatch.stop();
        timerHasStarted = false;
        btnIcon = Icon(Icons.play_arrow);
        textController.text = "$hrs:$mins:$secs";
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
        //Call sound/alert to play.
        print("Timer is done");
        timerListeners.remove(onTick);
        timer.cancel();
      }
      for (final listener in timerListeners) {
        listener(newTime);
      }
    }

  }


}

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
  final regExp = new RegExp(
    r"\d{2}",
  );
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

class VariableTimerWidget extends StatefulWidget{
  @override
  _VariableTimerWidgetState createState() => _VariableTimerWidgetState();
}


class _VariableTimerWidgetState extends State<VariableTimerWidget> {
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
            currentLoopLocation = 0;
            _setNewTime();

          }else {
            timerListeners.remove(onTick);
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

