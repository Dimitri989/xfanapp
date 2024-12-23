import 'package:xfan/screens/post_preview_page.dart';

import 'package:flutter/material.dart';
import 'package:xfan/widgets/subscription_dialog.dart';

class ProfilePage extends StatefulWidget {
  final bool isOwnProfile;
  final bool isSubscribed;
  
  const ProfilePage({
    super.key, 
    this.isOwnProfile = true,
    this.isSubscribed = false,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isGridView = true;
  bool isLiked = false;
  bool _isFollowing = false;
  final TextEditingController _commentController = TextEditingController();

  final Map<String, dynamic> userData = {
    'username': 'creator123',
    'isVerified': true,
    'isXFanCreator': true,
    'subscriptionPrice': 4.99,
    'bio': 'Digital creator | Content daily ✨\nWelcome to my xFan! 🌟',
    'followers': '24.5K',
    'following': '1.2K',
    'likes': '103K',
    'profileImage': 'https://picsum.photos/200',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2 + (userData['isXFanCreator'] as bool ? 1 : 0) + (widget.isOwnProfile ? 1 : 0),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _toggleFollow() {
    setState(() {
      _isFollowing = !_isFollowing;
    });
  }

  void _showSubscriptionDialog() {
    showDialog(
      context: context,
      builder: (context) => SubscriptionDialog(
        creatorName: userData['username'] as String,
        price: userData['subscriptionPrice'] as double,
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildContentGrid(bool isXFanContent) {
    if (isXFanContent && !widget.isSubscribed) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Subscribe to see exclusive content',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return _isGridView ? _buildGrid() : _buildList();
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(1),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      itemCount: 30,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                opaque: false,
                pageBuilder: (context, _, __) => PostPreviewPage(
                  imageUrl: 'https://picsum.photos/800/1200?random=$index',
                  index: index,
                ),
              ),
            );
          },
          child: Container(
            color: Colors.grey[900],
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  'https://picsum.photos/200/200?random=$index',
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Icon(
                    index % 2 == 0 ? Icons.play_circle_outline : Icons.image,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildList() {
    return ListView.builder(
      itemCount: 30,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                opaque: false,
                pageBuilder: (context, _, __) => PostPreviewPage(
                  imageUrl: 'https://picsum.photos/800/1200?random=$index',
                  index: index,
                ),
              ),
            );
          },
          child: Container(
            height: 200,
            margin: const EdgeInsets.symmetric(vertical: 1),
            color: Colors.grey[900],
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  'https://picsum.photos/400/200?random=$index',
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Row(
                    children: [
                      Icon(Icons.favorite, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '1.2K',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.comment, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '234',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabViewChildren = [
      _buildContentGrid(false), // Posts
      if (userData['isXFanCreator'] as bool) 
        _buildContentGrid(true), // xFan Content
      _buildContentGrid(false), // Liked
      if (widget.isOwnProfile) 
        _buildContentGrid(false), // Private
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              CircleAvatar(
                                radius: 50,
                                backgroundImage: NetworkImage(userData['profileImage'] as String),
                              ),
                              const SizedBox(height: 8),
                              if (widget.isOwnProfile)
                                SizedBox(
                                  width: 100,
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                    ),
                                    child: const Text('Edit Profile'),
                                  ),
                                )
                              else if (userData['isXFanCreator'] as bool)
                                SizedBox(
                                  width: 100,
                                  child: ElevatedButton(
                                    onPressed: widget.isSubscribed ? null : _showSubscriptionDialog,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                    ),
                                    child: Text(widget.isSubscribed ? 'Subscribed' : 'Subscribe'),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Text(
                                      "@${userData['username'] as String}",
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (userData['isVerified'] as bool)
                                      const Padding(
                                        padding: EdgeInsets.only(left: 4),
                                        child: Icon(Icons.verified, color: Colors.blue, size: 20),
                                      ),
                                  ],
                                ),
                                if (userData['isXFanCreator'] as bool)
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      "xFan Creator • \$${userData['subscriptionPrice']}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 12),
                                Text(
                                  userData['bio'] as String,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          _buildStat('Followers', userData['followers'] as String),
                          _buildStat('Following', userData['following'] as String),
                          _buildStat('Likes', userData['likes'] as String),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: <Widget>[
                            // Tabs
                            Center(
                              child: TabBar(
                                controller: _tabController,
                                isScrollable: false,
                                labelColor: Colors.white,
                                unselectedLabelColor: Colors.grey,
                                indicatorColor: Colors.white,
                                dividerColor: Colors.transparent,
                                padding: EdgeInsets.zero,
                                labelPadding: const EdgeInsets.symmetric(horizontal: 10),
                                tabs: <Widget>[
                                  const Tab(text: 'Posts'),
                                  if (userData['isXFanCreator'] as bool)
                                    const Tab(text: 'xFan Content'),
                                  const Tab(text: 'Liked'),
                                  if (widget.isOwnProfile)
                                    const Tab(text: 'Private'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Grid/List toggle
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
                                onPressed: () {
                                  setState(() {
                                    _isGridView = !_isGridView;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: tabViewChildren,
            ),
          ),
        ],
      ),
    );
  }
}