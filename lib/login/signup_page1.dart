import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("users");

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthPlaceController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String? _selectedDay;
  String? _selectedMonth;
  String? _selectedYear;
  String? _selectedHour;
  String? _selectedMinute;
  String? _selectedGender;
  String? _selectedMaritalStatus;
  bool _isAgreed = false;
  bool _isLoading = false; // Yükleniyor durumu ekledim

  Future<String> _getAscendant(String birthDate, String birthTime, String city) async {
    try {
      final url = Uri.parse("https://uzeyir.pythonanywhere.com/get-ascendant");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "date": birthDate,
          "time": birthTime,
          "city": city,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['ascendant']; // API'den gelen yükselen burç
      } else {
        throw Exception('Yükselen burç hesaplanırken bir hata oluştu.');
      }
    } catch (e) {
      throw Exception('Bir hata oluştu: $e');
    }
  }

  String getBurc(String day, String month) {
    int dayInt = int.tryParse(day) ?? 0;
    int monthInt = int.tryParse(month) ?? 0;

    if ((monthInt == 3 && dayInt >= 21) || (monthInt == 4 && dayInt <= 19)) {
      return 'Koç';
    } else if ((monthInt == 4 && dayInt >= 20) || (monthInt == 5 && dayInt <= 20)) {
      return 'Boğa';
    } else if ((monthInt == 5 && dayInt >= 21) || (monthInt == 6 && dayInt <= 20)) {
      return 'İkizler';
    } else if ((monthInt == 6 && dayInt >= 21) || (monthInt == 7 && dayInt <= 22)) {
      return 'Yengeç';
    } else if ((monthInt == 7 && dayInt >= 23) || (monthInt == 8 && dayInt <= 22)) {
      return 'Aslan';
    } else if ((monthInt == 8 && dayInt >= 23) || (monthInt == 9 && dayInt <= 22)) {
      return 'Başak';
    } else if ((monthInt == 9 && dayInt >= 23) || (monthInt == 10 && dayInt <= 22)) {
      return 'Terazi';
    } else if ((monthInt == 10 && dayInt >= 23) || (monthInt == 11 && dayInt <= 21)) {
      return 'Akrep';
    } else if ((monthInt == 11 && dayInt >= 22) || (monthInt == 12 && dayInt <= 21)) {
      return 'Yay';
    } else if ((monthInt == 12 && dayInt >= 22) || (monthInt == 1 && dayInt <= 19)) {
      return 'Oğlak';
    } else if ((monthInt == 1 && dayInt >= 20) || (monthInt == 2 && dayInt <= 18)) {
      return 'Kova';
    } else {
      return 'Balık';
    }
  }

  Future<void> _registerUser() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Şifreler eşleşmiyor!")),
      );
      return;
    }
    if (_selectedDay == null || _selectedMonth == null || _selectedYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lütfen doğum tarihinizi giriniz!")),
      );
      return;
    }
    if (_selectedHour == null || _selectedMinute == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lütfen doğum saatinizi giriniz!")),
      );
      return;
    }
    if (_nameController.text.isEmpty ||
        _surnameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _birthPlaceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lütfen tüm alanları doldurunuz!")),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Yükleme durumunu başlatıyoruz
    });

    try {
      // Firebase Authentication ile kullanıcı oluştur
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;
      if (user != null) {
        String birthDate = "${_selectedDay!}.${_selectedMonth!}.${_selectedYear!}";
        String birthTime = "${_selectedHour!}:${_selectedMinute!}";
        String burc = getBurc(_selectedDay!, _selectedMonth!);

        // Kullanıcıyı Realtime Database'e kaydet
        await _dbRef.child(user.uid).set({
          "name": _nameController.text.trim(),
          "surname": _surnameController.text.trim(),
          "phone": _phoneController.text.trim(),
          "email": _emailController.text.trim(),
          "birthDate": birthDate,
          "birthTime": birthTime,
          "birthPlace": _birthPlaceController.text.trim(),
          "gender": _selectedGender,
          "maritalStatus": _selectedMaritalStatus,
          "createdAt": DateTime.now().toIso8601String(),
          "gun": _selectedDay,
          "ay": _selectedMonth,
          "yil": _selectedYear,
          "burc": burc,
          "ascendant": "calculating", // Başlangıçta placeholder
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Kayıt başarılı!')),
        );

        Navigator.pushReplacementNamed(context, '/LoginPage');

        // Ascendant hesaplamasını API çağrısı ile başlat
        _calculateAndUpdateAscendant(user.uid, birthDate, birthTime, _birthPlaceController.text.trim());
      }
    }  catch (e) {
  print(e);

  String errorMessage = "❌ Bilinmeyen hata oluştu."; // Varsayılan hata mesajı

  // Firebase Authentication hataları
  if (e is FirebaseAuthException) {
    switch (e.code) {
      case 'user-not-found':
        errorMessage = "❌ Hata: Kullanıcı bulunamadı!";
        break;
      case 'wrong-password':
        errorMessage = "❌ Hata: Yanlış şifre!";
        break;
      case 'email-already-in-use':
        errorMessage = "❌ Hata: Bu e-posta adresi zaten kullanılıyor!";
        break;
      case 'invalid-email':
        errorMessage = "❌ Hata: Geçersiz e-posta adresi!";
        break;
      default:
        errorMessage = "❌ Firebase Hatası";
    }
  }

  // Firebase Firestore hataları
  else if (e is FirebaseException) {
    switch (e.code) {
      case 'not-found':
        errorMessage = "❌ Hata: Belge bulunamadı!";
        break;
      case 'permission-denied':
        errorMessage = "❌ Hata: Erişim izni yok!";
        break;
      case 'unavailable':
        errorMessage = "❌ Hata: Sunucuya ulaşılamıyor!";
        break;
      default:
        errorMessage = "❌ Firebase Firestore Hatası";
    }
  }

  // Flutter hata türleri
  else if (e is FormatException) {
    errorMessage = "❌ Format Hatası: Geçersiz veri formatı!";
  } else if (e is TimeoutException) {
    errorMessage = "❌ Zaman aşımı: Sunucuya bağlanılamadı!";
  } else {
    errorMessage = "❌ Hata";
  }

  // Hata mesajını ekranda göster
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(errorMessage)),
  );
} finally {
  setState(() {
    _isLoading = false; // Yükleme durumu bitti
  });
}
  }

  Future<void> _calculateAndUpdateAscendant(String userId, String birthDate, String birthTime, String birthPlace) async {
    try {
      String ascendant = await _getAscendant(birthDate, birthTime, birthPlace);
      await _dbRef.child(userId).update({"ascendant": ascendant});
    } catch (e) {
      print("Ascendant hesaplanırken hata oluştu: $e");
    }
  }


