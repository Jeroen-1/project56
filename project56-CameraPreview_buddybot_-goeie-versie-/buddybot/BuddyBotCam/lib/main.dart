import 'dart:io';
import 'ML/ML.dart';
import 'package:camera/camera.dart';
import 'VisionDetectorViews/detector_views.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

List<CameraDescription> cameras = [];
double x = 0;
double y = 0;
String xWord = "Laden...";
String yWord = "";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Permission.camera.request();
  //await Permission.microphone.request();

  cameras = await availableCameras();
  runApp(const MyApp());
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Buddy Bot Demo'),
      //   centerTitle: true,
      //   elevation: 0,
      // ),

      body: SafeArea(
        child: Center(
          child: Row(
            children: [
              // Container (
              //   height: 400,
              //   width: 800,
              //   child: Wrap(
              //     children: <Widget> [
              //       FaceDetectorView(),
              //     ],
              //   )
              // ),
              Container(
                height: 300,
                width: 300,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Wrap(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        CustomCard(
                          'Buddy Bot',
                          FaceDetectorView(),
                          featureCompleted: true,
                        ),
                        CustomCard(
                          'ML',
                          ML(),
                          featureCompleted: true,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final String _label;
  final Widget _viewPage;
  final bool featureCompleted;

  const CustomCard(this._label, this._viewPage,
      {this.featureCompleted = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.only(bottom: 10),
      child: ListTile(
        tileColor: Theme.of(context).primaryColor,
        title: Text(
          _label,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onTap: () {
          if (Platform.isIOS && !featureCompleted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text(
                    'This feature has not been implemented for iOS yet')));
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (context) => _viewPage));
          }
        },
      ),
    );
  }
}
