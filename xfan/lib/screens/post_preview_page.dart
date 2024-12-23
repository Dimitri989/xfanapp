import 'package:flutter/material.dart';

class Comment {
  // Improved Comment class with parent reference
  final String username;
  final String text;
  final String timeAgo;
  bool isLiked;
  final Comment? parent;  // Reference to parent comment if this is a reply
  final List<Comment> replies;

  Comment({
    required this.username,
    required this.text,
    required this.timeAgo,
    this.isLiked = false,
    this.parent,
    List<Comment>? replies,
  }) : replies = replies ?? [];
}

class PostPreviewPage extends StatefulWidget {
  final String imageUrl;
  final int index;
  final int totalImages;

  const PostPreviewPage({
    super.key,
    required this.imageUrl,
    required this.index,
    this.totalImages = 30,
  });

  @override
  State<PostPreviewPage> createState() => _PostPreviewPageState();
}

class _PostPreviewPageState extends State<PostPreviewPage> {
  final TextEditingController _commentController = TextEditingController();
  final List<Comment> _comments = [];
  double _dragStartY = 0;
  bool _isDragging = false;
  Comment? _replyingTo;

  @override
  void initState() {
    super.initState();
    // Add some sample comments
    _comments.addAll([
      Comment(
        username: 'user1',
        text: 'Great post! 🔥',
        timeAgo: '2h ago',
      ),
      Comment(
        username: 'user2',
        text: 'Amazing! 👏',
        timeAgo: '1h ago',
      ),
    ]);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    if (details.primaryDelta! > 10) { // If dragged down more than 10 pixels
      if (widget.index < widget.totalImages - 1) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            opaque: false,
            transitionDuration: const Duration(milliseconds: 200),
            pageBuilder: (context, _, __) => PostPreviewPage(
              imageUrl: 'https://picsum.photos/800/1200?random=${widget.index + 1}',
              index: widget.index + 1,
              totalImages: widget.totalImages,
            ),
          ),
        );
      }
    }
  }

  void _addComment(String text, {Comment? replyTo}) {
    setState(() {
      final newComment = Comment(
        username: 'you',
        text: text,
        timeAgo: 'now',
        parent: replyTo,
      );

      if (replyTo != null) {
        replyTo.replies.add(newComment);
      } else {
        _comments.insert(0, newComment);
      }
      
      _replyingTo = null;
      _commentController.clear();
    });
  }

  // Recursive function to build comment thread
  Widget _buildCommentThread(Comment comment, [int depth = 0]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCommentTile(comment),
        if (comment.replies.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(left: depth < 3 ? 32.0 : 0), // Limit nesting depth
            child: Column(
              children: comment.replies
                  .map((reply) => _buildCommentThread(reply, depth + 1))
                  .toList(),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.95),
        body: GestureDetector(
          onTap: () {}, // Prevents closing when tapping content
          child: SafeArea(
            child: Column(
              children: [
                // Close button
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                // Content
                Expanded(
                  child: Row(
                    children: [
                      // Image
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onVerticalDragUpdate: _handleVerticalDragUpdate,
                          child: Image.network(
                            widget.imageUrl,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      // Comments section
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(left: 1),
                          color: Colors.black,
                          child: Column(
                            children: [
                              // Comments list
                              Expanded(
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: _comments.length,
                                  itemBuilder: (context, index) {
                                    return _buildCommentThread(_comments[index]);
                                  },
                                ),
                              ),
                              // Reply indicator
                              if (_replyingTo != null)
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  color: Colors.grey[900],
                                  child: Row(
                                    children: [
                                      Text(
                                        'Replying to @${_replyingTo!.username}',
                                        style: TextStyle(color: Colors.grey[400]),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        icon: const Icon(Icons.close, color: Colors.grey),
                                        onPressed: () {
                                          setState(() => _replyingTo = null);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              // Comment input
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: Colors.grey[900]!),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _commentController,
                                        style: const TextStyle(color: Colors.white),
                                        decoration: InputDecoration(
                                          hintText: _replyingTo != null ? 'Write a reply...' : 'Add a comment...',
                                          hintStyle: TextStyle(color: Colors.grey[600]),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        if (_commentController.text.isNotEmpty) {
                                          _addComment(_commentController.text, replyTo: _replyingTo);
                                        }
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Post'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommentTile(Comment comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '@${comment.username}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      comment.timeAgo,
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.text,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          comment.isLiked = !comment.isLiked;
                        });
                      },
                      child: Icon(
                        comment.isLiked ? Icons.favorite : Icons.favorite_border,
                        color: comment.isLiked ? Colors.red : Colors.grey,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _replyingTo = comment;
                        });
                      },
                      child: Text(
                        'Reply',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
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