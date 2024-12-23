import 'package:flutter/material.dart';

class NotificationSettings extends StatefulWidget {
  const NotificationSettings({super.key});

  @override
  State<NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  // Notification preferences
  final Map<String, bool> _preferences = {
    'likes': true,
    'comments': true,
    'newFollowers': true,
    'mentions': true,
    'subscriptions': true,
    'remixesAndDuets': true,
    'promotions': false,
    'milestones': true,
  };

  // Push notification settings
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  String _notificationSound = 'Default';
  bool _vibrate = true;
  
  // Time settings
  String _quietHoursStart = '22:00';
  String _quietHoursEnd = '08:00';
  bool _quietHoursEnabled = false;

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    
    if (picked != null) {
      setState(() {
        if (isStart) {
          _quietHoursStart = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
        } else {
          _quietHoursEnd = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Notification Settings'),
      ),
      body: ListView(
        children: [
          // Push Notifications Section
          _buildSectionHeader('Push Notifications'),
          SwitchListTile(
            title: const Text('Enable Push Notifications',
                style: TextStyle(color: Colors.white)),
            value: _pushNotifications,
            onChanged: (value) {
              setState(() => _pushNotifications = value);
            },
          ),
          if (_pushNotifications) ...[
            ListTile(
              title: const Text('Notification Sound',
                  style: TextStyle(color: Colors.white)),
              subtitle: Text(_notificationSound,
                  style: const TextStyle(color: Colors.grey)),
              trailing: const Icon(Icons.chevron_right, color: Colors.white),
              onTap: () {
                // TODO: Show sound picker
              },
            ),
            SwitchListTile(
              title: const Text('Vibrate',
                  style: TextStyle(color: Colors.white)),
              value: _vibrate,
              onChanged: (value) {
                setState(() => _vibrate = value);
              },
            ),
          ],

          const Divider(color: Colors.grey),

          // Email Notifications
          SwitchListTile(
            title: const Text('Email Notifications',
                style: TextStyle(color: Colors.white)),
            subtitle: const Text('Receive notifications via email',
                style: TextStyle(color: Colors.grey)),
            value: _emailNotifications,
            onChanged: (value) {
              setState(() => _emailNotifications = value);
            },
          ),

          const Divider(color: Colors.grey),

          // Quiet Hours
          _buildSectionHeader('Quiet Hours'),
          SwitchListTile(
            title: const Text('Enable Quiet Hours',
                style: TextStyle(color: Colors.white)),
            value: _quietHoursEnabled,
            onChanged: (value) {
              setState(() => _quietHoursEnabled = value);
            },
          ),
          if (_quietHoursEnabled)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => _selectTime(context, true),
                      child: Text('From: $_quietHoursStart',
                          style: const TextStyle(color: Colors.blue)),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () => _selectTime(context, false),
                      child: Text('To: $_quietHoursEnd',
                          style: const TextStyle(color: Colors.blue)),
                    ),
                  ),
                ],
              ),
            ),

          const Divider(color: Colors.grey),

          // Notification Types
          _buildSectionHeader('Notification Types'),
          ..._preferences.entries.map((entry) {
            return SwitchListTile(
              title: Text(_getPreferenceTitle(entry.key),
                  style: const TextStyle(color: Colors.white)),
              subtitle: Text(_getPreferenceDescription(entry.key),
                  style: const TextStyle(color: Colors.grey)),
              value: entry.value,
              onChanged: (value) {
                setState(() => _preferences[entry.key] = value);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getPreferenceTitle(String key) {
    switch (key) {
      case 'likes':
        return 'Likes';
      case 'comments':
        return 'Comments';
      case 'newFollowers':
        return 'New Followers';
      case 'mentions':
        return 'Mentions';
      case 'subscriptions':
        return 'Subscriptions';
      case 'remixesAndDuets':
        return 'Remixes & Duets';
      case 'promotions':
        return 'Promotional Updates';
      case 'milestones':
        return 'Milestones';
      default:
        return key;
    }
  }

  String _getPreferenceDescription(String key) {
    switch (key) {
      case 'likes':
        return 'When someone likes your content';
      case 'comments':
        return 'When someone comments on your content';
      case 'newFollowers':
        return 'When someone follows you';
      case 'mentions':
        return 'When someone mentions you';
      case 'subscriptions':
        return 'Subscription updates and new content';
      case 'remixesAndDuets':
        return 'When someone remixes or duets with your content';
      case 'promotions':
        return 'Promotional offers and updates';
      case 'milestones':
        return 'Achievement notifications';
      default:
        return '';
    }
  }
}