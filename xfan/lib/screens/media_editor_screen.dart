import 'package:flutter/material.dart';
import 'dart:async';

// Text Overlay Model
class TextOverlay {
  final String text;
  final Offset position;
  final Color color;
  final double fontSize;

  TextOverlay({
    required this.text,
    required this.position,
    this.color = Colors.white,
    this.fontSize = 20,
  });

  TextOverlay copyWith({
    String? text,
    Offset? position,
    Color? color,
    double? fontSize,
  }) {
    return TextOverlay(
      text: text ?? this.text,
      position: position ?? this.position,
      color: color ?? this.color,
      fontSize: fontSize ?? this.fontSize,
    );
  }
}

class MediaEditorScreen extends StatefulWidget {
  final bool isVideo;
  
  const MediaEditorScreen({
    super.key,
    this.isVideo = false,
  });

  @override
  State<MediaEditorScreen> createState() => _MediaEditorScreenState();
}

class _MediaEditorScreenState extends State<MediaEditorScreen> {
  List<TextOverlay> _textOverlays = [];
  bool _isEditingText = false;
  int _selectedTextIndex = -1;
  final List<String> _filters = ['None', 'Vintage', 'B&W', 'Vivid', 'Dramatic'];
  String _selectedFilter = 'None';
  double _startTrim = 0.0;
  double _endTrim = 1.0;

  @override
  void dispose() {
    super.dispose();
  }

  void _addTextOverlay() {
    setState(() {
      _textOverlays.add(TextOverlay(
        text: 'Tap to edit',
        position: const Offset(100, 100),
      ));
      _selectedTextIndex = _textOverlays.length - 1;
      _isEditingText = true;
    });
  }

  void _updateTextOverlay(int index, TextOverlay newOverlay) {
    setState(() {
      _textOverlays[index] = newOverlay;
    });
  }

  void _deleteSelectedText() {
    if (_selectedTextIndex >= 0) {
      setState(() {
        _textOverlays.removeAt(_selectedTextIndex);
        _selectedTextIndex = -1;
        _isEditingText = false;
      });
    }
  }

  void _showFiltersSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black.withOpacity(0.9),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Filters',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedFilter = filter);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 80,
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedFilter == filter
                              ? Colors.blue
                              : Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.filter,
                            color: _selectedFilter == filter
                                ? Colors.blue
                                : Colors.white,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            filter,
                            style: TextStyle(
                              color: _selectedFilter == filter
                                  ? Colors.blue
                                  : Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
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
            // Mock media preview with filter
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _selectedFilter == 'B&W' ? Colors.grey[800]! : Colors.blue[900]!,
                      _selectedFilter == 'B&W' ? Colors.grey[600]! : Colors.purple[900]!,
                    ],
                  ),
                ),
                child: widget.isVideo
                    ? const Center(
                        child: Icon(Icons.play_circle_outline,
                            color: Colors.white, size: 64))
                    : null,
              ),
            ),

            // Text Overlays
            ...List.generate(_textOverlays.length, (index) {
              final overlay = _textOverlays[index];
              return Positioned(
                left: overlay.position.dx,
                top: overlay.position.dy,
                child: GestureDetector(
                  onTapDown: (_) {
                    setState(() {
                      _selectedTextIndex = index;
                      _isEditingText = true;
                    });
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      _textOverlays[index] = overlay.copyWith(
                        position: Offset(
                          overlay.position.dx + details.delta.dx,
                          overlay.position.dy + details.delta.dy,
                        ),
                      );
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: index == _selectedTextIndex
                          ? Border.all(color: Colors.blue, width: 1)
                          : null,
                    ),
                    child: Text(
                      overlay.text,
                      style: TextStyle(
                        color: overlay.color,
                        fontSize: overlay.fontSize,
                        shadows: const [
                          Shadow(
                            blurRadius: 3.0,
                            color: Colors.black,
                            offset: Offset(1.0, 1.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),

            // Video trimmer (only for videos)
            if (widget.isVideo)
              Positioned(
                bottom: 100,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: 80,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Thumbnails container with fixed height
                          SizedBox(
                            height: 40,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white, width: 1),
                                color: Colors.grey[900],
                              ),
                            ),
                          ),
                          // Slider with padding
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: SliderTheme(
                              data: SliderThemeData(
                                thumbColor: Colors.white,
                                activeTrackColor: Colors.blue,
                                inactiveTrackColor: Colors.grey[800],
                              ),
                              child: RangeSlider(
                                values: RangeValues(_startTrim, _endTrim),
                                onChanged: (RangeValues values) {
                                  setState(() {
                                    _startTrim = values.start;
                                    _endTrim = values.end;
                                  });
                                },
                                min: 0.0,
                                max: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Bottom toolbar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          _buildToolButton(
                            icon: Icons.text_fields,
                            label: 'Text',
                            onTap: _addTextOverlay,
                          ),
                          _buildToolButton(
                            icon: Icons.filter_vintage,
                            label: 'Filters',
                            onTap: _showFiltersSheet,
                          ),
                          if (widget.isVideo)
                            _buildToolButton(
                              icon: Icons.music_note,
                              label: 'Music',
                              onTap: () {
                                // TODO: Implement music selection
                              },
                            ),
                          _buildToolButton(
                            icon: Icons.auto_fix_high,
                            label: 'Effects',
                            onTap: () {
                              // TODO: Implement effects
                            },
                          ),
                          _buildToolButton(
                            icon: Icons.crop,
                            label: 'Crop',
                            onTap: () {
                              // TODO: Implement cropping
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: FilledButton(
                              onPressed: () {
                                // TODO: Save draft
                                Navigator.pop(context);
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.grey[800],
                              ),
                              child: const Text('Save Draft'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FilledButton(
                              onPressed: () {
                                // TODO: Navigate to post creation
                                Navigator.pop(context);
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                              child: const Text('Next'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Text editing panel
            if (_isEditingText && _selectedTextIndex >= 0)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _isEditingText = false;
                                _selectedTextIndex = -1;
                              });
                            },
                          ),
                          Expanded(
                            child: TextField(
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: 'Enter text...',
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                              ),
                              onChanged: (value) {
                                _updateTextOverlay(
                                  _selectedTextIndex,
                                  _textOverlays[_selectedTextIndex]
                                      .copyWith(text: value),
                                );
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.white),
                            onPressed: _deleteSelectedText,
                          ),
                        ],
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ...Colors.primaries.map((color) {
                              return GestureDetector(
                                onTap: () {
                                  _updateTextOverlay(
                                    _selectedTextIndex,
                                    _textOverlays[_selectedTextIndex]
                                        .copyWith(color: color),
                                  );
                                },
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  margin: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Top toolbar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.undo, color: Colors.white),
                          onPressed: () {
                            // TODO: Implement undo
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.redo, color: Colors.white),
                          onPressed: () {
                            // TODO: Implement redo
                          },
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
}