import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String userId; // Kullanıcı ID'si
  const ChangePasswordScreen({super.key, required this.userId});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  String? _errorMessage;

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      // Eski şifreyi doğrulama işlemi yapılacak
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Şu anki kullanıcı ile giriş yapılmış mı kontrol et
        AuthCredential credential = EmailAuthProvider.credential(
            email: user.email!,
            password: _oldPasswordController.text,
        );

        // Şifreyi doğrulama (eski şifreyi kontrol et)
        await user.reauthenticateWithCredential(credential);

        // Şifre doğrulandıysa yeni şifreyi güncelle
        await user.updatePassword(_newPasswordController.text);
        
        // Şifre başarıyla değiştirildi
        if (mounted) {
          // context kullanılarak widget render edilmişse
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Şifre başarıyla değiştirildi!')));
        }
      }
    } catch (e) {
      // Hata mesajını göster
      if (mounted) {
        setState(() {
          _errorMessage = 'Eski şifre yanlış veya başka bir hata oluştu';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Şifre Değiştir',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        centerTitle: true,
        leading: Container(),
        backgroundColor: const Color.fromARGB(255, 41, 55, 73),

      ),
        backgroundColor: const Color.fromARGB(255, 41, 55, 73),

      body: Padding(
  padding: const EdgeInsets.all(16.0),
  child: Form(
    key: _formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TextFormField(
          controller: _oldPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Eski Şifre',
            labelStyle: TextStyle(color: Colors.white), // Etiket rengini beyaz yap
            hintText: 'Eski şifrenizi girin',
            hintStyle: TextStyle(color: Colors.grey), // İpucu metnini gri yap
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white), // Normal alt çizgi beyaz
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue), // Odaklandığında alt çizgi mavi
            ),
          ),
          style: TextStyle(color: Colors.white), // Kullanıcının yazdığı metni beyaz yap
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Eski şifrenizi girin';
            }
            return null;
          },
        ),
        TextFormField(
          controller: _newPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Yeni Şifre',
            labelStyle: TextStyle(color: Colors.white),
            hintText: 'Yeni şifrenizi girin',
            hintStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
          ),
          style: TextStyle(color: Colors.white),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Yeni şifrenizi girin';
            }
            return null;
          },
        ),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Yeni Şifre (Tekrar)',
            labelStyle: TextStyle(color: Colors.white),
            hintText: 'Yeni şifrenizi tekrar girin',
            hintStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
          ),
          style: TextStyle(color: Colors.white),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Yeni şifrenizi tekrar girin';
            }
            if (value != _newPasswordController.text) {
              return 'Yeni şifreler eşleşmiyor';
            }
            return null;
          },
        ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red),
            ),
          ),
          const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _changePassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue, // Buton rengini mavi yaptım
            padding: EdgeInsets.symmetric(vertical: 15),
          ),
          child: const Text(
            'Şifreyi Değiştir',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ],
    ),
  ),
),

    );
  }
}
