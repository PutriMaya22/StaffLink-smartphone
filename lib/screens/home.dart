import 'package:flutter/material.dart';

class WalletScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.insert_chart), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Hi Tino", style: TextStyle(color: Colors.grey[700])),
                      Text("Welcome back", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    child: Icon(Icons.notifications_none, color: Colors.black),
                  )
                ],
              ),
              const SizedBox(height: 20),
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActionButton(Icons.send, Colors.blue),
                  _buildActionButton(Icons.shopping_bag, Colors.orange),
                  _buildActionButton(Icons.wallet, Colors.green),
                  _buildActionButton(Icons.settings, Colors.purple),
                ],
              ),
              const SizedBox(height: 30),
              // Transactions
              Text("Transactions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Today", style: TextStyle(color: Colors.grey)),
                  Icon(Icons.keyboard_arrow_down)
                ],
              ),
              const SizedBox(height: 20),
              _buildTransaction("Collage Free", "4:56 PM", Icons.home, Colors.red),
              _buildTransaction("Alec Koder", "5:20 PM", null, null, avatar: 'https://i.pravatar.cc/150?img=3'),
              _buildTransaction("Tino Well", "7:21 PM", null, null, avatar: 'https://i.pravatar.cc/150?img=5'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color) {
    return CircleAvatar(
      radius: 25,
      backgroundColor: color.withOpacity(0.2),
      child: Icon(icon, color: color),
    );
  }

  Widget _buildTransaction(String name, String time, IconData? icon, Color? iconColor, {String? avatar}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          avatar != null
              ? CircleAvatar(backgroundImage: NetworkImage(avatar))
              : CircleAvatar(backgroundColor: iconColor ?? Colors.grey, child: Icon(icon, color: Colors.white)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
              Text(time, style: TextStyle(color: Colors.grey)),
            ],
          )
        ],
      ),
    );
  }
}
