import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../data/local_data.dart';
import '../../view_models/credentials_provider.dart';
import '../../views/credentials/login_screen.dart';

class PrivacyPolicyDialog extends StatelessWidget {
  const PrivacyPolicyDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDataProvider>(
      builder: (context, userProvider, _) {
        return AlertDialog(
          title: const Text('Privacy Policy'),
          content: const SingleChildScrollView(
            child: Text(
              'Please accept our privacy '
              ' policy to continue.\n\n',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // first close dialog

                userProvider.privacyPolicy(
                    mobileNo: localData.userMobile,
                    password: "",
                    context: context);
              },
              child: const Text('Accept'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // first close dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              },
              child: const Text('cancel'),
            ),
          ],
        );
      },
    );
  }
}
