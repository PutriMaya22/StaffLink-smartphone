import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.pink[100],
              child: Icon(Icons.person, size: 40, color: Colors.black),
            ),
            SizedBox(height: 10),
            Text("Tino Well", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
            Text("FCW–587462", style: TextStyle(color: Colors.grey[700])),
            SizedBox(height: 20),

            // Row of icons
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Icon(Icons.bar_chart, color: Colors.amber[800]),
                  Icon(Icons.notifications, color: Colors.black87),
                  Icon(Icons.settings, color: Colors.black87),
                  Icon(Icons.logout, color: Colors.purple),
                ],
              ),
            ),
            SizedBox(height: 30),

            _buildTile(Icons.person, "Information"),
            _buildTile(Icons.lock, "Security"),
            _buildTile(Icons.mail, "Contact us"),
            _buildTile(Icons.support, "Support"),
            _buildTile(
              Icons.dark_mode,
              "Dark Mode",
              trailing: Switch(value: false, onChanged: (_) {}),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(IconData icon, String label, {Widget? trailing}) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(label, style: TextStyle(color: Colors.black87)),
      trailing: trailing ?? Icon(Icons.arrow_forward_ios, color: Colors.black45, size: 16),
    );
  }
}
