import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // SystemNavigator için gerekli import

class MessagePage extends StatefulWidget {
  final String userId;

  const MessagePage({super.key, required this.userId});

  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  late DatabaseReference _dbRef;
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    _dbRef = FirebaseDatabase.instance.ref("users/${widget.userId}/notifications");
    _getNotifications();
    _markNotificationsAsRead(); // Bildirimleri okundu olarak işaretle
  }

  // Bildirimleri Firebase'den al
  void _getNotifications() {
    _dbRef.onChildAdded.listen((DatabaseEvent event) {
      if (mounted) {
        setState(() {
          var notif = Map<String, dynamic>.from(event.snapshot.value as Map<dynamic, dynamic>);
          notifications.add(notif);
        });
      }
    });
  }

  // Bildirimleri 'read: true' olarak işaretle
  void _markNotificationsAsRead() {
    _dbRef.once().then((DatabaseEvent snapshot) {
      if (snapshot.snapshot.value != null) {
        for (var childSnapshot in snapshot.snapshot.children) {
          childSnapshot.ref.update({'read': true});
        }
      }
    });
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


  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Mesajlar",
            style: TextStyle(color: Colors.white), // AppBar başlığını beyaz yapıyoruz
          ),
          backgroundColor: const Color.fromARGB(255, 41, 55, 73), // AppBar rengini koyu mavi yapıyoruz
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.account_circle, color: Colors.white), // İkonun rengini beyaz yapıyoruz
            iconSize: 40.0, // İkonu büyütüyoruz
            onPressed: () {
              Navigator.pushNamed(context, '/account_settings');
            },
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 41, 55, 73),
        body: notifications.isEmpty
            ? Center(child: Text("Henüz mesajınız yok", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)))
            : ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  var notif = notifications[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 132, 161, 185),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Başlık
                          Text(
                            notif['title'] ?? 'Başlık yok',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white
                            ),
                          ),
                          SizedBox(height: 5),
                          // Mesaj
                          Text(
                            notif['body'] ?? 'Mesaj yok',
                            style: TextStyle(fontSize: 14,color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
