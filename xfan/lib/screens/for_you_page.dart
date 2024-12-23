import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:xfan/widgets/subscription_dialog.dart';
import 'package:xfan/widgets/comments_sheet.dart';
import 'package:xfan/widgets/profile_preview_sheet.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class ForYouPage extends StatefulWidget {
 const ForYouPage({super.key});

 @override
 State<ForYouPage> createState() => _ForYouPageState();
}

class _ForYouPageState extends State<ForYouPage> {
 final PageController _pageController = PageController();
 bool _isLoading = true;
 List<ContentData> _contentList = [];
 int _currentPage = 0;
 final int _pageSize = 10;
 bool _autoplayEnabled = true;
 String _currentQuality = 'auto';

 @override
 void initState() {
   super.initState();
   _loadContent();
 }

 Future<void> _loadContent() async {
   setState(() {
     _isLoading = true;
   });
   await Future.delayed(const Duration(seconds: 2));
   List<ContentData> newContent = List.generate(
     _pageSize,
     (index) => ContentData(
       id: '${_currentPage * _pageSize + index}',
       username: "Creator ${_currentPage * _pageSize + index}",
       description: "This is a test post #xfan #trending",
       isXFanContent: index % 2 == 0,
       likes: "1.2K",
       comments: "234",
       profileImageUrl: "https://picsum.photos/200",
       videoUrl: "https://example.com/video${_currentPage * _pageSize + index}.mp4",
     ),
   );
   setState(() {
     _contentList.addAll(newContent);
     _isLoading = false;
     _currentPage++;
   });
 }

 @override
 Widget build(BuildContext context) {
   if (_isLoading && _contentList.isEmpty) {
     return const Center(child: CircularProgressIndicator(color: Colors.blue));
   }
   return Scaffold(
     backgroundColor: Colors.black,
     body: RefreshIndicator(
       color: Colors.blue,
       onRefresh: () async {
         HapticFeedback.mediumImpact();
         setState(() {
           _contentList.clear();
           _currentPage = 0;
         });
         await _loadContent();
       },
       child: PageView.builder(
         controller: _pageController,
         scrollDirection: Axis.vertical,
         itemCount: _contentList.length + 1,
         onPageChanged: (index) {
           HapticFeedback.selectionClick();
           if (!_autoplayEnabled) return;
           if (index == _contentList.length) {
             _loadContent();
           }
         },
         itemBuilder: (context, index) {
           if (index == _contentList.length) {
             _loadContent();
             return const Center(child: CircularProgressIndicator(color: Colors.blue));
           }
           return ContentCard(
             content: _contentList[index],
             autoplayEnabled: _autoplayEnabled,
             currentQuality: _currentQuality,
             onAutoplayChanged: (value) {
               setState(() {
                 _autoplayEnabled = value;
               });
             },
             onQualityChanged: (quality) {
               setState(() {
                 _currentQuality = quality;
               });
             },
           );
         },
       ),
     ),
   );
 }

 @override
 void dispose() {
   _pageController.dispose();
   super.dispose();
 }
}

class VideoControls extends StatefulWidget {
 final VideoPlayerController controller;
 final bool isPlaying;
 final bool isMuted;
 final VoidCallback onPlayPause;
 final VoidCallback onMute;

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
 Timer? _controlsTimer;

 void _handleTap() {
   setState(() {
     _showControls = !_showControls;
   });
   _resetControlsTimer();
 }

 void _resetControlsTimer() {
   _controlsTimer?.cancel();
   if (_showControls) {
     _controlsTimer = Timer(const Duration(seconds: 3), () {
       if (mounted) {
         setState(() {
           _showControls = false;
         });
       }
     });
   }
 }

 void _seekForward() {
   final Duration currentPosition = widget.controller.value.position;
   final Duration targetPosition = currentPosition + const Duration(seconds: 10);
   widget.controller.seekTo(targetPosition);
   HapticFeedback.mediumImpact();
 }

 void _seekBackward() {
   final Duration currentPosition = widget.controller.value.position;
   final Duration targetPosition = currentPosition - const Duration(seconds: 10);
   widget.controller.seekTo(targetPosition);
   HapticFeedback.mediumImpact();
 }

