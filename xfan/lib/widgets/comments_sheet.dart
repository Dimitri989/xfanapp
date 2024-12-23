import 'package:flutter/material.dart';

class CommentsSheet extends StatefulWidget {
  const CommentsSheet({super.key});

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final TextEditingController _commentController = TextEditingController();
  final List<Comment> _comments = [
    Comment(
      username: 'user1',
      text: 'Amazing content! 🔥',
      likes: 124,
      timeAgo: '2h',
      isVerified: true,
      replies: [],
    ),
    Comment(
      username: 'user2',
      text: 'Keep it up! 👍',
      likes: 56,
      timeAgo: '1h',
      isVerified: false,
      replies: [],
    ),
  ];

  void _addReply(Comment parentComment, String replyText) {
    setState(() {
      parentComment.replies.add(Comment(
        username: 'you',
        text: replyText,
        likes: 0,
        timeAgo: 'now',
        isVerified: false,
        replies: [],
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Comments count
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Comments',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Comments list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _comments.length,
                  itemBuilder: (context, index) {
                    return CommentTile(
                      comment: _comments[index],
                      onReply: _addReply,
                    );
                  },
                ),
              ),
              // Comment input
              SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    border: Border(top: BorderSide(color: Colors.grey[800]!)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.blue),
                        onPressed: () {
                          if (_commentController.text.isNotEmpty) {
                            setState(() {
                              _comments.insert(
                                0,
                                Comment(
                                  username: 'you',
                                  text: _commentController.text,
                                  likes: 0,
                                  timeAgo: 'now',
                                  isVerified: false,
                                  replies: [],
                                ),
                              );
                            });
                            _commentController.clear();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class Comment {
  final String username;
  final String text;
  int likes;
  final String timeAgo;
  final bool isVerified;
  final List<Comment> replies;

  Comment({
    required this.username,
    required this.text,
    required this.likes,
    required this.timeAgo,
    required this.isVerified,
    required this.replies,
  });
}

class CommentTile extends StatefulWidget {
  final Comment comment;
  final Function(Comment, String) onReply;

  const CommentTile({super.key, required this.comment, required this.onReply});

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isLiked = false;
  bool _isReplying = false;
  final TextEditingController _replyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: 1.3).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Stack(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white),
              ),
              if (widget.comment.isVerified)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, size: 10, color: Colors.white),
                  ),
                ),
            ],
          ),
          title: Row(
            children: [
              Flexible(
                child: Text(
                  '@${widget.comment.username}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.comment.isVerified) ...[
                const SizedBox(width: 4),
                const Icon(Icons.verified, color: Colors.blue, size: 14),
              ],
              const SizedBox(width: 8),
              Text(
                widget.comment.timeAgo,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
          subtitle: Text(
            widget.comment.text,
            style: const TextStyle(color: Colors.white),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _animation.value,
                    child: child,
                  );
                },
                child: IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      isLiked = !isLiked;
                      if (isLiked) {
                        widget.comment.likes++;
                        _controller.forward().then((_) => _controller.reverse());
                      } else {
                        widget.comment.likes--;
                      }
                    });
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              Text(
                widget.comment.likes.toString(),
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              IconButton(
                icon: const Icon(Icons.reply, color: Colors.grey),
                onPressed: () {
                  setState(() {
                    _isReplying = !_isReplying;
                  });
                },
              ),
            ],
          ),
        ),
        if (_isReplying)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Write a reply...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: () {
                    if (_replyController.text.isNotEmpty) {
                      widget.onReply(widget.comment, _replyController.text);
                      _replyController.clear();
                      setState(() {
                        _isReplying = false;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        if (widget.comment.replies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              children: widget.comment.replies.map((reply) {
                return CommentTile(comment: reply, onReply: widget.onReply);
              }).toList(),
            ),
          ),
      ],
    );
  }
}