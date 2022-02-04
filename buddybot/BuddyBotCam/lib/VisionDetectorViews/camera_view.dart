import 'dart:io';
import 'package:buddy_bot_cam/ML/ML.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'face_detector_view.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';
import 'package:rive/rive.dart';
import '../main.dart';

enum ScreenMode { liveFeed, gallery }

class CameraView extends StatefulWidget {
  CameraView(
      {Key? key,
        required this.title,
        required this.customPaint,
        required this.onImage,
        this.initialDirection = CameraLensDirection.back})
      : super(key: key);
  final String title;
  final CustomPaint? customPaint;
  final Function(InputImage inputImage) onImage;
  final CameraLensDirection initialDirection;
  FaceDetector faceDetector = GoogleMlKit.vision.faceDetector();

  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  ScreenMode _mode = ScreenMode.liveFeed;
  CameraController? _controller;
  int _cameraIndex = 0;
  bool get isPlaying => _controller1.isActive;
  Artboard? _riveArtboard;
  late RiveAnimationController _controller1;
  String lastPlayedAnimation = "nothing";

  @override
  void initState() {
    super.initState(); //loads the rive file from assets folder
    rootBundle.load('assets/selfmade_eye.riv').then(
          (data) async {
        // Load the RiveFile from the binary data.
        final file = RiveFile.import(data);
        // The artboard is the root of the animation and gets drawn in the
        final artboard = file.mainArtboard;
        setState(() => _riveArtboard = file.mainArtboard // set the first state of the animation to be Mid-mid
          ..addController(
              SimpleAnimation('Mid-mid')
          ));
        setState(() => _riveArtboard = artboard);
      },
    );
    // Camera view for testing how the eyes follows you
    for (var i = 0; i < cameras.length; i++) { 
      if (cameras[i].lensDirection == widget.initialDirection) {
        _cameraIndex = i;
      }
    }
    _startLiveFeed();
  }

  @override
  void dispose() {
    _stopLiveFeed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
  Widget _body() {
    Widget body;
      body = _liveFeedBody();
    return body;
  }

  Widget _liveFeedBody() {
    if (_controller?.value.isInitialized == false) {
      return Container();
    }
    //checks the width and height from every device (may need improvement)!
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Container(
        child: Center(
          child: Column(
            children: [
              //change width and height for the camera preview size
              Container(
                  width: 0,
                  height: 0,
                  child: Row(
                    children: <Widget>[
                      CameraPreview(_controller!),
                    ],
                  )
              ),
              // container which shows the animations of the eyes (Rive animations) with the corresponding width and height
              Container(
                width: width,
                height: height - 100,
                child: faceFollower(),
              ),
              // container that prints out the answers and variables of the X value, Y value, Postion and LastPlayedAnimation
              Container(
                child: Center(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                        child: Text('X value: ' + x.toString(), style: TextStyle(fontSize: 15.0, color: Colors.black)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                        child: Text('Y value: ' + y.toString(), style: TextStyle(fontSize: 15.0, color: Colors.black)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                        child: Text(xWord + ' ' + yWord, style: TextStyle(fontSize: 15.0, color: Colors.black)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                        child: Text(lastPlayedAnimation, style: TextStyle(fontSize: 15.0, color: Colors.black)),
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          //when button is pushed go the ML (pose detection)
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => ML()),
                          );
                          debugPrint('Received click: Start Event');
                        },
                        child: const Text('Start Event'),
                      ),
                    ],
                  ),
                )
              )
            ],
          ),
        )
    );
  }
  //function to start the camera preview
  Future _startLiveFeed() async {
    final camera = cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      ResolutionPreset.low,
      enableAudio: false,
    );
    _controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _controller?.startImageStream(_processCameraImage);
      setState(() {});
    });
  }
  //function to stop the camera preview
  Future _stopLiveFeed() async {
    await _controller?.stopImageStream();
    await _controller?.dispose();
    _controller = null;
  }

  
  Widget faceFollower() {
    if (_riveArtboard != null) {
      // print face location in the terminal
      print(xWord);
      print(yWord);
      // if functions that plays the animations to the corresponding locations that has been detected with 1 second delay between each
      if(xWord == "Links") {
        if (yWord == "Boven" && lastPlayedAnimation != "Top-left") {
          //calls the animation with one second delay and assign the lastplayed animation
          Timer(Duration(seconds: 1),(){
          _riveArtboard!.artboard..addController(SimpleAnimation('Top-left')); 
          });
          lastPlayedAnimation = "Top-left";
        }
        if (yWord == "Midden" && lastPlayedAnimation != "Mid-left") {
          Timer(Duration(seconds: 1),(){
          _riveArtboard!.artboard..addController(SimpleAnimation('Mid-left'));
          });
          lastPlayedAnimation = "Mid-left";
        }
        if (yWord == "Onder" && lastPlayedAnimation != "Bottom-left") {
          Timer(Duration(seconds: 1),(){//});
            _riveArtboard!.artboard
              ..addController(SimpleAnimation('Bottom-left'));
          });
            lastPlayedAnimation = "Bottom-left";
        }
      }
      if(xWord == "Midden" ){
        if(yWord == "Boven" && lastPlayedAnimation != "Top-mid"){
          Timer(Duration(seconds: 1),(){
          _riveArtboard!.artboard..addController(SimpleAnimation('Top-mid'));
        });
          lastPlayedAnimation = "Top-mid";
        }
        if(yWord == "Midden" && lastPlayedAnimation != "Mid-mid"){
          Timer(Duration(seconds: 1),(){
          _riveArtboard!.artboard..addController(SimpleAnimation('Mid-mid'));
          });
          lastPlayedAnimation = "Mid-Mid";
        }
        if(yWord == "Onder" && lastPlayedAnimation != "Bottom-mid"){
          Timer(Duration(seconds: 1),(){
          _riveArtboard!.artboard..addController(SimpleAnimation('Bottom-mid'));
        });
          lastPlayedAnimation = "Bottom-mid";
        }
      }
      if(xWord == "Rechts"){
        if(yWord == "Boven" && lastPlayedAnimation != "Top-right"){
          Timer(Duration(seconds: 1),(){
          _riveArtboard!.artboard..addController(SimpleAnimation('Top-right'));
          });
          lastPlayedAnimation = "Top-right";
        }
        if(yWord == "Midden" && lastPlayedAnimation != "Mid-right"){
          Timer(Duration(seconds: 1),(){
          _riveArtboard!.artboard..addController(SimpleAnimation('Mid-right'));
          });
          lastPlayedAnimation = "Mid-right";
        }
        if(yWord == "Onder" && lastPlayedAnimation != "Bottom-right"){
          Timer(Duration(seconds: 1),(){
          _riveArtboard!.artboard..addController(SimpleAnimation('Bottom-right'));
          });
          lastPlayedAnimation = "Bottom-right";
        }
      }
      return Rive(
        artboard: _riveArtboard!,
        fit: BoxFit.cover,
      );
    } else {
      return Container();
    }
  }

  Future _processCameraImage(CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
    Size(image.width.toDouble(), image.height.toDouble());

    final imageRotation = InputImageRotation.Rotation_0deg;

    final inputImageFormat =
        InputImageFormatMethods.fromRawValue(image.format.raw) ??
            InputImageFormat.NV21;

    final planeData = image.planes.map(
          (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    final inputImage =
    InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

    widget.onImage(inputImage);
  }
}
