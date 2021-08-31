import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class VideoApp extends StatefulWidget {
  final String sourse;
  VideoApp(this.sourse);
  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
      widget.sourse,
    )..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: <Widget>[
                    GestureDetector(
                        onTap: () {
                          setState(() {
                            _controller.value.isPlaying
                                ? _controller.pause()
                                : _controller.play();
                          });
                        },
                        child: VideoPlayer(_controller)),
                    VideoProgressIndicator(_controller, allowScrubbing: true),
                    _controller.value.isPlaying
                        ? Container()
                        : Align(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _controller.play();
                                });
                              },
                              child: ClipOval(
                                child: Material(
                                  color: Colors.white30,
                                  child: SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: Icon(
                                      Icons.play_arrow,
                                      color: Colors.grey.shade100,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                  ],
                ),
              )
            : Container(),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
