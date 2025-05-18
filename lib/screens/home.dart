import 'package:flutter/material.dart';
import 'HousekeepingReportForm.dart';

class TaskManagerScreen extends StatelessWidget {
  const TaskManagerScreen({super.key});

  void showAbsenDialog(BuildContext context, String status) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Absen $status'),
            content: Text('Absen $status berhasil!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HousekeepingReportForm()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Form'),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights),
            label: 'Prediksi',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              color: const Color(0xFF1A73E8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Hello\nArta Dariati Wacana S.H.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Icons.menu, color: Colors.white),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5B5FEF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'STAFFLINK',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Jalan JALAN',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: StatusButton(
                            icon: Icons.login,
                            label: 'Masuk',
                            color: Color(0xFFB9D9F2),
                            onPressed:
                                (context) => showAbsenDialog(context, 'Masuk'),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: StatusButton(
                            icon: Icons.logout,
                            label: 'Pulang',
                            color: Color(0xFFF7B9B9),
                            onPressed:
                                (context) => showAbsenDialog(context, 'Pulang'),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: StatusButton(
                            icon: Icons.description,
                            label: 'Izin',
                            color: Color(0xFFB9B9F7),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: StatusButton(
                            icon: Icons.medical_services,
                            label: 'Sakit',
                            color: Color(0xFFF7B9B9),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F3F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'Riwayat',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Status',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // const RiwayatItem(
                        //   name: 'Eva Purwanti',
                        //   date: '2024-06-01',
                        //   imageUrl:
                        //       'https://storage.googleapis.com/a1aa/image/69199c45-e8f7-46cc-3b10-fe772cc42e97.jpg',
                        // ),
                        // const RiwayatItem(
                        //   name: 'Paiman Perkasa Hutapea S.E.',
                        //   date: '2024-05-28',
                        //   imageUrl:
                        //       'https://storage.googleapis.com/a1aa/image/ae3f6f11-ec0b-4b6b-47ff-05ef4b42c26e.jpg',
                        // ),
                        // const RiwayatItem(
                        //   name: 'Diah Andriani',
                        //   date: '2024-05-20',
                        //   imageUrl:
                        //       'https://storage.googleapis.com/a1aa/image/ae3f6f11-ec0b-4b6b-47ff-05ef4b42c26e.jpg',
                        // ),
                        // const RiwayatItem(
                        //   name: 'Kalim Bakti Saputra S.H.',
                        //   date: '2024-05-15',
                        //   imageUrl:
                        //       'https://storage.googleapis.com/a1aa/image/ae3f6f11-ec0b-4b6b-47ff-05ef4b42c26e.jpg',
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatusButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final void Function(BuildContext)? onPressed;

  const StatusButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onPressed?.call(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: Colors.black87),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class RiwayatItem extends StatelessWidget {
  final String name;
  final String date;
  final String imageUrl;

  const RiwayatItem({
    super.key,
    required this.name,
    required this.date,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  imageUrl,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    date,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
