import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';

import './LiveFeed.dart';
import './Box.dart';

List<CameraDescription> cameras;

Future<Null> main() async
{
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error: $e.code\nError Message: $e.message'); //error message
  }
  runApp(
    MaterialApp(
      title: 'ML with tflite model',
      home: FlutterTeachable(cameras),
    ),
  );
}

class FlutterTeachable extends StatefulWidget {
  final List<CameraDescription> cameras;
  FlutterTeachable(this.cameras); // use camera
  @override
  _FlutterTeachableState createState() => _FlutterTeachableState();
}

class _FlutterTeachableState extends State<FlutterTeachable> {
  // for the photo analysis standard settings
  bool liveFeed = false;

  List<dynamic> _recognitions;
  int _imageHeight = 0;
  int _imageWidth = 0;

  bool _load = false;
  File _pic;
  List _result;
  String _confidence = "";
  String _fingers = "";

  String numbers = '';

  @override
  void dispose() {
    super.dispose();
    Tflite.close();
  }
  @override
  void initState() {
    super.initState();

    _load = true;

    loadMyModel().then((v){
      setState(() {
        _load = false;
      });
    });

  }

  loadMyModel() async
  {
    //leave the ML tflite file and the lables from the correct folder
    var res = await Tflite.loadModel(
      labels: "assets/labels.txt",
      model: "assets/model_unquant.tflite"
    );

    print("Result is : $res");

  }

  chooseImage() async
  {
    // take the picture
    File _img = await ImagePicker.pickImage(source: ImageSource.camera);

    if(_img == null) return;

    setState(() {
      _load = true;
      _pic = _img;
      applyModelonImage(_pic);
    });
  }

  applyModelonImage(File file) async
  {
    // load the model and check which how much confidence each label has
    var _res = await Tflite.runModelOnImage(
      // load the model
      path: file.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5
    );

    //check the model on the image
    setState(() {
      _load = false;
      _result = _res;
      print(_result);
      String str = _result[0]["label"];
      
      _fingers = str.substring(2);
      _confidence = _result != null ? (_result[0]["confidence"]*100.0).toString().substring(0,2) + "%" : "";

      // print the labels with the percentage
      print(str.substring(2));
      print((_result[0]["confidence"]*100.0).toString().substring(0,2)+"%");
      print("indexed : ${_result[0]["label"]}");
    });
  }

  setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }  

  // in display settings
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("ML with tflite model"),
      ),
      body: !liveFeed ? Center(
        child: ListView(
          children: <Widget>[
            _load ? Container(alignment: Alignment.center,child: CircularProgressIndicator(),)
              : Container(
                width: size.width*0.9,
                height: size.height*0.7,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Center(
                      child: _pic != null ? Image.file(_pic,width: size.width*0.6,) : Container(),
                    ),
                    _result == null ? Container()
                          : Text("$_fingers\nConfidence: $_confidence"), //print the surest answer
                  ],
                ),
              )
          ],
        ),
      )
      : Stack(
              children: [
                CameraLiveScreen(
                  widget.cameras,
                  setRecognitions,
                ),
                EnclosedBox(
                    _recognitions == null ? [] : _recognitions,
                    math.max(_imageHeight  ,_imageWidth),
                    math.min(_imageHeight, _imageWidth),
                    size.height,
                    size.width,
                ),
              ],
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            RaisedButton(
              child: Text("Image"), // test with image
              onPressed: (){
                setState(() {
                  liveFeed = false; // livefeed off
                });
                chooseImage();
              },
            ),
            RaisedButton(
              child: Text("Live"), // test in live 
              onPressed: () {
                setState(() {
                  liveFeed = true; // livefeed on
                });
                loadMyModel();
              },
            ),
          ],
        ),
      ),
    );
  }
}