 @override
 void dispose() {
   _controlsTimer?.cancel();
   super.dispose();
 }

 @override
 Widget build(BuildContext context) {
   return GestureDetector(
     onTap: _handleTap,
     onDoubleTapDown: (details) {
       final screenWidth = MediaQuery.of(context).size.width;
       if (details.globalPosition.dx < screenWidth / 2) {
         _seekBackward();
       } else {
         _seekForward();
       }
     },
     child: Stack(
       children: [
         // Video content
         AspectRatio(
           aspectRatio: widget.controller.value.aspectRatio,
           child: VideoPlayer(widget.controller),
         ),

         // Video controls overlay
         if (_showControls)
           Container(
             color: Colors.black26,
             child: Stack(
               children: [
                 // Play/Pause center button
                 Center(
                   child: IconButton(
                     icon: Icon(
                       widget.isPlaying ? Icons.pause : Icons.play_arrow,
                       color: Colors.white,
                       size: 50,
                     ),
                     onPressed: () {
                       widget.onPlayPause();
                       HapticFeedback.mediumImpact();
                     },
                   ),
                 ),

                 // Progress bar
                 Positioned(
                   bottom: 0,
                   left: 0,
                   right: 0,
                   child: Container(
                     padding: const EdgeInsets.only(bottom: 20),
                     child: ValueListenableBuilder(
                       valueListenable: widget.controller,
                       builder: (context, VideoPlayerValue value, child) {
                         return VideoProgressIndicator(
                           widget.controller,
                           allowScrubbing: true,
                           colors: const VideoProgressColors(
                             playedColor: Colors.blue,
                             bufferedColor: Colors.white38,
                             backgroundColor: Colors.white12,
                           ),
                         );
                       },
                     ),
                   ),
                 ),

                 // Top controls
                 Positioned(
                   top: 0,
                   right: 0,
                   child: Row(
                     children: [
                       IconButton(
                         icon: Icon(
                           widget.isMuted ? Icons.volume_off : Icons.volume_up,
                           color: Colors.white,
                         ),
                         onPressed: () {
                           widget.onMute();
                           HapticFeedback.selectionClick();
                         },
                       ),
                     ],
                   ),
                 ),

                 // Seek indicators
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
           ),
       ],
     ),
   );
 }
}

class ContentCard extends StatefulWidget {
 final ContentData content;
 final bool autoplayEnabled;
 final String currentQuality;
 final Function(bool) onAutoplayChanged;
 final Function(String) onQualityChanged;

 const ContentCard({
   super.key,
   required this.content,
   required this.autoplayEnabled,
   required this.currentQuality,
   required this.onAutoplayChanged,
   required this.onQualityChanged,
 });

 @override
 State<ContentCard> createState() => _ContentCardState();
}

class _ContentCardState extends State<ContentCard> with SingleTickerProviderStateMixin {
 bool isLiked = false;
 bool isBookmarked = false;
 bool isMuted = false;
 DateTime? _startViewTime;
 late VideoPlayerController _videoController;
 late AnimationController _animationController;
 late Animation<double> _scaleAnimation;
 bool _isPlaying = true;

 @override
 void initState() {
   super.initState();
   _startViewTime = DateTime.now();
   _initializeVideo();

   _animationController = AnimationController(
     duration: const Duration(milliseconds: 200),
     vsync: this,
   );

   _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
     CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
   );
 }

 Future<void> _initializeVideo() async {
   _videoController = VideoPlayerController.network(widget.content.videoUrl);
   try {
     await _videoController.initialize();
     if (mounted) {
       setState(() {});
       if (widget.autoplayEnabled) {
         _videoController.play();
       }
       _videoController.setLooping(true);
     }
   } catch (e) {
     print('Error initializing video: $e');
   }
 }

 @override
 void didUpdateWidget(ContentCard oldWidget) {
   super.didUpdateWidget(oldWidget);
   if (widget.autoplayEnabled != oldWidget.autoplayEnabled) {
     widget.autoplayEnabled ? _videoController.play() : _videoController.pause();
   }
 }

 @override
 void dispose() {
   _logViewDuration();
   _videoController.dispose();
   _animationController.dispose();
   super.dispose();
 }

 void _logViewDuration() {
   if (_startViewTime != null) {
     final duration = DateTime.now().difference(_startViewTime!);
     print('Content viewed for ${duration.inSeconds} seconds');
   }
 }

 void _handleLike() {
   HapticFeedback.mediumImpact();
   setState(() {
     isLiked = !isLiked;
   });
   if (isLiked) {
     _animationController.forward().then((_) => _animationController.reverse());
   }
 }

 void _togglePlayPause() {
   HapticFeedback.selectionClick();
   setState(() {
     _isPlaying = !_isPlaying;
     _isPlaying ? _videoController.play() : _videoController.pause();
   });
 }

 void _toggleMute() {
   HapticFeedback.selectionClick();
   setState(() {
     isMuted = !isMuted;
     _videoController.setVolume(isMuted ? 0 : 1);
   });
 }

 void _showVideoSettings() {
   HapticFeedback.mediumImpact();
   showDialog(
     context: context,
     builder: (context) => Dialog(
       backgroundColor: Colors.black87,
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
       child: Container(
         padding: const EdgeInsets.all(24),
         child: Column(
           mainAxisSize: MainAxisSize.min,
           children: [
             const Text(
               'Video Settings',
               style: TextStyle(
                 color: Colors.white,
                 fontSize: 20,
                 fontWeight: FontWeight.bold,
               ),
             ),
             const SizedBox(height: 24),
             SwitchListTile(
               title: const Text(
                 'Autoplay Videos',
                 style: TextStyle(color: Colors.white),
               ),
               value: widget.autoplayEnabled,
               onChanged: widget.onAutoplayChanged,
               activeColor: Colors.blue,
             ),
             const Divider(color: Colors.white24),
             ListTile(
               title: const Text(
                 'Video Quality',
                 style: TextStyle(color: Colors.white),
               ),
               trailing: DropdownButton<String>(
                 value: widget.currentQuality,
                 dropdownColor: Colors.black87,
                 style: const TextStyle(color: Colors.white),
                 underline: Container(
                   height: 2,
                   color: Colors.blue,
                 ),
                 onChanged: (String? newValue) {
                   if (newValue != null) widget.onQualityChanged(newValue);
                   Navigator.pop(context);
                 },
                 items: ['auto', '1080p', '720p', '480p', '360p']
                     .map<DropdownMenuItem<String>>((String value) {
                   return DropdownMenuItem<String>(
                     value: value,
                     child: Text(value),
                   );
                 }).toList(),
               ),
             ),
           ],
         ),
       ),
     ),
   );
 }
  @override
 Widget build(BuildContext context) {
   return SafeArea(
     child: GestureDetector(
       onDoubleTap: _handleLike,
       onTap: () {
         if (widget.content.isXFanContent) {
           HapticFeedback.mediumImpact();
           showDialog(
             context: context,
             builder: (context) => SubscriptionDialog(
               creatorName: widget.content.username,
               price: 2.40,
             ),
           );
         }
       },
       child: Container(
         color: Colors.black,
         child: Stack(
           fit: StackFit.expand,
           children: [
             if (_videoController.value.isInitialized)
               VideoControls(
                 controller: _videoController,
                 isPlaying: _isPlaying,
                 isMuted: isMuted,
                 onPlayPause: _togglePlayPause,
                 onMute: _toggleMute,
               ),

             Positioned(
               right: 16,
               bottom: 100,
               child: Column(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   GestureDetector(
                     onTap: () {
                       HapticFeedback.mediumImpact();
                       showModalBottomSheet(
                         context: context,
                         isScrollControlled: true,
                         backgroundColor: Colors.transparent,
                         builder: (context) => ProfilePreviewSheet(
                           username: widget.content.username,
                           profileImageUrl: widget.content.profileImageUrl,
                           isXFanCreator: widget.content.isXFanContent,
                         ),
                       );
                     },
                     child: CircleAvatar(
                       radius: 25,
                       backgroundImage: NetworkImage(widget.content.profileImageUrl),
                     ),
                   ),
                   const SizedBox(height: 20),
                   ScaleTransition(
                     scale: _scaleAnimation,
                     child: IconButton(
                       icon: Icon(
                         isLiked ? Icons.favorite : Icons.favorite_border,
                         color: isLiked ? Colors.red : Colors.white,
                         size: 30,
                       ),
                       onPressed: _handleLike,
                     ),
                   ),
                   Text(widget.content.likes,
                       style: const TextStyle(color: Colors.white)),
                   const SizedBox(height: 20),
                   IconButton(
                     icon: const Icon(Icons.comment, color: Colors.white, size: 30),
                     onPressed: () {
                       HapticFeedback.mediumImpact();
                       showModalBottomSheet(
                         context: context,
                         isScrollControlled: true,
                         backgroundColor: Colors.transparent,
                         builder: (context) => const CommentsSheet(),
                       );
                     },
                   ),
                   Text(widget.content.comments,
                       style: const TextStyle(color: Colors.white)),
                   const SizedBox(height: 20),
                   IconButton(
                     icon: const Icon(Icons.share, color: Colors.white, size: 30),
                     onPressed: () {
                       HapticFeedback.mediumImpact();
                       Share.share('Check out this content by ${widget.content.username}!');
                     },
                   ),
                   const SizedBox(height: 20),
                   IconButton(
                     icon: Icon(
                       isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                       color: Colors.white,
                       size: 30,
                     ),
                     onPressed: () {
                       HapticFeedback.mediumImpact();
                       setState(() {
                         isBookmarked = !isBookmarked;
                       });
                     },
                   ),
                   const SizedBox(height: 20),
                   IconButton(
                     icon: Icon(
                       widget.autoplayEnabled ? Icons.play_circle_outline : Icons.pause_circle_outline,
                       color: Colors.white,
                       size: 30,
                     ),
                     onPressed: _showVideoSettings,
                   ),
                 ],
               ),
             ),

             Positioned(
               left: 16,
               bottom: 50,
               right: 100,
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   Row(
                     children: [
                       Text(
                         '@${widget.content.username}',
                         style: const TextStyle(
                           color: Colors.white,
                           fontWeight: FontWeight.bold,
                           fontSize: 16,
                         ),
                       ),
                       if (widget.content.isXFanContent) ...[
                         const SizedBox(width: 8),
                         Container(
                           padding: const EdgeInsets.symmetric(
                               horizontal: 8, vertical: 4),
                           decoration: BoxDecoration(
                             color: Colors.blue,
                             borderRadius: BorderRadius.circular(4),
                           ),
                           child: const Text(
                             'xFan',
                             style: TextStyle(
                               color: Colors.white,
                               fontSize: 12,
                               fontWeight: FontWeight.bold,
                             ),
                           ),
                         ),
                       ],
                     ],
                   ),
                   const SizedBox(height: 8),
                   Text(
                     widget.content.description,
                     style: const TextStyle(color: Colors.white),
                     maxLines: 2,
                     overflow: TextOverflow.ellipsis,
                   ),
                 ],
               ),
             ),

             if (widget.content.isXFanContent)
               ClipRect(
                 child: BackdropFilter(
                   filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                   child: Container(
                     color: Colors.black.withOpacity(0.5),
                     child: const Center(
                       child: Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           Icon(Icons.lock, color: Colors.white, size: 40),
                           SizedBox(height: 10),
                           Text(
                             'Subscribe to view\nxFan content',
                             textAlign: TextAlign.center,
                             style: TextStyle(color: Colors.white),
                           ),
                         ],
                       ),
                     ),
                   ),
                 ),
               ),
           ],
         ),
       ),
     ),
   );
 }
}

class ContentData {
 final String id;
 final String username;
 final String description;
 final bool isXFanContent;
 final String likes;
 final String comments;
 final String profileImageUrl;
 final String videoUrl;

 ContentData({
   required this.id,
   required this.username,
   required this.description,
   required this.isXFanContent,
   required this.likes,
   required this.comments,
   required this.profileImageUrl,
   required this.videoUrl,
 });
}