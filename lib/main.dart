import 'dart:math';
import 'dart:typed_data';
import 'package:album_saver/album_saver.dart';
import 'package:intl/intl.dart' as intl;

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:open_file/open_file.dart';
//import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:permission_handler/permission_handler.dart';

List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //FirebaseAdMob.instance
  //    .initialize(appId: "ca-app-pub-6448871441563979~6708200773");
  cameras = await availableCameras();
  runApp(CameraApp());
}

class CameraApp extends StatefulWidget {
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  CameraController controller;
  Future<void> _initializeControllerFuture;
  ui.Image image;
  bool _isDisabled;
  bool _isProcessRunning;
  //
/*  InterstitialAd myInterstitial = InterstitialAd(
    adUnitId: "ca-app-pub-6448871441563979/9204509780",
    listener: (MobileAdEvent event) {
      print("InterstitialAd event is $event");
    },
  );
*/
/*  BannerAd myBanner = BannerAd(
    adUnitId: "ca-app-pub-6448871441563979/8601056318",
    size: AdSize.banner,
    listener: (MobileAdEvent event) {
      print("BannerAd event is $event");
    },
  );*/

  void _takePhoto(recordedImage) async {
    if (recordedImage != null && recordedImage.path != null) {}
  }

  static var imagePath = "";

  @override
  void initState() {
    super.initState();
    /*  myBanner
      ..load()
      ..show(
        anchorOffset: 30.0,
        horizontalCenterOffset: 10.0,
        anchorType: AnchorType.top,
      );*/
    _isDisabled = true;
    _isProcessRunning = false;
    controller = CameraController(cameras.first, ResolutionPreset.max);
    _initializeControllerFuture = controller.initialize();
  }

  @override
  void dispose() {
    // myInterstitial.dispose();
    //myBanner.dispose();
    controller.dispose();
    super.dispose();
  }

  Future<ui.Image> loadImage(List<int> img) async {
    final Completer<ui.Image> completer = new Completer();
    ui.decodeImageFromList(img, (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            body: FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Stack(
            alignment: FractionalOffset.center,
            children: <Widget>[
              new Positioned.fill(
                  child: controller.value.isInitialized
                      ? new AspectRatio(
                          aspectRatio: controller.value.aspectRatio,
                          child: CameraPreview(controller))
                      : Container()),
              Positioned(
                  top: 250,
                  child: _isProcessRunning
                      ? SizedBox(
                          width: 150.0,
                          height: 150.0,
                          child: CircularProgressIndicator(
                              backgroundColor: Colors.red,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white)))
                      : Container()),
              new Positioned(
                bottom: 1,
                child: Opacity(
                  opacity: 1,
                  child: new Image.asset(
                    'images/shit.png',
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width,
                  ),
                ),
              ),
              new Positioned(
                bottom: 5,
                child: Container(
                    height: 35,
                    width: 100,
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: RaisedButton(
                        color: Colors.red,
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(18.0),
                            side: BorderSide(color: Colors.red)),
                        onPressed: _isDisabled
                            ? () async {
                                try {
                                  setState(() {
                                    _isDisabled = false;
                                    _isProcessRunning = true;
                                  });
                                  await _initializeControllerFuture;
                                  if (await Permission.storage
                                      .request()
                                      .isGranted) {
                                    print("Granted");
                                  }
                                  String path2 =
                                      (await getExternalStorageDirectory())
                                          .path;
                                  
                                  final path = join(
                                    (await getTemporaryDirectory()).path,
                                    '${DateTime.now()}.png',
                                  );

                                  await controller.takePicture(path);

                                  /*  myInterstitial
                                    ..load()
                                    ..show(
                                      anchorType: AnchorType.bottom,
                                      anchorOffset: 0.0,
                                      horizontalCenterOffset: 0.0,
                                    );*/

                                  ui.PictureRecorder recorder =
                                      ui.PictureRecorder();

                                  Canvas canvas = Canvas(recorder);

                                  final eslSekil = await loadImage(
                                      File(path).readAsBytesSync());

                                  final ByteData data =
                                      await rootBundle.load('images/shit.png');

                                  img.Image images = img
                                      .decodeImage(data.buffer.asUint8List());

                                  img.Image thumbnail = img.copyResize(images,
                                      width: eslSekil
                                          .width); // eslSekil.width + 600

                                  File(
                                      '${(await getTemporaryDirectory()).path}/shit.png')
                                    ..writeAsBytesSync(
                                        img.encodePng(thumbnail));

                                  image = await loadImage(new Uint8List
                                      .view(File(
                                          '${(await getTemporaryDirectory()).path}/shit.png')
                                      .readAsBytesSync()
                                      .buffer));

                                  canvas.drawImage(
                                      eslSekil, new Offset(0, 0), new Paint());

                                  canvas.drawImage(
                                      image,
                                      new Offset(
                                          eslSekil.width * 1.0 -
                                              image
                                                  .width, //-(image.width * 1.0) / 5
                                          eslSekil.height * 1.0 - image.height),
                                      new Paint());

                                  final pic = await (recorder
                                      .endRecording()
                                      .toImage(
                                          eslSekil.width, eslSekil.height));

                                  
                                  var pngBytes = await pic.toByteData(
                                      format: ui.ImageByteFormat.png);

                                  var now = new DateTime.now();
                                  var formatter =
                                      new intl.DateFormat('yyyyMMddhhmmss');

                                  String formatted = formatter.format(now);

                                  await Directory('$path2')
                                      .create(recursive: true);
                                  imagePath = '$path2/$formatted.jpg';
                                  //imagePath = '/storage/emulated/0/DCIM/$formatted.jpg';
                                  File(imagePath).writeAsBytesSync(
                                      pngBytes.buffer.asInt8List());
                                  //_takePhoto(File(imagePath));
                                  setState(() {
                                    _isDisabled = true;
                                    _isProcessRunning = false;
                                  });
                                  AlbumSaver.saveToAlbum(filePath: imagePath, albumName: "Camera");
                                  OpenFile.open(imagePath);
                                  
                                } catch (e) {
                                  // If an error occurs, log the error to the console.
                                  print(e);
                                }
                              }
                            : () => print("Wait..."),
                        child: Icon(Icons.camera_alt),
                      ),
                    )),
              ),
            ],
          );
        } else {
          // Otherwise, display a loading indicator.
          return Center(child: CircularProgressIndicator());
        }
      },
    )));
  }
}
