import 'package:flutter/material.dart';

class TaskManagerScreen extends StatelessWidget {
  const TaskManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      bottomNavigationBar: BottomNavigationBar(
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
                    'Good Morning\nRajesh Mehta',
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
                  const Text(
                    "Select date",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      DateBox(day: 'MON', date: '4', isSelected: true),
                      DateBox(day: 'Tue', date: '5'),
                      DateBox(day: 'Wed', date: '6'),
                      DateBox(day: 'Thr', date: '7'),
                      DateBox(day: 'Fri', date: '8'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Projects",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: const [
                      ProjectCard(title: 'Personal to-do', status: 'Ongoing'),
                      ProjectCard(title: 'Work to-do', status: 'In Process'),
                      ProjectCard(
                        title: 'High Priority Task',
                        status: 'Go to task',
                      ),
                      ProjectCard(title: 'Personal Things', status: 'On-hold'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Ongoing task",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  OngoingTaskCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DateBox extends StatelessWidget {
  final String day;
  final String date;
  final bool isSelected;

  const DateBox({
    super.key,
    required this.day,
    required this.date,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            day,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
          Text(
            date,
            style: TextStyle(color: isSelected ? Colors.white : Colors.black),
          ),
        ],
      ),
    );
  }
}

class ProjectCard extends StatelessWidget {
  final String title;
  final String status;

  const ProjectCard({super.key, required this.title, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width - 52) / 2,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(status, style: const TextStyle(color: Colors.blue)),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.blue),
            ],
          ),
        ],
      ),
    );
  }
}

class OngoingTaskCard extends StatelessWidget {
  const OngoingTaskCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Candidate Management",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text("For - Zoho Project"),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: 0.88,
                  backgroundColor: Colors.grey[300],
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                "88%",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  // CircleAvatar without image, with color and text
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.blue,
                    child: Text('A', style: TextStyle(color: Colors.white)),
                  ),
                  SizedBox(width: 4),
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.green,
                    child: Text('B', style: TextStyle(color: Colors.white)),
                  ),
                  SizedBox(width: 4),
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.grey,
                    child: Text(
                      '+3',
                      style: TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const Row(
                children: [
                  Icon(Icons.calendar_today, size: 14),
                  SizedBox(width: 4),
                  Text("June 6, 2022"),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
