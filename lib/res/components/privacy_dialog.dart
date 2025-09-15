import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/local_data.dart';
import '../../view_models/credentials_provider.dart';
import '../../views/credentials/login_screen.dart';

class PrivacyPolicyDialog extends StatefulWidget {
  const PrivacyPolicyDialog({Key? key}) : super(key: key);

  @override
  State<PrivacyPolicyDialog> createState() => _PrivacyPolicyDialogState();
}

class _PrivacyPolicyDialogState extends State<PrivacyPolicyDialog> {
  bool _expanded = false;

  // Put the long policy text here (or load from assets)
  final String _privacyPolicyFull = '''
Privacy Policy
Hapi Apps has provided this Privacy Policy to familiarise User to

The type of data or information that User share with or provide to Hapi Apps and that Hapi Apps collects from User;
The purpose for collection of such data or information from User; Hapi Apps information security practices and policies; and
Hapi Apps policy on sharing or transferring User’s data or information with third parties
This Privacy Policy may be amended / updated from time to time. Upon amending / updating the Privacy Policy, we will accordingly amend the date above. We suggest that User regularly check this Privacy Policy to apprise themselves of any updates. Users continued use of App or provision of data or information thereafter will imply their unconditional acceptance of such updates to this Privacy Policy.
Information collected and storage of such Information:
The Information (which shall also include data) provided by User to Hapi Apps or collected from User by Hapi Apps may consist of Personal Information and Non-Personal Information.
1 Information collected

Personal Information

Personal Information is Information collected that can be used to uniquely identify or contact the User. Personal Information for the purposes of this Privacy Policy shall include, but not be limited to:

- Full Name
- Photo
- Addresses User travels to
- Mobile number
- E-mail address
- Date of birth
- Vehicle details and registration plate number
- Information regarding users transactions on the App , (including Drive or Ride history)
- Bank account information and user’s preferences to use credit card or debit card or other payment modes
- Internet Protocol address, devices details that is used to install the App or browse the Website
- Any other items of sensitive personal data or information as such term is defined under the Information Technology (Reasonable Security Practices And Procedures And Sensitive Personal Data Of Information) Rules, 2011 enacted under the Information Technology Act, 2000
- Identification code of user’s communication device which they use to access the App/Website or otherwise deal with any Hapi Apps entity
- Any other Information that provided during the registration process, if any, on the App
Such Personal Information may be collected in various ways including during the course of User:

- registering as a User on the App
- availing certain services offered on the App. Such instances include but are not limited to making an offer providing vehicle for ride sharing, participating in ride sharing, any online survey or contest, communicating with Hapi Apps customer service by phone, email or otherwise or posting user reviews on the App
- otherwise doing business on the App/Website or otherwise dealing with any Hapi Apps entity
- we may receive Personal information about User from third parties, such as social media services, commercially available sources and business partners. If user access App/Website through a social media service or connect a service on App/Website to a social media service, the information we collect may include user name associated with that social media service, any information or content the social media service has the right to share with us, such as profile picture, email address or friends list, and any information user have made public in connection with that social media service. When user access the App/Website or otherwise deal with any Hapi Apps entity through social media services or when user connect any App/Website to social media services, user is authorizing Hapi Apps to collect, store, and use and retain such information and content in accordance with this Privacy Policy
Non-Personal Information

hapi apps may also collect information other than Personal Information from User through the app when User visit and / or use the App. Such information may be stored in third party’s server logs. This Non-Personal Information would not assist hapi apps to identify User personally
This Non-Personal Information may include User’s:

- geographic location
- telecom service provider or internet service provider details
- the type of browser (Internet Explorer, Firefox, Opera, Google Chrome etc.)
- the operating system, device and the Website User last visited before visiting the App/Website
- duration of stay on the App/Website is also stored in the session along with the date and time of access
2 Links to third party websites

Links to third-party advertisements, third-party websites or any third party electronic communication service may be provided on the App/Website which are operated by third parties and are not controlled by, or affiliated to, or associated with, Hapi Apps unless expressly specified on the App/Website
3 Security & Retention

The security of User’s Personal Information is important to us. Hapi Apps endeavors to ensure the security of personal information and to protect against unauthorized access or unauthorized alteration, disclosure or destruction. For this purpose, Hapi Apps adopts internal reviews of the data collection, storage and processing practices and security measures, including appropriate encryption and physical security measures to guard against unauthorized access to systems from where Hapi Apps accesses user’s personal information. Each of the Hapi Apps entity shall adopt reasonable security practices and procedures as mandated under applicable laws for the protection of information entered. Provided that user right to claim damages shall be limited to the right to claim only statutory damages under Information Technology Act, 2000 and User hereby waive and release all Hapi Apps entities from any claim of damages under contract or under tort
When user use the payment gateway to complete any transaction on the App or website then their credit card data may be stored, with user’s permission, at the payment gateway controlled by the payment gateway and not accessible to Hapi Apps. The rules to this are governed by payment gateway
4 User discretion and opt out

User can add or update their Personal Information on regular basis. Kindly note that Hapi Apps would retain the previous Personal Information in its records  ''';

  @override
  Widget build(BuildContext context) {
    final userProvider = context.read<UserDataProvider>();

    return AlertDialog(
      title: const Text('Privacy Policy'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _expanded
                  ? _privacyPolicyFull
                  : _privacyPolicyFull.length > 250
                      ? _privacyPolicyFull.substring(0, 250) + '…'
                      : _privacyPolicyFull,
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Text(
                _expanded ? 'Read less' : 'Read more',
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            userProvider.privacyPolicy(
              mobileNo: localData.userMobile,
              password: "12345678",
              context: context,
            );
          },
          child: const Text('Accept'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ),
            );
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
