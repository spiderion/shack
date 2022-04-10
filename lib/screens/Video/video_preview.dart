import 'package:flutter/material.dart';
import 'package:flutter_grid/screens/Video/video_controls.dart';
import 'package:video_player/video_player.dart';

class VideoPreview extends StatefulWidget {
  const VideoPreview({this.controller});

  final VideoPlayerController controller;

  @override
  _VideoPreviewState createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    widget.controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (widget.controller.value.isInitialized) {
      return Stack(
        children: <Widget>[
          ClipRect(
            child: Container(
              child: Transform.scale(
                scale: widget.controller.value.aspectRatio / size.aspectRatio,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: widget.controller.value.aspectRatio,
                    child: VideoPlayer(widget.controller),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: VideoControls(
              videoController: widget.controller,
            ),
          ),
        ],
      );
    } else {
      return Container();
    }
  }
}
