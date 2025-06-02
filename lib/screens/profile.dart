import 'package:flutter/material.dart';
import 'package:sp_util/sp_util.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login.dart'; // sesuaikan pathnya

// Global ValueNotifier untuk dark mode (ambil dari SpUtil)
ValueNotifier<bool> isDarkMode = ValueNotifier<bool>(SpUtil.getBool('darkMode') ?? false);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = '';
  String? token;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    token = SpUtil.getString('token'); // ambil token dari SpUtil
  }

  void _loadUserName() {
    setState(() {
      userName = SpUtil.getString('username') ?? '';
    });
  }

  // Fungsi hapus akun yang menerima token dan password
  Future<void> _deleteAccount(String token, String password) async {
    final url = Uri.parse('http://127.0.0.1:8000/api/user/delete'); // Ganti dengan endpoint delete akun kamu

    final body = jsonEncode({'password': password});

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Akun berhasil dihapus')),
          );
          // Setelah hapus akun, biasanya logout / ke halaman login
          SpUtil.clear();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        }
      } else {
        String errorMessage = 'Gagal menghapus akun';
        try {
          final data = jsonDecode(response.body);
          if (data is Map && data['message'] != null) {
            errorMessage = data['message'];
          }
        } catch (_) {}

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    }
  }

  // Dialog untuk input password sebelum delete akun
  Future<String?> _showPasswordInputDialog() async {
    String input = '';
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Masukkan Password'),
          content: TextField(
            autofocus: true,
            obscureText: true,
            onChanged: (value) => input = value,
            decoration: const InputDecoration(hintText: 'Password'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(input),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                children: [
                  const CircleAvatar(radius: 45, child: Icon(Icons.person, size: 45)),
                  const SizedBox(height: 12),
                  Text(
                    userName,
                    style: theme.textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _iconAction(
                        Icons.settings,
                        "Settings",
                        onTap: () async {
                          if (token == null || token!.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Token tidak ditemukan, silakan login ulang')),
                            );
                            return;
                          }
                          final updated = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(builder: (_) => EditProfileScreen(token: token!)),
                          );
                          if (updated == true) {
                            _loadUserName(); // refresh username setelah edit profile berhasil
                          }
                        },
                      ),
                      _iconAction(
                        Icons.logout,
                        "Logout",
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Anda ingin keluar?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text("Tidak"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    SpUtil.clear();
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const LoginPage(),
                                      ),
                                    );
                                  },
                                  child: const Text("Ya"),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      _iconAction(
                        Icons.delete_forever,
                        "Delete Akun",
                        onTap: () async {
                          if (token == null || token!.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Token tidak ditemukan, silakan login ulang')),
                            );
                            return;
                          }

                          final password = await _showPasswordInputDialog();
                          if (password != null && password.isNotEmpty) {
                            await _deleteAccount(token!, password);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Password wajib diisi')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildTile(
              Icons.person,
              "Information",
              context,
              onTap: () {
                // Dialog muncul ketika tile Information diklik
                showDialog(
                  context: context,
                  builder: (context) {
                    final name = SpUtil.getString('username') ?? '-';
                    final email = SpUtil.getString('email') ?? '-';
                    final departemen = SpUtil.getString('departemen') ?? '-';
                    return AlertDialog(
                      title: const Text('Information'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nama: $name'),
                          Text('Email: $email'),
                          Text('Departemen: $departemen'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Tutup'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            _buildTile(
              Icons.dark_mode,
              "Dark Mode",
              context,
              trailing: ValueListenableBuilder<bool>(
                valueListenable: isDarkMode,
                builder: (context, value, _) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(value ? Icons.nightlight_round : Icons.wb_sunny),
                      Switch(
                        value: value,
                        onChanged: (newValue) async {
                          isDarkMode.value = newValue;
                          await SpUtil.putBool('darkMode', newValue);
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _iconAction(
    IconData icon,
    String label, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.blue.withOpacity(0.1),
            child: Icon(icon, color: Colors.blue),
          ),
          const SizedBox(height: 6),
          Text(label),
        ],
      ),
    );
  }

  static Widget _buildTile(
    IconData icon,
    String label,
    BuildContext context, {
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(label),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  final String token;

  const EditProfileScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController(text: SpUtil.getString('username') ?? '');
  final TextEditingController emailController = TextEditingController(text: SpUtil.getString('email') ?? '');
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmController = TextEditingController();

  bool isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('http://127.0.0.1:8000/api/user/profile');

    Map<String, String> body = {
      'name': nameController.text.trim(),
      'email': emailController.text.trim(),
    };

    if (passwordController.text.isNotEmpty) {
      body['password'] = passwordController.text;
      body['password_confirmation'] = passwordConfirmController.text;
    }

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        await SpUtil.putString('username', nameController.text.trim());
        await SpUtil.putString('email', emailController.text.trim());

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil berhasil diperbarui')),
          );
          Navigator.pop(context, true);
        }
      } else {
        String errorMessage = 'Gagal memperbarui profil';
        try {
          final data = jsonDecode(response.body);
          if (data is Map && data['message'] != null) {
            errorMessage = data['message'];
          }
        } catch (_) {}

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Email tidak boleh kosong';
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Email tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password Baru'),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordConfirmController,
                decoration: const InputDecoration(labelText: 'Konfirmasi Password Baru'),
                obscureText: true,
                validator: (value) {
                  if (passwordController.text.isNotEmpty && value != passwordController.text) {
                    return 'Konfirmasi password tidak cocok';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

