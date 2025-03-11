import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AdminPaneli extends StatefulWidget {
  const AdminPaneli({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPaneli> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("users");

  String _selectedFilter = "burc"; // Varsayılan filtre
  String _filterValue = ""; // Kullanıcının girdiği filtre değeri
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  // Firebase'den kullanıcıları getir
  void _fetchUsers() async {
    _dbRef.once().then((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.value != null) {
        Map<dynamic, dynamic> usersMap = snapshot.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> userList = [];

        usersMap.forEach((key, value) {
          userList.add({"id": key, ...Map<String, dynamic>.from(value)});
        });

        setState(() {
          _users = userList;
        });
      }
    });
  }

  // Seçilen kritere göre kullanıcıları filtrele
  List<Map<String, dynamic>> _getFilteredUsers() {
    if (_filterValue.isEmpty) return _users;

    return _users.where((user) {
      return user[_selectedFilter]?.toString().toLowerCase() == _filterValue.toLowerCase();
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredUsers = _getFilteredUsers();

    return Scaffold(
      appBar: AppBar(title: Text("Admin Paneli - Kullanıcı Filtreleme")),
      body: Column(
        children: [
          // Filtreleme Seçenekleri
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedFilter,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedFilter = newValue!;
                        _filterValue = "";
                      });
                    },
                    items: [
                      "burc",
                      "ascendant",
                      "gün",
                      "ay",
                      "yıl"
                    ].map((filter) {
                      return DropdownMenuItem(
                        value: filter,
                        child: Text(filter.toUpperCase()),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(width: 10),
                // Filtre Değeri Girişi
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "Değer girin",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _filterValue = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: filteredUsers.isEmpty
                ? Center(child: Text("Sonuç bulunamadı"))
                : ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      var user = filteredUsers[index];
                      return ListTile(
                        title: Text(user["name"] ?? "Bilinmeyen"),
                        subtitle: Text("Burç: ${user["burc"]}, Yükselen: ${user["ascendant"]}"),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
