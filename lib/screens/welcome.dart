import 'package:flutter/material.dart';
import 'login.dart'; // Impor halaman login

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "title": "Tetap Terhubung",
      "subtitle": "Berkolaborasi dengan tim, melacak kemajuan, dan tetap diperbarui tentang jadwal kerja Anda.",
      "image": "assets/logo.png", // Bisa diganti dengan gambar yang sesuai
    },
    {
      "title": "Selamat Datang",
      "subtitle": "Siap untuk mengelola tugas dengan lebih efisien dan tetap terorganisir dalam setiap hari kerja.",
      "image": "assets/logo.png", // Bisa diganti dengan gambar yang sesuai
    },
  ];

  void _nextPage() {
    if (_currentPage < onboardingData.length - 1) {
      _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.ease);
    } else {
      // Jika sudah di halaman terakhir, arahkan ke halaman login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background putih
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    itemCount: onboardingData.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (index != 0)
                                IconButton(
                                  icon: Icon(Icons.arrow_back, color: Colors.black),
                                  onPressed: () {
                                    _pageController.previousPage(duration: Duration(milliseconds: 300), curve: Curves.ease);
                                  },
                                )
                              else
                                SizedBox(width: 48), // Padding untuk tombol back
                              TextButton(
                                onPressed: () {
                                  // Skip langsung ke login atau home
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => LoginPage()),
                                  );
                                },
                                child: Text("Skip", style: TextStyle(color: Colors.black)),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Image.asset(
                            onboardingData[index]['image']!,
                            height: 250,
                            width: 250,
                            fit: BoxFit.contain, // Pilih salah satu opsi di bawah
                          ),
                          SizedBox(height: 30),
                          Text(
                            onboardingData[index]['title']!,
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          SizedBox(height: 15),
                          Text(
                            onboardingData[index]['subtitle']!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 80,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(onboardingData.length, (index) => buildDot(index)),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Warna tombol (biru)
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(20),
                ),
                child: Icon(Icons.arrow_forward, color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildDot(int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 5),
      height: 8,
      width: _currentPage == index ? 20 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.blue : Colors.grey,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