@override
Widget build(BuildContext context) {
  return Scaffold(
    resizeToAvoidBottomInset: true,
    body: Stack(
      children: [
        // Arka plan
        Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/background.jpg"), // Arka plan resmi
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Form içeriği
        _isLoading
            ? Center(child: CircularProgressIndicator()) // Yükleme durumu aktifse göster
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Image.asset(
                        "assets/astro4ever_logo.png",
                        width: 100,
                        height: 100
                ),
                const SizedBox(height: 20),

                _buildTextField(
                  controller: _nameController,
                  hintText: "İsim",
                  icon: Icons.person,
                  validator: (value) => value!.isEmpty ? "isim boş bırakılamaz!" : null,
                ),
                _buildTextField(
                  controller: _surnameController,
                  hintText: "Soyisim",
                  icon: Icons.person,
                ),
                _buildPhoneNumberField(),
                _buildEmailField(),
                Text("Doğum Günü", style: TextStyle(color: Colors.white)),
                // Doğum Tarihi
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdownButton(
                        hintText: "Gün",
                        value: _selectedDay,
                        items: List.generate(31, (index) => (index + 1).toString()),
                        onChanged: (value) {
                          setState(() {
                            _selectedDay = value;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: _buildDropdownButton(
                        hintText: "Ay",
                        value: _selectedMonth,
                        items: List.generate(12, (index) => (index + 1).toString()),
                        onChanged: (value) {
                          setState(() {
                            _selectedMonth = value;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: _buildDropdownButton(
                        hintText: "Yıl",
                        value: _selectedYear,
                        items: List.generate(
                          DateTime.now().year - 1900 + 1,
                          (index) => (DateTime.now().year - index).toString(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _selectedYear = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                Text("Doğum Saati", style: TextStyle(color: Colors.white)),

                // Doğum Saati
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdownButton(
                        hintText: "Saat",
                        value: _selectedHour,
                        items: List.generate(24, (index) => index.toString().padLeft(2, '0')),
                        onChanged: (value) {
                          setState(() {
                            _selectedHour = value;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: _buildDropdownButton(
                        hintText: "Dakika",
                        value: _selectedMinute,
                        items: List.generate(60, (index) => index.toString().padLeft(2, '0')),
                        onChanged: (value) {
                          setState(() {
                            _selectedMinute = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                _buildTextField(
                  controller: _birthPlaceController,
                  hintText: "Doğduğunuz Şehir",
                  icon: Icons.location_on,
                ),

                // Cinsiyet
                _buildDropdownButton(
                  hintText: "Cinsiyet",
                  value: _selectedGender,
                  items: ['Erkek', 'Kadın','Belirtmek İstemiyorum'],
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                ),

                // Medeni Durum
                _buildDropdownButton(
                  hintText: "Medeni Durum",
                  value: _selectedMaritalStatus,
                  items: ['Evli', 'Bekar','Belirtmek İstemiyorum'],
                  onChanged: (value) {
                    setState(() {
                      _selectedMaritalStatus = value;
                    });
                  },
                ),

                _buildTextField(
                  controller: _passwordController,
                  hintText: "Şifre",
                  icon: Icons.lock,
                  obscureText: true,
                ),
                _buildTextField(
                  controller: _confirmPasswordController,
                  hintText: "Şifre Doğrula",
                  icon: Icons.lock,
                  obscureText: true,
                ),

                const SizedBox(height: 20),

                            
                Row(
                  children: [
                    Checkbox(
                      value: _isAgreed, // Onay kutusunun durumu
                      onChanged: (bool? value) {
                        setState(() {
                          _isAgreed = value!; // Durumu güncelle
                        });
                      },
                    ),
                    Flexible(
                      child: Text.rich(
                        TextSpan(
                          text: '', // Başlangıçta boş bir metin
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Kullanıcı sözleşmesini', 
                              style: TextStyle(color: Colors.white, 
                              fontWeight: FontWeight.bold, 
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white, // Alt çizginin rengini beyaz yaptık
                                  ),
                              recognizer: TapGestureRecognizer()..onTap = () {
                                Navigator.pushNamed(context, '/privacy_policy');
                              },
                            ),
                            TextSpan(
                              text: ' okudum ve kabul ediyorum', 
                              style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Kayıt Ol butonu
                ElevatedButton(
                  onPressed: _isAgreed
                      ? _registerUser
                      : null, // Onay verilmediyse buton pasif olur
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    backgroundColor: Colors.lightBlueAccent,
                    shadowColor: Colors.blueGrey,
                    elevation: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.person_add, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        "Kayıt Ol",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      "Zaten hesabın var mı?",
                      style: TextStyle(color: Colors.white),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/LoginPage'),
                      child: const Text(
                        "Giriş Yap",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildDropdownButton({
  required String hintText,
  required String? value,
  required List<String> items,
  required Function(String?) onChanged,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 15), // Dropdown butonları arasına aralık ekledik
    child: DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      items: items
          .map((item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: TextStyle(color: Colors.white), // Dropdown item'ları için yazı rengi
                ),
              ))
          .toList(),
      decoration: InputDecoration(
        labelText: hintText,
        labelStyle: TextStyle(color: Colors.white), // Label yazı rengi beyaz
        hintStyle: TextStyle(color: Colors.white), // Hint text rengi beyaz
        fillColor: Colors.blueGrey, // Fill color ekledik
        filled: true, // Fill özelliğini aktif ettik
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blueGrey), // Border rengini ekledik
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blueGrey), // Focused border rengi
        ),
      ),
      dropdownColor: Colors.blueGrey[700], // Dropdown menüsünün arka plan rengi
    ),
  );
}



Widget _buildPhoneNumberField() {
  return Padding(
    padding: const EdgeInsets.only(bottom: 15), // Text field'lar arasında aralık ekledik
    child: TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        LengthLimitingTextInputFormatter(10), // Maksimum 10 hane sınırlaması
      ],
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.phone, color: Colors.white), // İkon rengi düzenlendi
        labelText: "Telefon Numarası",
        labelStyle: TextStyle(color: Colors.white), // Label text rengi
        hintStyle: TextStyle(color: Colors.white), // Hint text rengini beyaz yaptık
        fillColor: Colors.blueGrey, // Fill color ekledik
        filled: true, // Fill özelliğini aktif ettik
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      style: TextStyle(color: Colors.white),
    ),
  );
}

Widget _buildTextField({
  required TextEditingController controller,
  required String hintText,
  required IconData icon,
  bool obscureText = false,
  TextInputType? keyboardType,
  FormFieldValidator<String>? validator,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 15), // Text field'lar arasında aralık ekledik
    child: TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white), // İkon rengi düzenlendi
        labelText: hintText,
        labelStyle: TextStyle(color: Colors.white), // Label text rengi
        hintStyle: TextStyle(color: Colors.white), // Hint text rengini beyaz yaptık
        fillColor: Colors.blueGrey, // Fill color ekledik
        filled: true, // Fill özelliğini aktif ettik
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      style: TextStyle(color: Colors.white),
    ),
  );
}

Widget _buildEmailField() {
  return _buildTextField(
    controller: _emailController,
    hintText: "Email",
    icon: Icons.email,
    keyboardType: TextInputType.emailAddress,
  );
}
}