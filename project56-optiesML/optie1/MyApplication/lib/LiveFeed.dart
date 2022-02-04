import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'package:tflite/tflite.dart';

typedef void Callback(List<dynamic> list, int h, int w);

class CameraLiveScreen extends StatefulWidget {
  
  final List<CameraDescription> cameras;
  final Callback setRecognitions;

  CameraLiveScreen(this.cameras,this.setRecognitions);

  @override
  _CameraLiveScreenState createState() => _CameraLiveScreenState();
}

class _CameraLiveScreenState extends State<CameraLiveScreen> {

  CameraController controller;
  bool isDetecting = false;


    @override
  void initState() {
    super.initState();
    // error message if a camera can be used
    if (widget.cameras == null || widget.cameras.length < 1) {
      print('No camera is found');
    } else {
      controller = new CameraController(
        widget.cameras[1], // 0 back 1 front
        ResolutionPreset.low, // quality camera
      );
      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});

        // start camera
        controller.startImageStream((CameraImage img) {
          if (!isDetecting) {
            isDetecting = true;

            int startTime = new DateTime.now().millisecondsSinceEpoch;

              //settings for running the TfLite model
              Tflite.runModelOnFrame(
                bytesList: img.planes.map((plane) {
                  return plane.bytes;
                }).toList(),
                imageHeight: img.height,
                imageWidth: img.width,
                numResults: 1, // number of views in live feed (so both or only the highest)
              ).then((recognitions) {
                //how long is the break
                int endTime = new DateTime.now().millisecondsSinceEpoch;
                print("Detection took ${endTime - startTime}");

                widget.setRecognitions(recognitions, img.height , img.width);

                isDetecting = false;
              });
          }
        });
      });
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller.value.isInitialized) {
      return Container();
    }

    // large of the display of the camera preview
    var tmp = MediaQuery.of(context).size;
    var screenH = math.max(tmp.height, tmp.width);
    var screenW = math.min(tmp.height, tmp.width);
    tmp = controller.value.previewSize;
    var previewH = math.max(tmp.height, tmp.width);
    var previewW = math.min(tmp.height, tmp.width);
    var screenRatio = screenH / screenW;
    var previewRatio = previewH +100 / previewW;

    return OverflowBox(
      maxHeight:
          screenRatio > previewRatio ? screenH : screenW / previewW * previewH,
      maxWidth:
          screenRatio > previewRatio ? screenH / previewH * previewW : screenW,
      child: CameraPreview(controller),
    );
  }
}
