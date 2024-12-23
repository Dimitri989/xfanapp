import 'package:flutter/material.dart';

class AutoplaySettings extends StatelessWidget {
  final bool autoplayEnabled;
  final Function(bool) onAutoplayChanged;
  final String currentQuality;
  final Function(String) onQualityChanged;

  const AutoplaySettings({
    super.key,
    required this.autoplayEnabled,
    required this.onAutoplayChanged,
    required this.currentQuality,
    required this.onQualityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
            // Autoplay Switch
            SwitchListTile(
              title: const Text(
                'Autoplay Videos',
                style: TextStyle(color: Colors.white),
              ),
              value: autoplayEnabled,
              onChanged: onAutoplayChanged,
              activeColor: Colors.blue,
            ),
            const Divider(color: Colors.white24),
            // Quality Selector
            ListTile(
              title: const Text(
                'Video Quality',
                style: TextStyle(color: Colors.white),
              ),
              trailing: DropdownButton<String>(
                value: currentQuality,
                dropdownColor: Colors.black87,
                style: const TextStyle(color: Colors.white),
                underline: Container(
                  height: 2,
                  color: Colors.blue,
                ),
                onChanged: (String? newValue) {
                  if (newValue != null) onQualityChanged(newValue);
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
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}