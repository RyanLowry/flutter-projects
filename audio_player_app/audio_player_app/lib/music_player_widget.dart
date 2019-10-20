import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'audiomanager.dart';

//THIS FILE INCLUDES 2 WIDGETS, MusicPlayerWidget and MusicTimerWidget

class MusicPlayerWidget extends StatefulWidget{
  final AudioManager man;
  MusicPlayerWidget({Key key, this.man}) : super(key : key);

  _MusicPlayerWidgetState createState() => _MusicPlayerWidgetState();

}

class _MusicPlayerWidgetState extends State<MusicPlayerWidget>{
  bool _playBtnPressed = false;
  Icon _btnIcon = Icon(Icons.play_circle_outline);
  double _soundVolume = 1;

  @override
  void initState() {
    // Allows widget to set right state after list_widget interaction.
    widget.man.audioPlayer.onPlayerStateChanged.listen((state){
      if(state == AudioPlayerState.PLAYING){
        _setBtnType("play");
      }else if(state == AudioPlayerState.PAUSED){
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
          icon:_btnIcon,
          iconSize: 48,
          onPressed: (){
            if(_playBtnPressed){
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
      //need to specify pressed state or will mess up proper state of btn.
      //cannot do _playBtnPressed = !_playBtnPressed.
      if(btnType == "pause"){
        _btnIcon = Icon(Icons.play_circle_outline);
        _playBtnPressed = false;
      }else{
        _btnIcon = Icon(Icons.pause_circle_outline);
        _playBtnPressed = true;
      }

    });

  }

}

class MusicTimerWidget extends StatefulWidget{
  final AudioManager man;
  MusicTimerWidget({Key key,this.man}) : super(key : key);

  _MusicTimerWidgetState createState() => _MusicTimerWidgetState();

}

class _MusicTimerWidgetState extends State<MusicTimerWidget>{
  double _songPos = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      child:
      Slider(
        min:0,
        max:1,
        value:_songPos,
        onChanged: (value){
          setState(() {
            _songPos = value;
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
        _songPos = 0;
      } else{
        _songPos = dur;
      }

    });
  }
}