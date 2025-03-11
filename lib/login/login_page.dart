// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false; // Yükleniyor durumu

  /// **Kullanıcının cihaz token’ını alıp Firebase Realtime Database’e kaydeder**
  Future<void> getDeviceTokenAndSaveToDatabase() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();

    if (token != null) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final databaseRef = FirebaseDatabase.instance.ref('users/$userId');
        await databaseRef.update({
          'deviceToken': token, // Kullanıcının cihaz token'ını kaydet
        });
      }
    }
  }

  /// **Giriş Fonksiyonu**
  Future<void> _login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError("Email ve şifre boş olamaz!");
      return;
    }

    setState(() {
      _isLoading = true; // Yükleniyor durumu aktif
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Kullanıcı giriş yaptıysa token'ı kaydet
      if (userCredential.user != null && mounted) {
        await getDeviceTokenAndSaveToDatabase(); // Token kaydetme işlemi
        Navigator.pushNamed(context, '/MessagePage');
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      if (e.code == 'user-not-found') {
        _showError("Kullanıcı bulunamadı. Lütfen kayıt olun.");
      } else if (e.code == 'wrong-password') {
        _showError("Şifre hatalı. Lütfen tekrar deneyin.");
      } else {
        _showError("Giriş başarısız.");
      }
    } finally {
      setState(() {
        _isLoading = false; // Yükleniyor durumu kapalı
      });
    }
  }

  /// **Firebase’den alıcı kullanıcının token’ını al**
  Future<String?> getReceiverToken(String receiverId) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref('users/$receiverId/deviceToken');
    DatabaseEvent event = await ref.once();
    return event.snapshot.value?.toString();
  }

  /// **Hata Mesajını Gösterme**
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                Center(
                  child: Image.asset(
                    "assets/astro4ever_logo.png",
                    width: 150,
                    height: 150,
                  ),
                ),
                const SizedBox(height: 40),
                _inputField(),
                const SizedBox(height: 5),
                _forgotPassword(),
                const Spacer(),
                _signup(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: emailController,
          decoration: InputDecoration(
            hintText: "Email",
            hintStyle: const TextStyle(color: Colors.white),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            fillColor: Colors.blueGrey,
            filled: true,
            prefixIcon: const Icon(Icons.person, color: Colors.white),
          ),
          style: TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: "Şifre",
            hintStyle: const TextStyle(color: Colors.white),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            fillColor: Colors.blueGrey,
            filled: true,
            prefixIcon: const Icon(Icons.password, color: Colors.white),
          ),
          style: TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isLoading ? null : _login, // Yükleniyor ise butona basılamaz
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.lightBlueAccent,
          ),
          child: _isLoading
              ? CircularProgressIndicator() // Yükleniyor göstergesi
              : const Text(
                  "Giriş Yap",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
        ),
      ],
    );
  }

  Widget _forgotPassword() {
    return TextButton(
      onPressed: () => Navigator.pushNamed(context, '/forget_password'),
      style: TextButton.styleFrom(
        backgroundColor: Colors.transparent, // Arka planı şeffaf yapar
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // İç boşluk
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Köşeleri yuvarlak yapar
        ),
      ),
      child: const Text(
        "Şifremi Unuttum",
        style: TextStyle(
          color: Colors.white, // Yazı rengi beyaz
          fontWeight: FontWeight.bold, // Yazıyı kalın yapar
        ),
      ),
    );
  }

  Widget _signup() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Henüz hesabın yok mu?  ",
            style: TextStyle(color: Colors.white)),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/SignupPage'),
          child: const Text("Kayıt Ol", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
