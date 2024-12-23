import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'media_editor_screen.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  bool _isRecording = false;
  bool _isPhotoMode = true;
  bool _isFrontCamera = false;
  bool _isFlashOn = false;
  Timer? _recordingTimer;
  int _recordingDuration = 0;

  @override
  void dispose() {
    _recordingTimer?.cancel();
    super.dispose();
  }

  void _toggleCameraMode() {
    if (_isRecording) return;
    setState(() {
      _isPhotoMode = !_isPhotoMode;
    });
    HapticFeedback.mediumImpact();
  }

  void _toggleCamera() {
    if (_isRecording) return;
    setState(() => _isFrontCamera = !_isFrontCamera);
    HapticFeedback.mediumImpact();
  }

  void _toggleFlash() {
    if (_isRecording) return;
    setState(() => _isFlashOn = !_isFlashOn);
    HapticFeedback.mediumImpact();
  }

  void _takePhoto() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MediaEditorScreen(isVideo: false),
      ),
    );
  }

  void _startRecording() {
    setState(() => _isRecording = true);
    _startTimer();
    HapticFeedback.mediumImpact();
  }

  void _stopRecording() {
    setState(() => _isRecording = false);
    _recordingTimer?.cancel();
    setState(() => _recordingDuration = 0);
    HapticFeedback.mediumImpact();
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MediaEditorScreen(isVideo: true),
      ),
    );
  }

  void _startTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _recordingDuration++);
      // Optional: Stop recording at max duration (e.g., 60 seconds)
      if (_recordingDuration >= 60) {
        _stopRecording();
      }
    });
  }

  void _pickFromGallery() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MediaEditorScreen(isVideo: false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Mock Camera Preview
            Center(
              child: Container(
                color: Colors.grey[900],
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Mock preview background
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.blue[900]!,
                            Colors.purple[900]!,
                          ],
                        ),
                      ),
                    ),
                    // Mock camera UI elements
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isFrontCamera ? Icons.face : Icons.camera_rear,
                          color: Colors.white.withOpacity(0.5),
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isRecording ? 'Recording...' : 'Preview',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                        if (_isFlashOn)
                          Container(
                            margin: const EdgeInsets.only(top: 16),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.yellow.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              'Flash ON',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Top Controls
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _isFlashOn ? Icons.flash_on : Icons.flash_off,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: _toggleFlash,
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings, color: Colors.white, size: 28),
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            // TODO: Show camera settings
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Recording Timer
            if (_isRecording)
              Positioned(
                top: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.fiber_manual_record, color: Colors.red, size: 12),
                        const SizedBox(width: 8),
                        Text(
                          '${_recordingDuration ~/ 60}:${(_recordingDuration % 60).toString().padLeft(2, '0')}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Bottom Controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Mode Selector
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildModeButton('Photo', _isPhotoMode),
                          _buildModeButton('Video', !_isPhotoMode),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Camera Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.photo_library, color: Colors.white, size: 32),
                          onPressed: _pickFromGallery,
                        ),
                        // Capture Button
                        GestureDetector(
                          onTap: _isPhotoMode ? _takePhoto : null,
                          onLongPress: _isPhotoMode ? null : _startRecording,
                          onLongPressUp: _isPhotoMode ? null : _stopRecording,
                          child: Container(
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              color: _isRecording ? Colors.red : Colors.transparent,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.flip_camera_ios, color: Colors.white, size: 32),
                          onPressed: _toggleCamera,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton(String label, bool isSelected) {
    return GestureDetector(
      onTap: _toggleCameraMode,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}