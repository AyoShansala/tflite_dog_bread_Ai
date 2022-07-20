import 'package:ai_dog_bread_identi_app/main.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isWorking = false;
  String result = '';
  CameraController? cameraController;
  CameraImage? imgCamera;

  initCamera() {
    cameraController = CameraController(cameras![0], ResolutionPreset.medium);
    cameraController!.initialize().then((value) {
      if (!mounted) {
        return;
      }
      setState(() {
        cameraController!.startImageStream((imageFromStream) => {
              if (!isWorking)
                {
                  isWorking = true,
                  imgCamera = imageFromStream,
                  runModelOnStreamFrame(),
                }
            });
      });
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/model.tflite",
      labels: "assets/labels.txt",
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadModel();
  }

  runModelOnStreamFrame() async {
    if (imgCamera != null) {
      var recognitions = await Tflite.runModelOnFrame(
        bytesList: imgCamera!.planes.map((plane) {
          return plane.bytes;
        }).toList(),
        imageHeight: imgCamera!.height,
        imageWidth: imgCamera!.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90,
        numResults: 2,
        threshold: 0.1,
        asynch: true,
      );
      result = '';

      recognitions!.forEach((response) {
        result += response["label"] +
            " " +
            (response["confidence"] as double).toStringAsFixed(2);
      });
      setState(() {
        result;
      });
      isWorking = false;
    }
  }

  @override
  void dispose() async {
    // TODO: implement dispose
    super.dispose();
    await Tflite.close();
    cameraController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dog Bread"),
      ),
      // body: Container(
      //   decoration: BoxDecoration(
      //     image: DecorationImage(
      //       image: AssetImage("assets/back.jpg"),
      //       fit: BoxFit.fill,
      //     ),
      //   ),
      //   child: Column(
      //     children: [
      //       Stack(
      //         children: [
      //           Center(
      //             child: Container(
      //               height: 320.0,
      //               width: 360.0,
      //               child: Image.asset("assets/frame.jpg"),
      //             ),
      //           ),
      //           Center(
      //             child: TextButton(
      //               onPressed: () {
      //                 initCamera();
      //               },
      //               child: Container(
      //                 margin: EdgeInsets.only(top: 35.0),
      //                 height: 250.0,
      //                 width: 340.0,
      //                 child: imgCamera == null
      //                     ? Container(
      //                         height: 250.0,
      //                         width: 340,
      //                         child: Icon(
      //                           Icons.photo_camera_front,
      //                           color: Colors.pink,
      //                           size: 28.0,
      //                         ),
      //                       )
      //                     : AspectRatio(
      //                         aspectRatio: cameraController!.value.aspectRatio,
      //                         child: CameraPreview(cameraController!),
      //                       ),
      //               ),
      //             ),
      //           )
      //         ],
      //       ),
      //       Center(
      //         child: Container(
      //           margin: EdgeInsets.only(top: 45.0),
      //           child: SingleChildScrollView(
      //             child: Text(
      //               result,
      //               style: const TextStyle(
      //                 backgroundColor: Colors.white54,
      //                 fontSize: 25,
      //                 color: Colors.black,
      //               ),
      //               textAlign: TextAlign.center,
      //             ),
      //           ),
      //         ),
      //       )
      //     ],
      //   ),
      // ),
    );
  }
}