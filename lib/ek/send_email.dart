
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  Future<void> sendEmail() async {
    final url = Uri.parse('https://seninbackend.com/send-mail'); // FastAPI URL
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': nameController.text,
        'email': emailController.text,
        'subject': subjectController.text,
        'message': messageController.text,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Mail başarıyla gönderildi"),
          backgroundColor: Colors.green));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Mail gönderme başarısız"),
          backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('İletişim')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: nameController, decoration: InputDecoration(labelText: 'Adınız')),
              TextFormField(controller: emailController, decoration: InputDecoration(labelText: 'E-posta')),
              TextFormField(controller: subjectController, decoration: InputDecoration(labelText: 'Konu')),
              TextFormField(controller: messageController, decoration: InputDecoration(labelText: 'Mesaj'), maxLines: 4),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: sendEmail,
                child: Text('Gönder'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
