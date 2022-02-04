import 'dart:convert';
import 'dart:async';
import 'package:buddy_bot_cam/VisionDetectorViews/face_detector_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:teachable/teachable.dart';

class ML extends StatefulWidget {
  late final String title;

  @override
  _MLState createState() => _MLState();
}

class _MLState extends State<ML> {
  // percentage answer 1
  int pose1 = 0;
  // percentage answer 1 
  int pose2 = 0;
  // percentage of the most true answer 
  int pose3 = 0; 
  // waiting until ML loaded
  String label = "Loading";
  // initialize the image 
  String _image = "assets/buddybot_nothing.png"; 

  // function for the corresponding image that needs to be used
  void _setImage() { 
    if(label == 'Yes') {
      _image = "assets/buddy_goedzo.png";
    } 
    else if(label == 'Nothing') {
      _image = "assets/buddybot_nothing.png";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Your answer")),
        body: Stack(
          children: [
            Container(
                child: Row(children: <Widget>[
                  // here you can change allignment and size of the image
                    Image(
                      image:   AssetImage(_image),
                      alignment: Alignment.center,
                      height: 800,
                      width: 800,
                    ),
                  //},
              Expanded(
                child: Container(
                  child: Teachable(
                    // path  to model ml
                    path: "pose/index.html", 
                    results: (res) {
                      var resp = jsonDecode(res);
                      setState(() {
                        //percentage answer 1
                        pose1 = (resp['Ja'] * 100.0).round();
                        //percentage answer 2 
                        pose2 = (resp['Niks'] * 100.0).round(); 
                        // if the value of pose 1 (yes) is greater than pose 2 (nothing) and the answer is therefore yes
                        if (pose1 > pose2) { 
                          pose3 = pose1; 
                          label = "Yes";
                          _setImage(); 
                          // timer of 5 second before he goes back to FaceDetecterViews (Eyes)
                          Timer(Duration(seconds: 5),(){ 
                          //go back to FaceDetectorView if the answer is yes
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => FaceDetectorView()),
                          );
                          });
                          }
                        // if the answer is nothing or no go back to FaceDetectorView (Eyes)
                        else{ 
                          pose3 = pose2;
                          label = "Nothing";
                          // timer is changed to a big time so the image wont change back if the answer is yes
                          Timer(Duration(seconds: 3000000),(){
                            _setImage();
                          });
                          // Wait for 12 second before he goes back 
                          Timer(Duration(seconds: 12),(){ 
                            //go back to FaceDetectorView if the answer is yes        
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => FaceDetectorView()),
                            );
                          });
                        }
                      });
                    },
                  ),
                ),
              ),
            ])),
            // print the answer
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
                            // button to go back the FaceDeetectorViews manually
                            child: const Text('Start Event'), 
                          ),
                        ]
                      ),
                    ],
                  )),
            )
          ],
        ));
  }


}
