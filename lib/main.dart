import 'package:flutter/material.dart';
import 'timer_widget.dart';
import 'stopwatch_widget.dart';
import 'variable_timer_widget.dart';


void main() => runApp(MyApp());
class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {


    return MaterialApp(
      title: 'Timer',

      home: Scaffold(
        appBar: AppBar(
          title: Text('Timer'),
        ),
        body: MainWidget(),
      ),
    );
  }
}

class MainWidget extends StatefulWidget{
  @override
  _MainWidgetState createState() => _MainWidgetState();
}
class _MainWidgetState extends State<MainWidget>{
  Widget currentWidget = TimerWidget();
  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).primaryColor;
    Widget buttonSection = Container(
      margin:const EdgeInsets.only(top:20),
      child:Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTimerColumn(color, Icons.access_alarm, 'Timer',TimerWidget()),
          _buildTimerColumn(color, Icons.access_time, 'Stopwatch',StopwatchWidget()),
          _buildTimerColumn(color, Icons.add_alarm, 'Incremental',VariableTimerWidget()),
        ],
      ),
    );

    //Body Build
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buttonSection,
        currentWidget,
        Text(""),
      ],
    );

  }
  Column _buildTimerColumn(Color col, IconData icon, String label,Widget connectedWidget){
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children : [
        IconButton(icon:Icon(icon),color:col, onPressed: () {
          setState(() {
            currentWidget = connectedWidget;
          });

        },),
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
