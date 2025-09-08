import 'package:flutter/material.dart';

class ShortcutHelpDialog {
  static void show(BuildContext context) {
    final List<Map<String, String>> shortcuts = [
      {"key": "Alt + P", "action": "Print current bill (if items exist)"},
      {"key": "Alt + S", "action": "Open order detail page"},
      {
        "key": "Alt + R",
        "action": "View last bill (future functionality placeholder)"
      },
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.help_outline, color: Colors.blue),
              SizedBox(width: 8),
              Text("Shortcut Keys"),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: shortcuts.length,
              separatorBuilder: (context, index) => Divider(),
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.keyboard, color: Colors.blue),
                  title: Text(
                    shortcuts[index]['key']!,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(shortcuts[index]['action']!),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: Text("Close"),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        );
      },
    );
  }
}
