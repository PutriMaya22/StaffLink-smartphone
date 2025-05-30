import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:sp_util/sp_util.dart';

import 'HousekeepingReportForm.dart';
import 'package:stafflink/screens/prediction.dart';
import 'package:stafflink/screens/profile.dart';
import 'package:fl_chart/fl_chart.dart';


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
  currentIndex: _selectedIndex >= 1 ? _selectedIndex + 1 : _selectedIndex,
  onTap: (index) {
    if (index == 1) {
      // Form, buka tanpa ubah tab
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HousekeepingReportForm()),
      );
    } else {
      // Karena Form tidak di _screens, index > 1 perlu dikurangi 1
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
  List<int> absensiPerBulan = List.filled(6, 0); // Default 6 bulan dengan 0 absensi
  String? userName;

  final String baseUrl = 'http://127.0.0.1:8000/api';

  @override
  void initState() {
    super.initState();
    userName = SpUtil.getString("username", defValue: "Putri");
    fetchAbsensiBulanan();
  }

  Future<void> fetchAbsensiBulanan() async {
    setState(() => _isLoading = true);

    final response = await http.get(
      Uri.parse('$baseUrl/absen/bulanan'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List<dynamic> data = jsonData['data']['absensi_per_bulan'];
      setState(() {
        absensiPerBulan = data.map((e) => e as int).toList();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      showMessage('Gagal mengambil data grafik absensi');
    }
  }

  Future<bool> checkAbsen({required String tipe}) async {
    final String userId = SpUtil.getString('user_id') ?? '';
    if (userId.isEmpty) {
      showMessage('User ID tidak ditemukan.');
      return false;
    }

    final tanggal = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final url = Uri.parse('$baseUrl/absen/check?user_id=$userId&tanggal=$tanggal&tipe=$tipe');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['exists'] ?? false;
      } else {
        showMessage('Gagal cek absen: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      showMessage('Error cek absen: $e');
      return false;
    }
  }

  Future<void> handleAbsen(String tipe) async {
    final String userId = SpUtil.getString('user_id') ?? '';
    final String namaUser = SpUtil.getString('username') ?? '';

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
      userId: userId,
      nama: namaUser,
      tipe: tipe,
      keterangan: keterangan,
    );

    if(success) {
      // Refresh grafik absensi jika absen berhasil
      await fetchAbsensiBulanan();
    }

    showMessage(success ? 'Absen $tipe berhasil' : 'Gagal melakukan absen');
    setState(() => _isLoading = false);
  }

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
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
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

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildButton(IconData icon, String label, Color color, String tipe) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: () {
            handleAbsen(tipe);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24, color: Colors.black),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(color: Colors.black, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart() {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

  return SizedBox(
    height: 220,
    child: BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 31, // sesuaikan maxY sesuai jumlah absensi maksimal per bulan
        barGroups: List.generate(12, (index) {
          double yValue = 0;
          if (index < absensiPerBulan.length) {
            yValue = absensiPerBulan[index].toDouble();
          }
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: yValue,
                color: Colors.blue,
                width: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < months.length) {
                  return Text(
                    months[value.toInt()],
                    style: const TextStyle(fontSize: 10),
                  );
                } else {
                  return const Text('');
                }
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10));
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
      ),
    ),
  );
}


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
                  'Hello\n${userName ?? "User"}',
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
                        _buildButton(Icons.login, 'Masuk', const Color(0xFFB9D9F2), 'masuk'),
                        _buildButton(Icons.logout, 'Pulang', const Color(0xFFF7B9B9), 'pulang'),
                        _buildButton(Icons.description, 'Izin', const Color(0xFFB9B9F7), 'izin'),
                        _buildButton(Icons.medical_services, 'Sakit', const Color(0xFFF7B9B9), 'sakit'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Grafik Absensi Perbulan',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _buildBarChart(),
                  ],
                ),
              ),
            ],
          ),
          if (_isLoading)
            const Positioned.fill(
              child: ColoredBox(
                color: Color.fromRGBO(0, 0, 0, 0.25),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}
