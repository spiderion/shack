import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shack/screens/Video/video_timer.dart';

class CameraScreen extends StatefulWidget {
  final Function() onCheckVideoFile;

  const CameraScreen({Key? key, required this.onCheckVideoFile}) : super(key: key);

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> with AutomaticKeepAliveClientMixin {
  CameraController? _controller;
  late List<CameraDescription> _cameras;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isRecording = false;
  final _timerKey = GlobalKey<VideoTimerState>();

  @override
  void initState() {
    _initCamera();
    super.initState();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(_cameras[0], ResolutionPreset.high);
    _controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_controller != null) {
      if (!_controller!.value.isInitialized) {
        return Container();
      }
    } else {
      return const Center(
        child: SizedBox(width: 32, height: 32, child: CircularProgressIndicator()),
      );
    }

    if (!_controller!.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      key: _scaffoldKey,
      extendBody: true,
      body: Stack(
        children: <Widget>[
          _buildCameraPreview(),
          Positioned(
              top: MediaQuery.of(context).padding.top,
              child: Container(
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              )),
          Positioned(
            top: 24.0,
            right: 12.0,
            child: IconButton(
              icon: Icon(
                Icons.switch_camera,
                color: Colors.white,
              ),
              onPressed: () {
                _onCameraSwitch();
              },
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 32.0,
            child: VideoTimer(
                key: _timerKey,
                onStopRecording: () {
                  stopVideoRecording();
                }),
          )
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildCameraPreview() {
    final size = MediaQuery.of(context).size;
    return ClipRect(
      child: Container(
        child: Transform.scale(
          scale: _controller!.value.aspectRatio / size.aspectRatio,
          child: Center(
            child: AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: CameraPreview(_controller!),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      color: Colors.grey,
      height: 100.0,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 28.0,
            child: IconButton(
              icon: Icon(
                (_isRecording) ? Icons.stop : Icons.videocam,
                size: 28.0,
                color: (_isRecording) ? Colors.red : Colors.black,
              ),
              onPressed: () {
                if (_isRecording) {
                  stopVideoRecording();
                } else {
                  startVideoRecording();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onCameraSwitch() async {
    final CameraDescription cameraDescription =
        (_controller!.description == _cameras[0]) ? _cameras[1] : _cameras[0];
    if (_controller != null) {
      await _controller!.dispose();
    }
    _controller = CameraController(cameraDescription, ResolutionPreset.medium);
    _controller!.addListener(() {
      if (mounted) setState(() {});
      if (_controller!.value.hasError) {
        showInSnackBar('Camera error ${_controller!.value.errorDescription}');
      }
    });

    try {
      await _controller!.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<String?> startVideoRecording() async {
    print('startVideoRecording');
    if (!_controller!.value.isInitialized) {
      return null;
    }
    setState(() {
      _isRecording = true;
    });
    _timerKey.currentState!.startTimer();

    final Directory extDir = await getTemporaryDirectory();
    final String dirPath = '${extDir.path}/media';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/profile.mp4';

    if (await File(filePath).exists()) {
      await File(filePath).delete();
    }

    if (_controller!.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return null;
    }

    try {
//      videoPath = filePath;
      await _controller!.startVideoRecording(/*filePath*/);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  Future<void> stopVideoRecording() async {
    if (!_controller!.value.isRecordingVideo) {
      return null;
    }
    _timerKey.currentState!.stopTimer();
    setState(() {
      _isRecording = false;
    });

    try {
      await _controller!.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    widget.onCheckVideoFile.call();
    Navigator.of(context).pop();
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  void showInSnackBar(String message) {
    _scaffoldKey.currentState!.showSnackBar(SnackBar(content: Text(message)));
  }

  void logError(String code, String? message) => print('Error: $code\nError Message: $message');

  @override
  bool get wantKeepAlive => true;
}
