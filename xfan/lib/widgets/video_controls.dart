import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';

class VideoControls extends StatefulWidget {
  final VideoPlayerController controller;
  final bool isPlaying;
  final bool isMuted;
  final Function() onPlayPause;
  final Function() onMute;

  const VideoControls({
    super.key,
    required this.controller,
    required this.isPlaying,
    required this.isMuted,
    required this.onPlayPause,
    required this.onMute,
  });

  @override
  State<VideoControls> createState() => _VideoControlsState();
}

class _VideoControlsState extends State<VideoControls> {
  bool _showControls = false;

  void _seekForward() {
    final Duration currentPosition = widget.controller.value.position;
    final Duration newPosition = currentPosition + const Duration(seconds: 10);
    widget.controller.seekTo(newPosition);
    HapticFeedback.mediumImpact();
  }

  void _seekBackward() {
    final Duration currentPosition = widget.controller.value.position;
    final Duration newPosition = currentPosition - const Duration(seconds: 10);
    widget.controller.seekTo(newPosition);
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: (details) {
        final screenWidth = MediaQuery.of(context).size.width;
        if (details.globalPosition.dx < screenWidth / 2) {
          _seekBackward();
        } else {
          _seekForward();
        }
      },
      onTap: () {
        setState(() {
          _showControls = !_showControls;
        });
        if (_showControls) {
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                _showControls = false;
              });
            }
          });
        }
      },
      child: Stack(
        children: [
          // Video progress bar
          if (_showControls)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.only(bottom: 20),
                color: Colors.black26,
                child: VideoProgressIndicator(
                  widget.controller,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                    playedColor: Colors.white,
                    bufferedColor: Colors.white38,
                    backgroundColor: Colors.white12,
                  ),
                ),
              ),
            ),

          // Control buttons
          if (_showControls)
            Positioned(
              right: 8,
              top: 8,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      widget.isMuted ? Icons.volume_off : Icons.volume_up,
                      color: Colors.white,
                    ),
                    onPressed: widget.onMute,
                  ),
                  IconButton(
                    icon: Icon(
                      widget.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    onPressed: widget.onPlayPause,
                  ),
                ],
              ),
            ),

          // Seek indicators
          if (_showControls)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 100,
                  height: double.infinity,
                  color: Colors.transparent,
                  child: const Center(
                    child: Icon(
                      Icons.replay_10,
                      color: Colors.white54,
                      size: 40,
                    ),
                  ),
                ),
                Container(
                  width: 100,
                  height: double.infinity,
                  color: Colors.transparent,
                  child: const Center(
                    child: Icon(
                      Icons.forward_10,
                      color: Colors.white54,
                      size: 40,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}