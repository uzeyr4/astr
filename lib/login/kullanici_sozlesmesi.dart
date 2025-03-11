import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,)
         
        ),
        leading: Container(),
        backgroundColor: const Color.fromARGB(255, 41, 55, 73),
        centerTitle: true,
      ),
      backgroundColor: const Color.fromARGB(255, 41, 55, 73),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            
            children: [
              
              Text(
                'Privacy Policy for Astro4ever\n\n'
                'Thank you for using Astro4ever (the "App"). This Privacy Policy explains how we collect, use, disclose, and protect your personal information when you use our App. By accessing or using our App, you signify your consent to the practices described in this Privacy Policy. Please read this Privacy Policy carefully to understand our practices regarding your personal information.\n\n'
                
                'Information We Collect\n\n'
                'Google Login and Apple Login: When you use our App, you have the option to log in using your Google or Apple credentials. In order to provide this functionality, we may collect certain information from your Google or Apple account, such as your name and email address. We only collect this information with your explicit consent and use it to authenticate and identify you within our App.\n\n'
                
                'Contacts List: To enhance your user experience and facilitate connections within the App, we may request access to your contacts list. This enables us to identify and display your friends who are also using Astro4ever making it easier for you to connect with them. We want to emphasize that we respect your privacy and handle your contacts list with care.\n\n'

                'Collection and Storage of Contact Information: When you grant access to your contacts list, we collect and store the necessary information to identify your friends who are using the App. This information includes names, phone numbers, and email addresses, but we do not store any additional details associated with your contacts.\n\n'

                'Security\n\n'
                'Data Security: We take reasonable measures to protect the personal information we collect from unauthorized access, disclosure, alteration, or destruction. However, no method of transmission over the internet or electronic storage is completely secure, and therefore, we cannot guarantee its absolute security.\n\n'

                'Children\'s Privacy\n\n'
                'Our App is intended for users who are at least 18 years old. We do not knowingly collect personal information from children under the age of 18. If we become aware that we have collected personal information from a child under the age of 18, we will take steps to remove that information from our servers.\n\n'

                'Changes to the Privacy Policy\n\n'
                'We reserve the right to modify this Privacy Policy at any time, and any changes will be effective upon posting the updated policy on our website or within the App. We encourage you to review this Privacy Policy periodically for any updates or changes. Your continued use of the App after any modifications to the Privacy Policy will signify your acceptance of the updated terms.\n\n'

                'CONTACT US\n\n'
                'Contact Astro4ever to find out how we can help on your astrological journey! support@astro4ever.com\n\n',
                style: TextStyle(fontSize: 16, height: 1.5,color: Colors.white),
              ),
              SizedBox(height: 10),
              
            ],
          ),
        ),
      ),
    );
  }
}
