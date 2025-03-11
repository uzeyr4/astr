// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class UserDetailsPage extends StatefulWidget {
  final String userId;

  const UserDetailsPage({super.key, required this.userId});

  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  late DatabaseReference _databaseReference;
  Map<dynamic, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _databaseReference = FirebaseDatabase.instance.ref("users/${widget.userId}");
    _fetchUserData();
  }

  void _fetchUserData() {
    _databaseReference.once().then((DatabaseEvent event) {
      setState(() {
        userData = event.snapshot.value as Map<dynamic, dynamic>?;
      });
    }).catchError((error) {
      print("Veri çekme hatası: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Kullanıcı Bilgileri",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: Container(),
        backgroundColor: const Color.fromARGB(255, 41, 55, 73),
      ),
      backgroundColor: const Color.fromARGB(255, 41, 55, 73),
      body: userData == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kullanıcı Adı
                  Center(
                    child: Column(
                      children: [
                        Text(
                          "${userData?['name']} ${userData?['surname']}",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 3,
                          width: 80,
                          color: Colors.blueAccent,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                  // Kullanıcı Bilgileri
                  _buildInfoRow("Doğum Tarihi", "${userData?['birthDate']}"),
                  _buildInfoRow("Doğum Saati", "${userData?['birthTime']}"),
                  _buildInfoRow("Burç", "${userData?['burc']}"),
                  _buildInfoRow("Yükselen", userData?['ascendant'].isEmpty ? "Belirtilmemiş" : userData?['ascendant']),
                  _buildInfoRow("Doğum Yeri", "${userData?['birthPlace']}"),
                  _buildInfoRow("Telefon", userData?['phone'].isEmpty ? "Belirtilmemiş" : userData?['phone']),
                  _buildInfoRow("Cinsiyet", userData?['gender'].isEmpty ? 'Belirtilmemiş' : userData?['gender']),
                  _buildInfoRow("Medeni Durum", userData?['maritalStatus'].isEmpty ? 'Belirtilmemiş' : userData?['maritalStatus']),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ),
        // ignore: deprecated_member_use
        Divider(color: Colors.white.withOpacity(0.5), thickness: 1), // Alt çizgi
      ],
    );
  }
}
