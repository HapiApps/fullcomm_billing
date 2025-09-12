import 'package:flutter/material.dart';

class ShortcutHelpDialog {
  static void show(BuildContext context) {
    final List<Map<String, String>> shortcuts = [
      {"key": "Alt + P", "action": "Print the bill you’re currently preparing"},
      {"key": "Alt + S", "action": "Open the page showing all saved bills"},
      {"key": "Alt + R", "action": "Reprint the most recently printed bill"},
      {"key": "Alt + C", "action": "Open the form to add a new customer"},
      {
        "key": "Alt + L",
        "action": "Update the stock list to see latest quantities"
      },
      {"key": "Alt + H", "action": "Show this list of shortcut keys"},
      {"key": "Alt + O", "action": "Log out of the billing system"},
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Row(
            children: [
              Icon(Icons.help_outline, color: Colors.blue),
              SizedBox(width: 4),
              Text("Shortcut Keys"),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: shortcuts.length,
              separatorBuilder: (context, index) => Divider(),
              itemBuilder: (context, index) {
                return ListTile(
                    leading: Icon(Icons.keyboard, color: Colors.blue),
                    title: Row(
                      children: [
                        Text(
                          shortcuts[index]['key']!,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "(${shortcuts[index]['action']!})", // <-- இங்க interpolation சரியாக
                        ),
                      ],
                    ));
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
