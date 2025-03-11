import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// Bildirim ayarları sayfasını ekledik
class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 41, 55, 73),
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            
            // İçerik
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo ekleme
                    Image.asset(
                      "assets/astro4ever_logo.png",
                      width: 200, // Logonun genişliği
                      height: 200, // Logonun yüksekliği
                    ),
                    const SizedBox(height: 20), // Logo ile başlık arası boşluk
                    const Text(
                      "Profilim",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20), // Başlık ile butonlar arası boşluk
                    _buildButton(
                      text: "Hesap Bilgileri",
                      icon: Icons.account_circle,
                      onPressed: () {Navigator.pushNamed(context, '/user_detail');
                        // Hesap bilgileri sayfasına yönlendirme
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildButton(
                      text: "Şifre Değiştir",
                      icon: Icons.lock,
                      onPressed: () {Navigator.pushNamed(context, '/change_password');
                        // Şifre değiştirme ekranına yönlendirme
                      },
                    ),
                    const SizedBox(height: 10),

                    _buildButton(
                      text: "Bildirim Ayarları",
                      icon: Icons.notifications,
                      onPressed: () {Navigator.pushNamed(context, '/notification_settings');
                        // Ş
                      },
                    ),
                     

                    const SizedBox(height: 10),
                    _buildButton(
                      text: "Çıkış Yap",
                      icon: Icons.exit_to_app,
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut(); // Kullanıcı oturumunu kapat
                        Navigator.pushNamedAndRemoveUntil(context, '/LoginPage', (route) => false);
                      },
                    ),

                    const SizedBox(height: 10),
                    _buildButton(
                      text: "Hesabımı Sil",
                      icon: Icons.delete_forever,
                      onPressed: () {Navigator.pushNamed(context, '/delete_user');
                        // Hesap silme işlemi için onay ekranı
                      },
                      backgroundColor: Colors.redAccent.shade100, // Silme işlemi için kırmızı
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    Color backgroundColor = Colors.blueGrey,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // Yuvarlak kenarlar
        ),
        elevation: 5, // Gölge
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 10), // İkon ile metin arası boşluk
          Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}


