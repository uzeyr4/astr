// ignore_for_file: unused_import

import 'package:as_app/login/kullanici_sozlesmesi.dart';
import 'package:as_app/account%20settings/change_password.dart';
import 'package:as_app/account%20settings/delete_user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';
// Import the generated file
import 'firebase_options.dart';
import 'login/login_page.dart';
import 'login/signup_page1.dart';
import 'pages/message.dart';
import 'pages/first_message.dart';
import 'pages/payment.dart';
import 'account settings/account_settings.dart';
import 'admin/admin_paneli.dart';
import 'ek/kullanici_list.dart';

import 'login/forget_password.dart';
import 'account settings/kullanıcı_bilgileri.dart';
import 'admin/_admin_user_list.dart';
import 'services/notification_service.dart'; 
import 'account settings/notification_settings.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Arka plan mesajlarını işleyin
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // initialRoute'u dinamik olarak ayarla
      initialRoute: FirebaseAuth.instance.currentUser != null ? '/MessagePage' : '/',
      routes: {
        '/MessagePage': (context) {
          final userId = FirebaseAuth.instance.currentUser?.uid;
          final userEmail = FirebaseAuth.instance.currentUser?.email;
          if (userEmail== "uzeyrkara7@gmail.com" ) 
          {
            return AdminPanelUsersPage();
          } 
          
          if(userId  != null) {
              return MessagePage(userId: userId); // userId'yi buraya geçiyoruz
            } else {
            return LoginPage();

            }

          
        },
        '/LoginPage': (context) => const LoginPage(),
        '/SignupPage': (context) => const SignupPage(),
        '/': (context) => const FirstPage(),
        '/forget_password': (context) => const ResetPasswordScreen(),

        '/PaymentPage': (context) => const PaymentPage(),


        '/account_settings': (context) => const AccountSettingsPage(),
        '/user_detail': (context){
          final userId = FirebaseAuth.instance.currentUser?.uid;
          return UserDetailsPage(userId: userId!); 
        } ,

        '/change_password': (context){
          final userId = FirebaseAuth.instance.currentUser?.uid;
          return ChangePasswordScreen(userId: userId!); 
        } ,
         
        '/privacy_policy': (context) => const PrivacyPolicyScreen(),
        '/delete_user': (context) => const DeleteUserPage(),
        '/notification_settings': (context) => NotificationSettingsPage(),

        

      
        '/AdminPanelimessage': (context) => AdminPanel(),
        '/AdminPaneliPage': (context) => AdminPanelUsersPage(),
        
        
       



      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

    @override
  void initState() {
    super.initState();
     NotificationService.requestPermission();
    setupFirebaseMessaging();
  }

void setupFirebaseMessaging() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print("İzin verildi");

    // Kullanıcının bildirim tercihlerini Firebase'den kontrol et
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final snapshot = await FirebaseDatabase.instance.ref('users/$userId/notificationEnabled').get();
      if (snapshot.exists && snapshot.value == true) {
        await FirebaseMessaging.instance.subscribeToTopic('all_users');
      }
    }
  } else {
    print("İzin verilmedi");
  }

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Foreground Message: ${message.notification?.title}');
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('Notification Opened: ${message.notification?.title}');
  });
}


  

  // Token'ı Firebase Realtime Database'e kaydetme
  Future<void> saveDeviceTokenToDatabase(String token) async {
    final databaseRef = FirebaseDatabase.instance.ref('users/${FirebaseAuth.instance.currentUser?.uid}');
    await databaseRef.update({
      'deviceToken': token, // Token'ı 'deviceToken' olarak kaydediyoruz
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('FCM Notifications')),
      body: Center(child: Text('Push Notifications App')),
    );
  }
}
