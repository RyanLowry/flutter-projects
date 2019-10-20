import 'package:flutter/material.dart';
import 'audiomanager.dart';

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
    // regex finds characters after a slash.
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
    //will throw error if not generated.
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