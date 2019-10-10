import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Player',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Music Player Page'),
    );
  }
}


class AudioManager{
  AudioPlayer audioplayer = new AudioPlayer();
  List<String> songs = [];
  bool hasStarted = false;
  final audioPath = "placeholder";
  AudioManager(){
  }


  void playAudio() async {
    if(hasStarted){
      await audioplayer.resume();
    }else{
      await audioplayer.play(audioPath,isLocal:true);
    }
  }
  void pauseAudio() async {
    await audioplayer.pause();

  }
  void replaySong() async {
    await audioplayer.stop();
    await audioplayer.resume();

  }
  void nextSong() async {

  }
  void previousSong() async {

  }
  void seekSong(seekValue) async {
    var duration = audioplayer.getDuration();
    duration.then((value){
      double position = (value * seekValue);
      audioplayer.seek(Duration(milliseconds: position.round()));
    });

  }


}


class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final man = AudioManager();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          MusicListWidget(),
          MusicPlayerWidget(man:man),
          MusicTimerWidget(man:man),
        ],
      ),
    );
  }
}

class MusicListWidget extends StatefulWidget{
  MusicListWidget({Key key,}) : super(key : key);

  @override
  _MusicListWidgetState createState() => _MusicListWidgetState();
}
class _MusicListWidgetState extends State<MusicListWidget>{
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListView(
          shrinkWrap: true,
          children: <Widget>[
            ListTile(
              title:Text("test"),
              onTap: (){

              },
            ),
            ListTile(
              title:Text("list"),
              onTap: (){

              },
            ),
          ],
        ),

      ],
    );
  }

}

class MusicPlayerWidget extends StatefulWidget{
  final AudioManager man;
  MusicPlayerWidget({Key key, this.man}) : super(key : key);

  _MusicPlayerWidgetState createState() => _MusicPlayerWidgetState();

}

class _MusicPlayerWidgetState extends State<MusicPlayerWidget>{

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        IconButton(
          icon:Icon(Icons.arrow_left),
          iconSize: 48,
          onPressed: (){
            widget.man.seekSong(0.0);
          },
        ),
        IconButton(
          icon:Icon(Icons.play_circle_outline),
          iconSize: 48,
          onPressed: (){
            widget.man.playAudio();

          },
        ),
        IconButton(
          icon:Icon(Icons.arrow_right),
          iconSize: 48,
          onPressed: (){

          },
        ),
      ],
    );
  }

}

class MusicTimerWidget extends StatefulWidget{
  final AudioManager man;
  MusicTimerWidget({Key key,this.man}) : super(key : key);

  _MusicTimerWidgetState createState() => _MusicTimerWidgetState();

}

class _MusicTimerWidgetState extends State<MusicTimerWidget>{
  double _value = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
      child:
      Slider(
        min:0,
        max:1,
        value:_value,
        onChanged: (value){
          setState(() {
            _value = value;
            widget.man.seekSong(value);
          });

        },
      ),
    );
  }

}