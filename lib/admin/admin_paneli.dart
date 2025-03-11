import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> getDeviceToken() async {
  String? token = await FirebaseMessaging.instance.getToken();
  print("Device Token: $token");
}

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  String? _selectedBurc;
  String? _selectedAscendant;
  int? _selectedGun;
  int? _selectedAy;
  int? _selectedYil;

  final List<String> _burcList = [
    'Koç', 'Boğa', 'İkizler', 'Yengeç', 'Aslan', 'Başak', 'Terazi',
    'Akrep', 'Yay', 'Oğlak', 'Kova', 'Balık'
  ];

  final List<String> _ascendantList = [
    'Koç', 'Boğa', 'İkizler', 'Yengeç', 'Aslan', 'Başak', 'Terazi',
    'Akrep', 'Yay', 'Oğlak', 'Kova', 'Balık'
  ];

  final List<int> _gunList = List.generate(31, (index) => index + 1);
  final List<int> _ayList = List.generate(12, (index) => index + 1);
  final List<int> _yilList = List.generate(
    DateTime.now().year - 1900 + 1,
    (index) => 1900 + index,
  );
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final TextEditingController _bodyController = TextEditingController();

  Future<void> sendPushNotification(String token, String title, String body) async {
    const String apiUrl = "https://uzeyir.pythonanywhere.com/send_notification"; // API URL'nizi buraya girin

    final Map<String, dynamic> message = {
      "token": token,
      "title": title,
      "body": body,
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print("Bildirim başarıyla gönderildi: ${response.body}");
    } else {
      print("FCM Hata: ${response.body}");
    }
  }


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
 Future<void> sendNotificationToFilteredUsers() async {
  String body = _bodyController.text;

  if (body.isEmpty) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mesaj içeriği boş olamaz.')),
      );
    }
    return;
  }

  DatabaseEvent usersEvent = await _database.child('users').once();

  if (usersEvent.snapshot.exists) {
    Map<dynamic, dynamic> users = Map<dynamic, dynamic>.from(usersEvent.snapshot.value as Map);

    // Kullanıcıları filtrele
    List<String> userTokensToNotify = [];
    
    for (var entry in users.entries) {
      String userId = entry.key;
      var userData = entry.value;

      bool matchesFilter = true;

      // Burç filtresi
      if (_selectedBurc != null && userData['burc'] != _selectedBurc) {
        matchesFilter = false;
      }

      // Yükselen Burç filtresi
      if (_selectedAscendant != null && userData['ascendant'] != _selectedAscendant) {
        matchesFilter = false;
      }

      // Gün filtresi - String ile karşılaştırma
      if (_selectedGun != null && userData['gun'] != _selectedGun.toString()) {
        matchesFilter = false;
      }

      // Ay filtresi - String ile karşılaştırma
      if (_selectedAy != null && userData['ay'] != _selectedAy.toString()) {
        matchesFilter = false;
      }

      // Yıl filtresi - String ile karşılaştırma
      if (_selectedYil != null && userData['yil'] != _selectedYil.toString()) {
        matchesFilter = false;
      }

      // Filtreye uyan kullanıcıyı bulduysak, token'ı ekle
      if (matchesFilter) {
        String dynamicTitle = "Sevgili, ${userData['name']}";
        String? deviceToken = userData['deviceToken'];

        if (deviceToken != null) {
          userTokensToNotify.add(deviceToken); // Kullanıcının cihaz token'ını listeye ekle
        }

        // Bildirimi kullanıcıya kaydet
        var notificationRef = _database.child('users/$userId/notifications').push();
        await notificationRef.set({
          'title': dynamicTitle,
          'body': body,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'read': false,
        });
      }
    }

    if (userTokensToNotify.isNotEmpty) {
      // Bildirimi tüm uygun kullanıcılara gönder
      for (String token in userTokensToNotify) {
        sendPushNotification(token, "Yeni Bildirim", body);  // Token listesi ile her kullanıcıya bildirim gönder
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bildirimler başarıyla gönderildi!')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Filtreye uygun kullanıcı bulunamadı.')),
        );
      }
    }

    // Mesaj içeriğini temizle
    _bodyController.clear();
  } else {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veritabanından kullanıcı verileri alınamadı.')),
      );
    }
  }
}



//////////////////////////////////////////////////////////////////////////////////////////////////////////////


  @override
   Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Paneli",
      style:TextStyle(color: Colors.white), 
      ),
      leading: Container(),
      centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 41, 55, 73),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(  // Add this to make the layout scrollable
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedBurc,
                hint: Text("Burç Seçin"),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedBurc = newValue;
                  });
                },
                items: _burcList.map((burc) {
                  return DropdownMenuItem<String>(
                    value: burc,
                    child: Text(burc),
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedAscendant,
                hint: Text("Yükselen Burç Seçin"),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedAscendant = newValue;
                  });
                },
                items: _ascendantList.map((asc) {
                  return DropdownMenuItem<String>(
                    value: asc,
                    child: Text(asc),
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: DropdownButtonFormField<int>(
                    value: _selectedGun,
                    hint: Text("Gün"),
                    items: _gunList.map((gun) => DropdownMenuItem(value: gun, child: Text("$gun"))).toList(),
                    onChanged: (value) => setState(() => _selectedGun = value),
                  )),
                  SizedBox(width: 10),
                  Expanded(child: DropdownButtonFormField<int>(
                    value: _selectedAy,
                    hint: Text("Ay"),
                    items: _ayList.map((ay) => DropdownMenuItem(value: ay, child: Text("$ay"))).toList(),
                    onChanged: (value) => setState(() => _selectedAy = value),
                  )),
                  SizedBox(width: 10),
                  Expanded(child: DropdownButtonFormField<int>(
                    value: _selectedYil,
                    hint: Text("Yıl"),
                    items: _yilList.map((yil) => DropdownMenuItem(value: yil, child: Text("$yil"))).toList(),
                    onChanged: (value) => setState(() => _selectedYil = value),
                  ))
                ],
              ),
              SizedBox(height: 16),
              
              SizedBox(height: 8),
              TextField(
                controller: _bodyController,
                decoration: InputDecoration(labelText: 'Mesaj İçeriği'),
                maxLines: 4,
              ),
              SizedBox(height: 16),
              // Wrap the button with an Expanded widget if needed
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: sendNotificationToFilteredUsers,
                      child: Text("Filtreye Uyan Kullanıcılara Mesaj Gönder"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

