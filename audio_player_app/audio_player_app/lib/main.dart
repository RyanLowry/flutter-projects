import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

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

class FileManager{
  FileManager();

  Future<String> getStorageDir() async{
    var dir = await getExternalStorageDirectory();
    return dir.toString();
  }
}

class AudioManager{
  final AudioPlayer audioplayer = new AudioPlayer();
  final FileManager filemanager = new FileManager();
  List<String> songs = [];
  int currentSong = 0;
  bool hasStarted = false;
  bool paused = false;
  ValueNotifier<bool> hasFiles = ValueNotifier(false);
  // storage/emulated/0/Music/ -- internal storage for android Music location.
  String audioPath = "storage/emulated/0/Music/";
  int songDuration;
  Duration currentDuration;

  AudioManager(){
    checkPermissions();
    new Directory(audioPath).list().listen((entity){
      if(FileSystemEntity.isFileSync(entity.path) == true){
        songs.add(entity.path);
      }


    },onDone:(){
      hasFiles.notifyListeners();
    });
    audioplayer.onAudioPositionChanged.listen((pos){
      currentDuration = pos;
    });
    audioplayer.onPlayerCompletion.listen((event) {
      nextSong();
    });
  }

  void checkPermissions() async{
    PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
    if (permission == PermissionStatus.denied){
      Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    }
  }
  void playAudio() async {
    if(paused){
      await audioplayer.resume();
    }else{
      await audioplayer.play(songs[currentSong],isLocal:true);
      await audioplayer.getDuration().then((value){
        songDuration = value;
      });
    }
    paused = false;
  }
  void pauseAudio() async {
    paused = true;
    await audioplayer.pause();

  }
  void replaySong() async {
    await audioplayer.stop();
    await audioplayer.resume();

  }
  void nextSong() async {
    currentSong++;
    if(currentSong > songs.length - 1){
      currentSong = 0;
    }
    await audioplayer.stop();
    await audioplayer.play(songs[currentSong],isLocal:true);

  }
  void previousSong() async {
    currentSong--;
    if(currentSong < 0){
      currentSong = songs.length - 1;
    }
    await audioplayer.stop();
    await audioplayer.play(songs[currentSong],isLocal:true);

  }
  void seekSong(seekValue) async {
    double position = (songDuration * seekValue);
    audioplayer.seek(Duration(milliseconds: position.round()));

  }
  int getDuration(){
    return songDuration;
  }
  double getCurrDuration(){
    if(currentDuration == null || songDuration == null){
      return 0.0;
    }else{
      return currentDuration.inMilliseconds / songDuration;
    }

  }

  void setSong(int song) {
    currentSong = song - 1;
    nextSong();
  }

  void setVolume(double vol){
    audioplayer.setVolume(vol);
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
          MusicListWidget(man:man),
          MusicPlayerWidget(man:man),
          MusicTimerWidget(man:man),
        ],
      ),
    );
  }
}

class MusicListWidget extends StatefulWidget{
  final AudioManager man;
  MusicListWidget({Key key,this.man}) : super(key : key);

  @override
  _MusicListWidgetState createState() => _MusicListWidgetState();
}
class _MusicListWidgetState extends State<MusicListWidget>{
  var listMusic = List<ListTile>();

  @override
  void initState() {
    widget.man.hasFiles.addListener((){
      updateWidget();
    });
    super.initState();
  }
  //Will not update widget if not here.
  @override
  void didUpdateWidget(MusicListWidget oldWidget) {
    setState(() {

    });
    super.didUpdateWidget(oldWidget);
  }
  updateWidget(){
    RegExp regExp = new RegExp(
      r"(?<=\/)[^\/]+$",
    );
    for(var i = 0; i < widget.man.songs.length; i++) {
        var song = widget.man.songs[i];
        var songName = regExp.stringMatch(song);
        listMusic.add(new ListTile(
          title: Text(songName),
          onTap: () {
            widget.man.setSong(i);
          },
        ));

    }
  }
  @override
  Widget build(BuildContext context) {
    return Expanded(

      child:
        ListView(

          shrinkWrap: true,
          children: _addWidget(),
        ),

    );
  }
  List<ListTile> _addWidget(){
    if(listMusic.length == 0){
      return new List<ListTile>.generate(1, (int i ){
        return ListTile(
          title:Text("No music in folder"),
        );
      });
    }else{
      return new List<ListTile>.generate(listMusic.length,(int index){
        return listMusic[index];
      });
    }
  }
}

class MusicPlayerWidget extends StatefulWidget{
  final AudioManager man;
  MusicPlayerWidget({Key key, this.man}) : super(key : key);

  _MusicPlayerWidgetState createState() => _MusicPlayerWidgetState();

}

class _MusicPlayerWidgetState extends State<MusicPlayerWidget>{
  bool btnPressed = false;
  Icon btnIcon = Icon(Icons.play_circle_outline);
  double _soundVolume = 1;

  @override
  void initState() {
    widget.man.audioplayer.onPlayerStateChanged.listen((state){
      if(state == AudioPlayerState.PLAYING){
        _setBtnType("play");
      }else if(state == AudioPlayerState.PAUSED || state == AudioPlayerState.STOPPED){
        _setBtnType("pause");
      }
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        IconButton(
          icon:Icon(Icons.arrow_left),
          iconSize: 48,
          onPressed: (){
            widget.man.previousSong();
          },
        ),
        IconButton(
          icon:btnIcon,
          iconSize: 48,
          onPressed: (){
            if(btnPressed){
              widget.man.pauseAudio();
            }else{
              widget.man.playAudio();
            }



          },
        ),
        IconButton(
          icon:Icon(Icons.arrow_right),
          iconSize: 48,
          onPressed: (){
            widget.man.nextSong();
          },
        ),
        Row(
          children: <Widget>[
            Icon(
              Icons.volume_up,
              size:24,
            ),
            Slider(
              min:0,
              max:1,
              value:_soundVolume,
              onChanged: (value){
                setState(() {
                  _soundVolume = value;
                  widget.man.setVolume(value);
                });
              },
            ),
          ],
        )
      ],
    );
  }
  void _setBtnType(btnType){
    setState(() {
      if(btnType == "pause"){
        btnIcon = Icon(Icons.play_circle_outline);


      }else{
        btnIcon = Icon(Icons.pause_circle_outline);


      }
      btnPressed = !btnPressed;
    });

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
  @override
  initState(){
    super.initState();
    new Timer.periodic(new Duration(seconds:1), setSlider);
  }
  void setSlider(Timer timer){
    double dur = widget.man.getCurrDuration();
    setState(() {
      // <min or >max, set default value. Prevents widget from breaking.
      if(dur < 0 || dur > 1 || dur == null){
        _value = 0;
      } else{
        _value = widget.man.getCurrDuration();
      }

    });
  }
}