import 'dart:convert';

import 'package:buddy_bot_cam/VisionDetectorViews/face_detector_view.dart';
import 'package:flutter/material.dart';
//import 'package:permission_handler/permission_handler.dart';
import 'package:teachable/teachable.dart';
 

class ML extends StatefulWidget {
  // ML({Key? key, required this.title}) : super(key: key);

  late final String title;

  @override
  _MLState createState() => _MLState();

  //await Permission.camera.request();
  //await Permission.microphone.request();
}

class _MLState extends State<ML> {
  int pose1 = 0;
  int pose2 = 0;
  int pose3 = 0;

  String label = "test";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Jouw antwoord")),

        body: Stack(
          children: [
            Container(
                child: Column(children: <Widget>[
              Expanded(
                child: Container(
                  child: Teachable(
                    path: "pose/index.html",
                    results: (res) {
                      var resp = jsonDecode(res);

                      setState(() {
                        pose1 = (resp['Ja'] * 100.0).round();
                        pose2 = (resp['Niks'] * 100.0).round();

                        if (pose1 > pose2) {
                          pose3 = pose1;
                          label = "Yes";
                          //Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => FaceDetectorView()),
                          );
                        }
                        else{
                          pose3 = pose2;
                          label = "Nothing";
                        }
                      });
                    },
                  ),
                ),
              ),
            ])),
            Align(

              alignment: Alignment.bottomCenter,
              child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () {

                              Navigator.pop(context);
                            },
                            child: const Text('Start Event'),
                          ),
                         //ext(
                           //ose3.toString(),
                            //yle: TextStyle(
                           // color: Colors.white,
                           //,
                        //),
                        ]
                      ),
                    ],
                  )),
            )
          ],
        ));
  }

}
