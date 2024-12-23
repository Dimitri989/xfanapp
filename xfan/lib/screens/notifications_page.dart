import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'notification_settings.dart';

class NotificationItem {
  final String username;
  final String action;
  final String timeAgo;
  final String? contentPreview;
  final NotificationType type;
  bool isFollowing;
  final String? contentId;
  final List<String>? groupedUsernames;
  final String? thumbnailUrl;
  bool isRead;
  final DateTime timestamp;

  NotificationItem({
    required this.username,
    required this.action,
    required this.timeAgo,
    this.contentPreview,
    required this.type,
    this.isFollowing = false,
    this.contentId,
    this.groupedUsernames,
    this.thumbnailUrl,
    this.isRead = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

enum NotificationType {
  like,
  comment,
  follow,
  mention,
  subscribed,
  newPost,
  remixVideo,
  duetVideo,
  milestone,
  promotional,
}

enum NotificationSort {
  latest,
  oldest,
  mostInteractions,
  unreadFirst
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<NotificationItem> _notifications = [];
  String _selectedFilter = 'All';
  bool _showUnreadOnly = false;
  NotificationSort _currentSort = NotificationSort.latest;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  DateTime? _startDate;
  DateTime? _endDate;
  Set<String> _selectedTypes = {};

  final List<String> _filterOptions = [
    'All',
    'Likes',
    'Comments',
    'Follows',
    'Mentions',
    'Subscriptions',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMockNotifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadMockNotifications() {
    _notifications.addAll([
      // Grouped likes notification
      NotificationItem(
        username: 'johndoe',
        action: 'and others liked your video',
        timeAgo: '2m',
        type: NotificationType.like,
        contentPreview: 'Check out my new dance routine! #dance',
        contentId: '123',
        groupedUsernames: ['jane_smith', 'mike_wilson', 'sarah_dance'],
        thumbnailUrl: 'https://picsum.photos/100',
      ),
      // Comments with mentions
      NotificationItem(
        username: 'sara_smith',
        action: 'and 5 others commented on your video',
        timeAgo: '5m',
        type: NotificationType.comment,
        contentPreview: '@username Amazing content! 🔥',
        contentId: '124',
        groupedUsernames: ['user1', 'user2', 'user3', 'user4', 'user5'],
        thumbnailUrl: 'https://picsum.photos/101',
      ),
      // Grouped follows
      NotificationItem(
        username: 'mike_jackson',
        action: 'and 3 others started following you',
        timeAgo: '15m',
        type: NotificationType.follow,
        groupedUsernames: ['dancer1', 'dancer2', 'dancer3'],
      ),
      // Milestone notification
      NotificationItem(
        username: 'System',
        action: 'Congratulations! You reached 1000 followers! 🎉',
        timeAgo: '30m',
        type: NotificationType.milestone,
      ),
      // Remix notification
      NotificationItem(
        username: 'creative_user',
        action: 'remixed your video',
        timeAgo: '1h',
        type: NotificationType.remixVideo,
        contentId: '125',
        thumbnailUrl: 'https://picsum.photos/102',
      ),
      // New post from subscription
      NotificationItem(
        username: 'favorite_creator',
        action: 'posted new exclusive content',
        timeAgo: '3h',
        type: NotificationType.newPost,
        contentId: '126',
        thumbnailUrl: 'https://picsum.photos/103',
      ),
    ]);
  }

  void _navigateToContent(NotificationItem notification) {
    if (notification.contentId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Navigating to content ${notification.contentId}'),
        ),
      );
    } else if (notification.type == NotificationType.follow) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Navigating to profile'),
        ),
      );
    }
  }

  Widget _buildNotificationIcon(NotificationType type) {
    IconData icon;
    Color color;

    switch (type) {
      case NotificationType.like:
        icon = Icons.favorite;
        color = Colors.red;
        break;
      case NotificationType.comment:
        icon = Icons.comment;
        color = Colors.blue;
        break;
      case NotificationType.follow:
        icon = Icons.person_add;
        color = Colors.green;
        break;
      case NotificationType.mention:
        icon = Icons.alternate_email;
        color = Colors.orange;
        break;
      case NotificationType.subscribed:
        icon = Icons.star;
        color = Colors.purple;
        break;
      case NotificationType.newPost:
        icon = Icons.new_releases;
        color = Colors.yellow;
        break;
      case NotificationType.remixVideo:
        icon = Icons.video_library;
        color = Colors.cyan;
        break;
      case NotificationType.duetVideo:
        icon = Icons.duo;
        color = Colors.pink;
        break;
      case NotificationType.milestone:
        icon = Icons.emoji_events;
        color = Colors.amber;
        break;
      case NotificationType.promotional:
        icon = Icons.local_offer;
        color = Colors.deepPurple;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color),
    );
  }

  Widget _buildGroupedAvatars(List<String> usernames) {
    return SizedBox(
      width: 80,
      height: 40,
      child: Stack(
        children: List.generate(
          usernames.length > 3 ? 3 : usernames.length,
          (index) => Positioned(
            left: index * 20.0,
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[800],
              child: Text(
                usernames[index][0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<NotificationItem> _getFilteredNotifications() {
    var filtered = _notifications;
    
    // Apply type filter
    if (_selectedFilter != 'All') {
      filtered = filtered.where((notification) {
        switch (_selectedFilter) {
          case 'Likes':
            return notification.type == NotificationType.like;
          case 'Comments':
            return notification.type == NotificationType.comment;
          case 'Follows':
            return notification.type == NotificationType.follow;
          case 'Mentions':
            return notification.type == NotificationType.mention;
          case 'Subscriptions':
            return notification.type == NotificationType.subscribed ||
                   notification.type == NotificationType.newPost;
          default:
            return true;
        }
      }).toList();
    }

    // Apply search filter if searching
    if (_isSearching && _searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      filtered = filtered.where((notification) {
        return notification.username.toLowerCase().contains(searchTerm) ||
               (notification.contentPreview?.toLowerCase().contains(searchTerm) ?? false) ||
               notification.action.toLowerCase().contains(searchTerm);
      }).toList();
    }

    // Apply date filter
    if (_startDate != null) {
      filtered = filtered.where((notification) =>
        notification.timestamp.isAfter(_startDate!)).toList();
    }
    if (_endDate != null) {
      filtered = filtered.where((notification) =>
        notification.timestamp.isBefore(_endDate!.add(const Duration(days: 1)))).toList();
    }

    // Apply type filters from advanced filter
    if (_selectedTypes.isNotEmpty) {
      filtered = filtered.where((notification) =>
        _selectedTypes.contains(notification.type.toString())).toList();
    }

    // Apply unread filter
    if (_showUnreadOnly) {
      filtered = filtered.where((notification) => !notification.isRead).toList();
    }

    // Apply sorting
    switch (_currentSort) {
      case NotificationSort.latest:
        filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        break;
      case NotificationSort.oldest:
        filtered.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        break;
      case NotificationSort.unreadFirst:
        filtered.sort((a, b) {
          if (a.isRead == b.isRead) {
            return b.timestamp.compareTo(a.timestamp);
          }
          return a.isRead ? 1 : -1;
        });
        break;
      case NotificationSort.mostInteractions:
        filtered.sort((a, b) {
          final aInteractions = a.groupedUsernames?.length ?? 0;
          final bInteractions = b.groupedUsernames?.length ?? 0;
          return bInteractions.compareTo(aInteractions);
        });
        break;
    }

    return filtered;
  }

  void _showQuickReplySheet(NotificationItem notification) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: QuickReplySheet(
          username: notification.username,
          onReply: (String reply) {
            HapticFeedback.mediumImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Reply sent: $reply')),
            );
          },
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Advanced Filters'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Date Range
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_startDate?.toString().split(' ')[0] ?? 'Start Date'),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => _startDate = date);
                      }
                    },
                  ),
                ),
                const Text(' - '),
                Expanded(
                  child: TextButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_endDate?.toString().split(' ')[0] ?? 'End Date'),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => _endDate = date);
                      }
                    },
                  ),
                ),
              ],
            ),
            
            // Notification Types
            Wrap(
              spacing: 8,
              children: NotificationType.values.map((type) {
                return FilterChip(
                  label: Text(type.toString().split('.')[1]),
                  selected: _selectedTypes.contains(type.toString()),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedTypes.add(type.toString());
                      } else {
                        _selectedTypes.remove(type.toString());
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _startDate = null;
                _endDate = null;
                _selectedTypes.clear();
              });
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showSortMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        color: Colors.black,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: NotificationSort.values.map((sort) {
            return ListTile(
              leading: _currentSort == sort
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
              title: Text(
                sort.toString().split('.')[1].replaceAll('_', ' '),
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                setState(() => _currentSort = sort);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _handleNotificationAction(NotificationItem notification, NotificationAction action) {
    HapticFeedback.mediumImpact();
    switch (action) {
      case NotificationAction.like:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Content liked')),
        );
        break;
      case NotificationAction.reply:
        _showQuickReplySheet(notification);
        break;
      case NotificationAction.delete:
        setState(() {
          _notifications.remove(notification);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification deleted')),
        );
        break;
      case NotificationAction.markRead:
        setState(() {
          notification.isRead = true;
        });
        break;
    }
  }

  Widget _buildSwipeActionButton(
    Color color,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return Container(
      alignment: Alignment.center,
      color: color,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
    );
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search notifications...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {});
                },
              )
            : const Text('Activity', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortMenu,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Text('Notification Settings'),
              ),
              const PopupMenuItem(
                value: 'readAll',
                child: Text('Mark All as Read'),
              ),
              const PopupMenuItem(
                value: 'clearAll',
                child: Text('Clear All'),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'settings':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationSettings(),
                    ),
                  );
                  break;
                case 'readAll':
                  setState(() {
                    for (var notification in _notifications) {
                      notification.isRead = true;
                    }
                  });
                  break;
                case 'clearAll':
                  setState(() {
                    _notifications.clear();
                  });
                  break;
              }
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                tabs: const [
                  Tab(text: 'All Activity'),
                  Tab(text: 'Mentions'),
                  Tab(text: 'System'),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _filterOptions.map((filter) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: FilterChip(
                                selected: _selectedFilter == filter,
                                label: Text(filter),
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedFilter = filter;
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _showUnreadOnly ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _showUnreadOnly = !_showUnreadOnly;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // All Activity Tab
          _buildNotificationsList(_getFilteredNotifications()),

          // Mentions Tab
          _buildNotificationsList(
            _notifications.where((n) => n.type == NotificationType.mention).toList(),
          ),

          // System Tab
          _buildNotificationsList(
            _notifications.where((n) =>
              n.type == NotificationType.milestone ||
              n.type == NotificationType.promotional
            ).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(List<NotificationItem> notifications) {
    if (notifications.isEmpty) {
      return const Center(
        child: Text(
          'No notifications',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return Dismissible(
          key: Key(notification.hashCode.toString()),
          background: _buildSwipeActionButton(
            Colors.blue,
            Icons.reply,
            'Reply',
            () => _handleNotificationAction(notification, NotificationAction.reply),
          ),
          secondaryBackground: _buildSwipeActionButton(
            Colors.red,
            Icons.delete,
            'Delete',
            () => _handleNotificationAction(notification, NotificationAction.delete),
          ),
          onDismissed: (direction) {
            if (direction == DismissDirection.startToEnd) {
              _handleNotificationAction(notification, NotificationAction.reply);
            } else {
              _handleNotificationAction(notification, NotificationAction.delete);
            }
          },
          child: GestureDetector(
            onLongPress: () {
              HapticFeedback.mediumImpact();
              showModalBottomSheet(
                context: context,
                builder: (context) => Container(
                  color: Colors.black,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.reply, color: Colors.white),
                        title: const Text(
                          'Quick Reply',
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _showQuickReplySheet(notification);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.remove_red_eye, color: Colors.white),
                        title: Text(
                          notification.isRead ? 'Mark as Unread' : 'Mark as Read',
                          style: const TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          setState(() {
                            notification.isRead = !notification.isRead;
                          });
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.delete, color: Colors.red),
                        title: const Text(
                          'Delete Notification',
                          style: TextStyle(color: Colors.red),
                        ),
                        onTap: () {
                          setState(() {
                            _notifications.remove(notification);
                          });
                          Navigator.pop(context);
                        },
                      ),
                      if (notification.type == NotificationType.follow)
                        ListTile(
                          leading: Icon(
                            notification.isFollowing ? Icons.person_remove : Icons.person_add,
                            color: Colors.white,
                          ),
                          title: Text(
                            notification.isFollowing ? 'Unfollow' : 'Follow',
                            style: const TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            setState(() {
                              notification.isFollowing = !notification.isFollowing;
                            });
                            Navigator.pop(context);
                          },
                        ),
                    ],
                  ),
                ),
              );
            },
            onTap: () => _navigateToContent(notification),
            child: Container(
              color: notification.isRead ? Colors.black : Colors.blue.withOpacity(0.1),
              child: ListTile(
                leading: notification.groupedUsernames != null
                    ? _buildGroupedAvatars(notification.groupedUsernames!)
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey[800],
                            child: Text(
                              notification.username[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildNotificationIcon(notification.type),
                        ],
                      ),
                title: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.white),
                    children: [
                      TextSpan(
                        text: '@${notification.username} ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: notification.action),
                      if (notification.groupedUsernames != null &&
                          notification.groupedUsernames!.length > 3)
                        TextSpan(
                          text:
                              ' and ${notification.groupedUsernames!.length - 3} others',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                    ],
                  ),
                ),
                subtitle: notification.contentPreview != null
                    ? Text(
                        notification.contentPreview!,
                        style: TextStyle(color: Colors.grey[400]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (notification.thumbnailUrl != null)
                      Container(
                        width: 50,
                        height: 50,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          image: DecorationImage(
                            image: NetworkImage(notification.thumbnailUrl!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          notification.timeAgo,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                        if (notification.type == NotificationType.follow)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: notification.isFollowing
                                    ? Colors.transparent
                                    : Colors.blue,
                                border: Border.all(
                                  color: notification.isFollowing
                                      ? Colors.grey
                                      : Colors.blue,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                notification.isFollowing ? 'Following' : 'Follow',
                                style: TextStyle(
                                  color: notification.isFollowing
                                      ? Colors.grey
                                      : Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Quick Reply Sheet Widget
class QuickReplySheet extends StatelessWidget {
  final String username;
  final Function(String) onReply;

  const QuickReplySheet({
    super.key,
    required this.username,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Quick Reply',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              _buildQuickReply('Thanks! 🙏', context),
              _buildQuickReply('Great! 🔥', context),
              _buildQuickReply('Will check it out! 👀', context),
              _buildQuickReply('Love it! ❤️', context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickReply(String text, BuildContext context) {
    return InkWell(
      onTap: () {
        onReply(text);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

enum NotificationAction {
  like,
  reply,
  delete,
  markRead,
}