import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AdminPanelUsersPage extends StatefulWidget {
  const AdminPanelUsersPage({super.key});

  @override
  _AdminPanelPageState createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelUsersPage> {
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref('users');
  List<Map<String, String>> users = [];

  @override
  void initState() {
    super.initState();
    _getUsers();
  }


Future<bool> _onWillPop() async {
  bool shouldExit = await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color.fromARGB(255, 50, 65, 85), // Diyalog arkaplan rengini koyu yap
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Kenarları yuvarlak yap
      ),
      title: Text(
        "Çıkmak istediğinize emin misiniz?",
        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false); // Hayır'a basınca kapanacak
          },
          child: Text("Hayır", style: TextStyle(color: Colors.white70, fontSize: 16)),
        ),
        TextButton(
          onPressed: () {
            SystemNavigator.pop(); // Evet'e basınca çıkış yapacak
          },
          child: Text("Evet", style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
  return shouldExit;
}



_getUsers() async {
  DataSnapshot snapshot = await _usersRef.get();
  if (snapshot.exists) {
    Map<String, dynamic> usersData = Map.from(snapshot.value as Map);
    setState(() {
      users = usersData.entries.map((entry) {
        return {
          'id': entry.key,
          'name': entry.value['name'] as String,  // Tür dönüşümü yapıyoruz
          'surname': entry.value['surname'] as String,  // Tür dönüşümü yapıyoruz
        };
      }).toList();
    });
  }
}


  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _onWillPop, 
      child: Scaffold(
        appBar: AppBar(
          title: Text('Admin Panel',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
          leading: IconButton(
          icon: Icon(Icons.account_circle, color: Colors.white, size: 35.0),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          },
        ),
          backgroundColor: const Color.fromARGB(255, 41, 55, 73),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.message),
              color: Colors.white,
              iconSize: 35.0,
              onPressed: () {
                Navigator.pushNamed(context, '/AdminPanelimessage');
              },
            ),
          ],
        ),
        
        body: ListView.separated(
          itemCount: users.length,
          separatorBuilder: (context, index) => Divider(color: Colors.blueGrey,),
          itemBuilder: (context, index) {
            return ListTile(
              title: Text('${users[index]['name']} ${users[index]['surname']}',
              style: TextStyle(color: Colors.black),),
              onTap: () {
                String userId = users[index]['id']!;
                // Kullanıcıya ait bildirimleri göstermek için
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserNotificationsPage(userId: userId),
                  ),
                );
                Divider(color: Colors.white, thickness: 1); // Alt çizgir
              },
              
            );
          },
        ),
      ),
    );
  }
}



class UserNotificationsPage extends StatefulWidget {
  final String userId;
  const UserNotificationsPage({super.key, required this.userId});

  @override
  _UserNotificationsPageState createState() => _UserNotificationsPageState();
}

class _UserNotificationsPageState extends State<UserNotificationsPage> {
  final DatabaseReference _notificationsRef = FirebaseDatabase.instance.ref('users');
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    _getNotifications();
  }

  _getNotifications() async {
    // Firebase'den bildirimleri al
    DataSnapshot snapshot = await _notificationsRef.child(widget.userId).child('notifications').get();
    if (snapshot.exists) {
      Map<String, dynamic> notificationsData = Map.from(snapshot.value as Map);
      setState(() {
        notifications = notificationsData.entries.map((entry) {
          return {
            'title': entry.value['title'],
            'body': entry.value['body'],
            'timestamp': entry.value['timestamp'],
            'read': entry.value['read'],
          };
        }).toList();
      });
    } else {
      setState(() {
        notifications = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mesajlar', style: TextStyle(color: Colors.white),),
      leading: Container(),
        backgroundColor: const Color.fromARGB(255, 41, 55, 73),
        centerTitle: true,),
      body: notifications.isEmpty
          ? Center(child: Text("Henüz mesaj atılmadı"))
          : ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (context, index) => Divider(),
              itemBuilder: (context, index) {
                var notification = notifications[index];
                return ListTile(
                  title: Text(notification['title']!),
                  subtitle: Text(notification['body']!),
                  trailing: notification['read'] ? Icon(Icons.check_circle) : Icon(Icons.radio_button_unchecked),
                );
                
              },
            ),
    );
  }
}


class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profil"),
        backgroundColor: Color.fromARGB(255, 41, 55, 73),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_circle, size: 100, color: Colors.blueGrey),
            SizedBox(height: 20),
            _buildButton(
              text: "Çıkış Yap",
              icon: Icons.exit_to_app,
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(
                    context, '/LoginPage', (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({required String text, required IconData icon, required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white),
      label: Text(text, style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onPressed,
    );
  }
}
