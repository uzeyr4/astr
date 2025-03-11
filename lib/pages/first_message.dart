import 'package:flutter/material.dart';

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            // Arka plan
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/background.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Yarı saydam kart ve metin
            Align(
              alignment: Alignment.center,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blueGrey,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Sevgili ....,",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Astro4ever'a Hoşgeldin\n"
                      "Bu uygulama asla bir fal platformu değildir. Gökyüzünde neler oluyor? Sana farkındalıklar sağlamak için burdayım. Sadece dolunaylar, yeni aylar değil, gökyüzündeki bütün etkileşimleri almaya hazır mısın? Yorumlar Yapay zeka olmadan sadece gerçek astrologlar tarafından gönderilecektir. O yüzden yazım hataları aramızda😉\n"
                      "Gökyüzüne Hakim Ol!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Sağ alt buton
            Positioned(
              bottom: 24,
              right: 24,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/LoginPage');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent, // Buton rengi
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Geç',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
