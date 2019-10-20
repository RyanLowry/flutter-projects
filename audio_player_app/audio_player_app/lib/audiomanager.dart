import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class AudioManager{
  final AudioPlayer audioPlayer = new AudioPlayer();
  List<String> songs = [];
  int currentSong = 0;
  bool hasStarted = false;
  bool paused = false;
  ValueNotifier<bool> hasFiles = ValueNotifier(false);
  // storage/emulated/0/Music/ -- internal storage for android Music location.
  String audioPath = "storage/emulated/0/Music/";
  Duration songDuration;
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

    audioPlayer.onAudioPositionChanged.listen((pos){
      currentDuration = pos;
    });
    audioPlayer.onPlayerCompletion.listen((event) {
      nextSong();
    });
    audioPlayer.onDurationChanged.listen((dur) {
      songDuration = dur;
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
      await audioPlayer.resume();
    }else{
      await audioPlayer.play(songs[currentSong],isLocal:true);
    }
    paused = false;
  }
  void pauseAudio() async {
    paused = true;
    await audioPlayer.pause();

  }
  void nextSong() async {
    currentSong++;
    if(currentSong > songs.length - 1){
      currentSong = 0;
    }
    await audioPlayer.play(songs[currentSong],isLocal:true);


  }
  void previousSong() async {
    currentSong--;
    if(currentSong < 0){
      currentSong = songs.length - 1;
    }
    await audioPlayer.play(songs[currentSong],isLocal:true);

  }
  void seekSong(seekValue) async {
    double position = (songDuration.inMilliseconds * seekValue);
    audioPlayer.seek(Duration(milliseconds: position.round()));

  }
  double getCurrDuration(){
    if(currentDuration == null || songDuration == null){
      return 0.0;
    }else{
      return currentDuration.inMilliseconds / songDuration.inMilliseconds;
    }

  }

  void setSong(int song) {
    currentSong = song - 1;
    nextSong();
  }

  void setVolume(double vol){
    audioPlayer.setVolume(vol);
  }



}