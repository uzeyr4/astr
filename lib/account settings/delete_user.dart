import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DeleteUserPage extends StatefulWidget {
  const DeleteUserPage({super.key});

  @override
  _DeleteUserPageState createState() => _DeleteUserPageState();
}

class _DeleteUserPageState extends State<DeleteUserPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> deleteUser() async {
    setState(() => isLoading = true);

    User? user = _auth.currentUser;

    if (user != null) {
      try {
        // Eğer kullanıcı parolasıyla giriş yaptıysa, yeniden kimlik doğrulama isteyelim
        for (var provider in user.providerData) {
          if (provider.providerId == "password") {
            await reauthenticateAndDeleteUser();
            return;
          }
        }

        // Diğer sağlayıcılar (Google, Facebook vs.) ile giriş yapılmışsa, doğrudan silme işlemi
        await user.delete();

        if (!mounted) return; // Ekran kapandıysa devam etme
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Hesabınız başarıyla silindi."),
        ));
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Hata: ${e.toString()}"),
        ));
      }
    }

    setState(() => isLoading = false);
  }

  Future<void> reauthenticateAndDeleteUser() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Lütfen e-posta ve şifreyi doldurun."),
      ));
      return;
    }

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Kimlik doğrulama işlemi
        await user.reauthenticateWithCredential(credential);
        await user.delete();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Hesabınız başarıyla silindi."),
        ));
        
        // Kullanıcıyı kaydettikten sonra giriş ekranına yönlendir
        Navigator.pushReplacementNamed(context, "/SignupPage");
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Kimlik doğrulama hatası: ${e.toString()}"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Hesabı Sil",
      style: TextStyle(color: Colors.white,
      fontWeight: FontWeight.bold),
      ),
        centerTitle: true,
        leading: Container(),
        backgroundColor: const Color.fromARGB(255, 41, 55, 73),
      ),
        backgroundColor: const Color.fromARGB(255, 41, 55, 73),
      
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      "Hesabınızı silmek istediğinizden emin misiniz?",
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
    ),
    SizedBox(height: 20),
    Text(
      "E-posta/şifre ile giriş yaptıysanız bilgilerinizi girin.",
      style: TextStyle(color: Colors.white),
    ),
    TextField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: "E-posta",
        labelStyle: TextStyle(color: Colors.white), // Etiket rengini beyaz yap
        hintText: "E-postanızı girin",
        hintStyle: TextStyle(color: Colors.grey), // İpucu metni gri yap
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white), // Normal alt çizgi rengi
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blue), // Odaklandığında alt çizgi mavi
        ),
      ),
      style: TextStyle(color: Colors.white), // Kullanıcının yazdığı metnin rengini beyaz yap
    ),
    TextField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: "Şifre",
        labelStyle: TextStyle(color: Colors.white),
        hintText: "Şifrenizi girin",
        hintStyle: TextStyle(color: Colors.grey),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
      ),
      style: TextStyle(color: Colors.white),
      obscureText: true,
    ),
    SizedBox(height: 20),
    isLoading
        ? Center(child: CircularProgressIndicator())
        : ElevatedButton(
            onPressed: deleteUser,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(vertical: 15),
            ),
            child: Center(
              child: Text(
                "Hesabı Sil",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
  ],
),

      ),
    );
  }
}
