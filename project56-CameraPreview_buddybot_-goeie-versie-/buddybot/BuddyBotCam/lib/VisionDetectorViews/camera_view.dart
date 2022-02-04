import 'dart:io';

import 'package:buddy_bot_cam/ML/ML.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'face_detector_view.dart';

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
  File? _image;
  ImagePicker? _imagePicker;
  int _cameraIndex = 0;
  double zoomLevel = 0.0, minZoomLevel = 0.0, maxZoomLevel = 0.0;

  get gameStageBloc => null;
  bool get isPlaying => _controller1?.isActive ?? false;
  Artboard? _riveArtboard;
  late RiveAnimationController _controller1;

  String lastPlayedAnimation = "nothing";




  @override
  void initState() {
    super.initState();
    rootBundle.load('assets/selfmade_eye.riv').then(
          (data) async {
        // Load the RiveFile from the binary data.
        final file = RiveFile.import(data);

        // The artboard is the root of the animation and gets drawn in the
        // Rive widget.
        final artboard = file.mainArtboard;
        setState(() => _riveArtboard = file.mainArtboard
          ..addController(
              SimpleAnimation('Mid-mid')
          ));

        setState(() => _riveArtboard = artboard);
      },
    );
    _imagePicker = ImagePicker();
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
      // appBar: AppBar(
      //   title: Text(widget.title),
      //   actions: [
      //     Padding(
      //       padding: EdgeInsets.only(right: 20.0),
      //       child: GestureDetector(
      //         onTap: _switchScreenMode,
      //         child: Icon(
      //           _mode == ScreenMode.liveFeed
      //               ? Icons.photo_library_outlined
      //               : (Platform.isIOS
      //               ? Icons.camera_alt_outlined
      //               : Icons.camera),
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
      body: _body(),
      floatingActionButton: _floatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget? _floatingActionButton() {
    if (_mode == ScreenMode.gallery) return null;
    if (cameras.length == 1) return null;
    return Container(
        height: 70.0,
        width: 70.0,
        child: FloatingActionButton(
          child: Icon(
            Platform.isIOS
                ? Icons.flip_camera_ios_outlined
                : Icons.flip_camera_android_outlined,
            size: 40,
          ),
          onPressed: _switchLiveCamera,
        ));
  }

  Widget _body() {
    Widget body;
    if (_mode == ScreenMode.liveFeed)
      body = _liveFeedBody();

    else
      body = _galleryBody();
    return body;
  }

  Widget _liveFeedBody() {
    if (_controller?.value.isInitialized == false) {
      return Container();
    }
    //double width;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    //var padding = MediaQuery.of(context).viewPadding;
    //double height1 = height - padding.top - padding.bottom;
    //double height3 = height - padding.top - kToolbarHeight;

    return Container(
      // color: Colors.black,
        child: Center(
          child: Column(
            children: [
              Container(
                  width: 200,
                  height: 200,
                  child: Row(
                    children: <Widget>[
                      CameraPreview(_controller!),
                      if (widget.customPaint != null) widget.customPaint!,
                      Positioned(
                        bottom: 100,
                        left: 50,
                        right: 50,
                        child: Slider(
                          value: zoomLevel,
                          min: minZoomLevel,
                          max: maxZoomLevel,
                          onChanged: (newSliderValue) {
                            setState(() {
                              zoomLevel = newSliderValue;
                              _controller!.setZoomLevel(zoomLevel);
                            });
                          },
                          divisions: (maxZoomLevel - 1).toInt() < 1
                              ? null
                              : (maxZoomLevel - 1).toInt(),
                        ),
                      )
                    ],
                  )
              ),

              Container(

                width: width,
                height: height - 300.0,
                child: faceFollower(),
              ),
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
                        onPressed: () {

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

  Widget _galleryBody() {
    return ListView(shrinkWrap: true, children: [
      _image != null
          ? Container(
        height: 400,
        width: 400,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image.file(_image!),
            if (widget.customPaint != null) widget.customPaint!,
          ],
        ),
      )
          : Icon(
        Icons.image,
        size: 200,
      ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton(
          child: Text('From Gallery'),
          onPressed: () => _getImage(ImageSource.gallery),
        ),
      ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton(
          child: Text('Take a picture'),
          onPressed: () => _getImage(ImageSource.camera),
        ),
      ),
    ]);
  }

  Future _getImage(ImageSource source) async {
    final pickedFile = await _imagePicker?.getImage(source: source);
    if (pickedFile != null) {
      _processPickedFile(pickedFile);
    } else {
      print('No image selected.');
    }
    setState(() {});
  }

  void _switchScreenMode() async {
    if (_mode == ScreenMode.liveFeed) {
      _mode = ScreenMode.gallery;
      await _stopLiveFeed();
    } else {
      _mode = ScreenMode.liveFeed;
      await _startLiveFeed();
    }
    setState(() {});
  }

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
      _controller?.getMinZoomLevel().then((value) {
        zoomLevel = value;
        minZoomLevel = value;
      });
      _controller?.getMaxZoomLevel().then((value) {
        maxZoomLevel = value;
      });
      _controller?.startImageStream(_processCameraImage);
      setState(() {});
    });
  }

  Future _stopLiveFeed() async {
    await _controller?.stopImageStream();
    await _controller?.dispose();
    _controller = null;
  }

  Future _switchLiveCamera() async {
    if (_cameraIndex == 0)
      _cameraIndex = 1;
    else
      _cameraIndex = 0;
    await _stopLiveFeed();
    await _startLiveFeed();
  }

  Future _processPickedFile(PickedFile pickedFile) async {
    setState(() {
      _image = File(pickedFile.path);
    });
    final inputImage = InputImage.fromFilePath(pickedFile.path);
    widget.onImage(inputImage);
  }

  Widget faceFollower() {
    if (_riveArtboard != null) {
      print(xWord);
      print(yWord);

      if(xWord == "Links"){
        if(yWord == "Boven" && lastPlayedAnimation != "Top-left"){
          _riveArtboard!.artboard..addController(SimpleAnimation('Top-left'));
          lastPlayedAnimation = "Top-left";
        }
        if(yWord == "Midden" && lastPlayedAnimation != "Mid-left"){
          _riveArtboard!.artboard..addController(SimpleAnimation('Mid-left'));
          lastPlayedAnimation = "Mid-left";
        }
        if(yWord == "Onder" && lastPlayedAnimation != "Bottom-left"){
          _riveArtboard!.artboard..addController(SimpleAnimation('Bottom-left'));
          lastPlayedAnimation = "Bottom-left";
        }
      }
      if(xWord == "Midden" && lastPlayedAnimation != "Top-mid"){
        if(yWord == "Boven"){
          _riveArtboard!.artboard..addController(SimpleAnimation('Top-mid'));
          lastPlayedAnimation = "Top-mid";
        }
        if(yWord == "Midden" && lastPlayedAnimation != "Mid-mid"){
          _riveArtboard!.artboard..addController(SimpleAnimation('Mid-mid'));
          lastPlayedAnimation = "Mid-Mid";
        }
        if(yWord == "Onder" && lastPlayedAnimation != "Bottom-mid"){
          _riveArtboard!.artboard..addController(SimpleAnimation('Bottom-mid'));
          lastPlayedAnimation = "Bottom-mid";
        }
      }
      if(xWord == "Rechts" && lastPlayedAnimation != "Top-right"){
        if(yWord == "Boven"){
          _riveArtboard!.artboard..addController(SimpleAnimation('Top-right'));
          lastPlayedAnimation = "Top-right";
        }
        if(yWord == "Midden" && lastPlayedAnimation != "Mid-right"){
          _riveArtboard!.artboard..addController(SimpleAnimation('Mid-right'));
          lastPlayedAnimation = "Mid-right";
        }
        if(yWord == "Onder" && lastPlayedAnimation != "Bottom-right"){
          _riveArtboard!.artboard..addController(SimpleAnimation('Bottom-right'));
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

    /*final camera = cameras[_cameraIndex];
    final imageRotation =
        InputImageRotationMethods.fromRawValue(camera.sensorOrientation) ??
            InputImageRotation.Rotation_0deg;*/

    //  quick fix to make it (only) work in landscape mode
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
