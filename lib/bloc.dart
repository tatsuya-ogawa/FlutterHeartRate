import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:lamp/lamp.dart';
import 'dart:async';

class MeasureData {
  final int timestamp;
  final double heartRate;

  MeasureData(this.timestamp, this.heartRate);
}

class CameraBlock {
  static const  _maxListLength = 1024;
  List<MeasureData> dataList = new List<MeasureData>();
  final _cameraInitializeController = StreamController<bool>();

  Stream<bool> get cameraInitializeStream => _cameraInitializeController.stream;
  final _heartRateController = StreamController<MeasureData>();

  Stream<MeasureData> get heartRateStream => _heartRateController.stream;
  final _measuringController = StreamController<bool>();

  Stream<bool> get isMeasuringStream => _measuringController.stream;

  CameraController camera;
  bool _isDetecting = false;
  bool _measuring = false;

  CameraLensDirection _direction = CameraLensDirection.back;

  Future<CameraDescription> _getCamera(CameraLensDirection dir) async {
    return await availableCameras().then(
          (List<CameraDescription> cameras) => cameras.firstWhere(
            (CameraDescription camera) => camera.lensDirection == dir,
      ),
    );
  }

  void initializeCamera() async {
    camera = CameraController(
      await _getCamera(_direction),
      defaultTargetPlatform == TargetPlatform.iOS
          ? ResolutionPreset.low
          : ResolutionPreset.medium,
    );
    await camera.initialize();
    //FIXME
    _cameraInitializeController.sink.add(true);
    camera.startImageStream((CameraImage image) async {
      if (_isDetecting) return;
      _isDetecting = true;
      try {
        //FIXME
        // await doSomethingWith(image)
        if (_measuring) {
          var now = DateTime.now().millisecondsSinceEpoch;
          var h = await compute(computeHeartRate, image);
          var data = MeasureData(now, h);
          if(dataList.length >= _maxListLength){
            dataList.removeAt(0);
          }
          dataList.add(data);
          _heartRateController.sink.add(data);
        }
      } catch (e) {
        // await handleExepction(e)
      } finally {
        _isDetecting = false;
      }
    });
  }

  static Future<double> computeHeartRate(CameraImage image) async {
    if (Platform.isIOS) {
      double h = 0.0;
      if (image.planes.length == 1) {
        final plane = image.planes.first;
        final double div = plane.bytes.length / 4;
        for (var i = 0; i < plane.bytes.length; i += 4) {
          final R = plane.bytes[i];
          final G = plane.bytes[i + 1];
          final B = plane.bytes[i + 2];
          final H = atan2((0.5 * R - 0.419 * G - 0.081 * B),
              (-0.169 * R - 0.331 * G + 0.5 * B));
          h += H / div / pi;
        }
      }
      return h;
    } else {
      //FIXME
      return 0.0;
    }
  }

  void dispose() {
    _heartRateController.close();
    _cameraInitializeController.close();
    _measuringController.close();
  }
}

class HeartRateBloc with CameraBlock {
  final _buttonController = StreamController<void>();

  Sink<void> get toggleRunningSink => _buttonController.sink;

  HeartRateBloc() {
    initializeCamera();
    _buttonController.stream.listen((event) {
      if (_measuring) {
        Lamp.turnOff();
      } else {
        Lamp.turnOn(intensity: 1.0);
      }
      _measuring = !_measuring;
      _measuringController.sink.add(_measuring);
    });
  }

  void dispose() {
    super.dispose();
    _measuringController.close();
  }
}
