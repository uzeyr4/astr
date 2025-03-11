import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  _NotificationSettingsPageState createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool isNotificationsEnabled = false; // Varsayılan olarak kapalı
  final DatabaseReference _database = FirebaseDatabase.instance.ref(); // Firebase DB referansı
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    loadNotificationPreference(); // Kullanıcının tercihini yükle
  }

  /// 🔥 Kullanıcının bildirim tercihini yükle
  void loadNotificationPreference() async {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      final snapshot = await _database.child('users/$userId/notificationEnabled').get();
      if (snapshot.exists) {
        setState(() {
          isNotificationsEnabled = snapshot.value as bool;
        });
      }
    }
  }

  /// 🔥 Kullanıcının bildirim tercihini güncelle
  void updateNotificationPreference(bool value) async {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      await _database.child('users/$userId').update({'notificationEnabled': value});
      setState(() {
        isNotificationsEnabled = value;
      });

      if (value) {
        await FirebaseMessaging.instance.subscribeToTopic('all_users');
      } else {
        await FirebaseMessaging.instance.unsubscribeFromTopic('all_users');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bildirim Ayarları", 
      style: (TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold
      )),),
      leading: Container(),
      centerTitle: true,
      backgroundColor: const Color.fromARGB(255, 41, 55, 73),  // Background color updated
      ),
      backgroundColor: const Color.fromARGB(255, 41, 55, 73),  // Background color updated
      body: Column(
        children: [
          ListTile(
            title: const Text(
              "Bildirimleri Aç/Kapat",
              style: TextStyle(color: Colors.white),  // Text color to contrast with the background
            ),
            trailing: Switch(
              value: isNotificationsEnabled,
              onChanged: (value) {
                updateNotificationPreference(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}
