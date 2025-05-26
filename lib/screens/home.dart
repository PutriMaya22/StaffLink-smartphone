import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:sp_util/sp_util.dart';

import 'HousekeepingReportForm.dart';
import 'package:stafflink/screens/prediction.dart';
import 'package:stafflink/screens/profile.dart';

class TaskManagerScreen extends StatefulWidget {
  final String token;
  const TaskManagerScreen({super.key, required this.token});

  @override
  State<TaskManagerScreen> createState() => _TaskManagerScreenState();
}

class _TaskManagerScreenState extends State<TaskManagerScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeContent(token: widget.token),
      const PredictionScreen(),
      const ProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      // Perbaiki pemilihan layar sesuai index
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 1) {
            // Navigasi ke form tanpa ubah bottom navigation index
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HousekeepingReportForm()),
            );
          } else {
            _onItemTapped(index > 1 ? index - 1 : index);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Form'),
          BottomNavigationBarItem(icon: Icon(Icons.insights), label: 'Prediksi'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  final String token;
  const HomeContent({super.key, required this.token});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  bool _isLoading = false;
  String namaUser = '';
  String userId = '';
  

  final String baseUrl = 'http://localhost:8000/api';

  @override
  void initState() {
    super.initState();
  }

  /* Future<void> fetchUsers() async {
  setState(() => _isLoading = true);
  try {
    final response = await http.get(Uri.parse('$baseUrl/users/last-login'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      print('Data user dari API: $data');

      if (data.isNotEmpty) {
        // Ambil user pertama, diasumsikan sudah diurut last_login desc dari backend
        final lastLoginUser = data.first;

        // Pastikan cek key 'name' atau 'nama' jika ada
        final nama = lastLoginUser['name'] ?? lastLoginUser['nama'] ?? '';

        setState(() {
          userId = lastLoginUser['id'].toString();
          namaUser = nama.isNotEmpty ? nama : 'User tanpa nama';
        });
      } else {
        showMessage('Tidak ada data user');
      }
    } else {
      showMessage('Gagal mendapatkan data user (${response.statusCode})');
    }
  } catch (e) {
    showMessage('Error saat fetch user: $e');
  }
  setState(() => _isLoading = false);
} */
Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final userId = data['user']['id'].toString();
      final name = data['user']['name'];

      await SpUtil.putString('user_id', userId);
      await SpUtil.putString('username', name);
      return true;
    } else {
      print('Login gagal: ${response.body}');
      return false;
    }
  }

  // Cek apakah user sudah absen tipe tertentu hari ini
  Future<bool> checkAbsen({required String tipe}) async {
  final String userId = SpUtil.getString('user_id') ?? '';
  if (userId.isEmpty) {
    print('User ID tidak ditemukan, gagal cek absen.');
    return false;
  }

  final tanggal = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final url = Uri.parse('$baseUrl/absen/check?user_id=$userId&tanggal=$tanggal&tipe=$tipe');

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Cek absen tipe $tipe: ${data['exists']}');
      return data['exists'] ?? false;
    } else {
      print('Gagal cek absen: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    print('Error cek absen: $e');
    return false;
  }
}

Future<void> handleAbsen(String tipe) async {
  final String userId = SpUtil.getString('user_id') ?? '';
final String namaUser = SpUtil.getString('username') ?? '';

print('Debug userId: $userId');
print('Debug namaUser: $namaUser');

if (userId.isEmpty || namaUser.isEmpty) {
  showMessage('User belum siap, coba lagi nanti');
  return;
}

  setState(() => _isLoading = true);

  if (tipe == 'izin' || tipe == 'sakit') {
    bool sudahAbsenMasuk = await checkAbsen(tipe: 'masuk');
    bool sudahAbsenPulang = await checkAbsen(tipe: 'pulang');

    if (sudahAbsenMasuk && sudahAbsenPulang) {
      setState(() => _isLoading = false);
      showMessage('Tidak bisa absen izin atau sakit setelah absen masuk dan pulang hari ini.');
      return;
    }
  }

  bool sudahAbsen = await checkAbsen(tipe: tipe);
  setState(() => _isLoading = false);

  if (sudahAbsen) {
    showMessage('Anda sudah melakukan absen "$tipe" hari ini');
    return;
  }

  String? keterangan;
  if (tipe == 'izin' || tipe == 'sakit') {
    keterangan = await showDialog<String>(
      context: context,
      builder: (context) {
        String temp = '';
        return AlertDialog(
          title: Text('Masukkan keterangan $tipe'),
          content: TextField(
            onChanged: (value) => temp = value,
            decoration: const InputDecoration(hintText: 'Keterangan'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                if (temp.trim().isEmpty) {
                  showMessage('Keterangan tidak boleh kosong');
                  return;
                }
                Navigator.pop(context, temp.trim());
              },
              child: const Text('Kirim'),
            ),
          ],
        );
      },
    );
    if (keterangan == null) return;
  }

  setState(() => _isLoading = true);

  final success = await postAbsen(
    userId: userId,    // sudah pasti String, bukan nullable
    nama: namaUser,    // sudah pasti String, bukan nullable
    tipe: tipe,
    keterangan: keterangan,
  );

  showMessage(success ? 'Absen $tipe berhasil' : 'Gagal melakukan absen');
  setState(() => _isLoading = false);
}


  // Fungsi untuk post absen ke API
  Future<bool> postAbsen({
    required String userId,
    required String nama,
    required String tipe,
    String? keterangan,
  }) async {
    final url = Uri.parse('$baseUrl/absen');
    final waktuSekarang = DateFormat('HH:mm:ss').format(DateTime.now());

    final body = {
      'user_id': userId,
      'nama': nama,
      'tanggal': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'tipe': tipe,
      if (tipe == 'masuk') 'waktu_masuk': waktuSekarang,
      if (tipe == 'pulang') 'waktu_keluar': waktuSekarang,
      if (tipe == 'izin' || tipe == 'sakit') 'keterangan': keterangan,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print('Gagal absen: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error post absen: $e');
      return false;
    }
  }

  // Fungsi menampilkan snackbar message
  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String? userName = SpUtil.getString("username", defValue: "Putri");

  @override
  Widget build(BuildContext context) {
  return SafeArea(
    child: Stack(
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              color: const Color(0xFF1A73E8),
              width: double.infinity,
              child: Text(
                'Hello\n$userName',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      _buildButton(Icons.login, 'Masuk', const Color(0xFFB9D9F2)),
                      _buildButton(Icons.logout, 'Pulang', const Color(0xFFF7B9B9)),
                      _buildButton(Icons.description, 'Izin', const Color(0xFFB9B9F7)),
                      _buildButton(Icons.medical_services, 'Sakit', const Color(0xFFF7B9B9)),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    ),
  );
}


  Widget _buildButton(IconData icon, String label, Color color) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 1,
          ),
          onPressed: () => handleAbsen(label.toLowerCase()),
          child: Column(
            children: [
              Icon(icon, size: 30, color: Colors.black87),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(color: Colors.black87)),
            ],
          ),
        ),
      ),
    );
  }
}