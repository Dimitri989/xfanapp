import 'package:flutter/material.dart';

class VideoQualitySelector extends StatelessWidget {
  final Function(String) onQualitySelected;
  final String currentQuality;

  const VideoQualitySelector({
    super.key,
    required this.onQualitySelected,
    required this.currentQuality,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.settings, color: Colors.white),
      onSelected: onQualitySelected,
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'auto',
          child: Text('Auto'),
        ),
        const PopupMenuItem<String>(
          value: '1080p',
          child: Text('1080p'),
        ),
        const PopupMenuItem<String>(
          value: '720p',
          child: Text('720p'),
        ),
        const PopupMenuItem<String>(
          value: '480p',
          child: Text('480p'),
        ),
        const PopupMenuItem<String>(
          value: '360p',
          child: Text('360p'),
        ),
      ],
    );
  }
}