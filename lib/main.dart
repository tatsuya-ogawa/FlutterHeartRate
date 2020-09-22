import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:lamp/lamp.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'bloc.dart';
import 'graph.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Heart rate',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        home: Provider<HeartRateBloc>(
          create: (context) => HeartRateBloc(),
          dispose: (context, bloc) => bloc.dispose(),
          child: MyHomePage(title: 'HeartRateApp'),
        ));
    //home: MyHomePage(title: 'Flutter Demo Home Page'),);
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  Widget build(BuildContext context) {
    final heartRateBloc = Provider.of<HeartRateBloc>(context);
    // This method is rerun every time setState is called
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            StreamBuilder(
              initialData: false,
              stream: heartRateBloc.cameraInitializeStream,
              builder: (context, snapshot) {
                return (snapshot.data)
                    ? AspectRatio(
                        aspectRatio: heartRateBloc.camera.value.aspectRatio,
                        child: CameraPreview(heartRateBloc.camera),
                      )
                    : CircularProgressIndicator();
              },
            ),
            Container(
              height: 160.0,
              width: double.infinity,
              child: Graph(heartRateBloc),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '指をカメラに押し当ててね!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).accentColor,
                    ),
                  )
                  // Text(
                  //   'Heart Rate:',
                  // ),
                  // StreamBuilder(
                  //   initialData: null,
                  //   stream: heartRateBloc.heartRateStream,
                  //   builder: (context, snapshot) {
                  //     return Text(
                  //       snapshot.data != null
                  //           ? '${snapshot.data.heartRate.toStringAsFixed(10)}'
                  //           : "None",
                  //       style: Theme.of(context).textTheme.display1,
                  //     );
                  //   },
                  // )
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            heartRateBloc.toggleRunningSink.add(null);
          },
          tooltip: 'Calculate',
          child: StreamBuilder(
              initialData: false,
              stream: heartRateBloc.isMeasuringStream,
              builder: (context, snapshot) {
                return (snapshot.data != null && snapshot.data)
                    ? Text('Stop')
                    : Text('Start');
              })
          //Icon(Icons.add),
          ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
