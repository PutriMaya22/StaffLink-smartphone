import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

class HousekeepingReportForm extends StatefulWidget {
  @override
  _HousekeepingReportFormState createState() => _HousekeepingReportFormState();
}

class _HousekeepingReportFormState extends State<HousekeepingReportForm> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _dateController = TextEditingController();
  final _namaController = TextEditingController();
  final _departemenController = TextEditingController();
  final _jamKerjaController = TextEditingController();

  String? selectedShift;

  final ImagePicker _picker = ImagePicker();

  // Pelayanan dan dokumen
  final List<String?> pelayanan = List<String?>.filled(10, null, growable: false);
  final List<File?> dokumen = List<File?>.filled(10, null, growable: false);
  final List<Uint8List?> dokumenWeb = List<Uint8List?>.filled(10, null, growable: false);

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _pickImage(int index) async {
    if (kIsWeb) {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (result != null && result.files.single.bytes != null) {
        setState(() {
          dokumenWeb[index] = result.files.single.bytes!;
        });
      }
    } else {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          dokumen[index] = File(image.path);
        });
      }
    }
  }

 Future<void> submitReport() async {
  if (!_formKey.currentState!.validate()) return;
  _formKey.currentState!.save();

  final url = Uri.parse('http://localhost:8000/api/report');
  var request = http.MultipartRequest('POST', url);

  request.fields['email'] = _emailController.text;
  request.fields['tanggal'] = _dateController.text;
  request.fields['nama'] = _namaController.text;
  request.fields['departemen'] = _departemenController.text;
  request.fields['shift'] = selectedShift ?? '';
  request.fields['jam_kerja'] = _jamKerjaController.text;

  // Kirim 10 pelayanan sebagai field individual
  for (int i = 0; i < 10; i++) {
    request.fields['pelayanan_${i + 1}'] = pelayanan[i] ?? '';
  }

  // Kirim dokumentasi (nama + file) sebagai field/file individual
  for (int i = 0; i < 10; i++) {
    if (kIsWeb && dokumenWeb[i] != null) {
      final filename = 'web_photo_${i + 1}.jpg';
      request.fields['dokumentasi_${i + 1}'] = filename;
      request.files.add(http.MultipartFile.fromBytes(
        'dokumen_${i + 1}',
        dokumenWeb[i]!,
        filename: filename,
      ));
    } else if (!kIsWeb && dokumen[i] != null) {
      final filename = dokumen[i]!.path.split('/').last;
      request.fields['dokumentasi_${i + 1}'] = filename;
      request.files.add(await http.MultipartFile.fromPath(
        'dokumen_${i + 1}',
        dokumen[i]!.path,
      ));
    } else {
      // Tetap kirim nama kosong jika tidak ada gambar
      request.fields['dokumentasi_${i + 1}'] = '';
    }
  }

  try {
    var response = await request.send();

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Report berhasil dikirim')));
      _resetForm();
    } else {
      String respStr = await response.stream.bytesToString();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $respStr')));
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
  }
}



  void _resetForm() {
    _formKey.currentState?.reset();
    _emailController.clear();
    _dateController.clear();
    _namaController.clear();
    _departemenController.clear();
    _jamKerjaController.clear();

    setState(() {
      selectedShift = null;
      for (int i = 0; i < pelayanan.length; i++) {
        pelayanan[i] = null;
        dokumen[i] = null;
        dokumenWeb[i] = null;
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _dateController.dispose();
    _namaController.dispose();
    _departemenController.dispose();
    _jamKerjaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report Harian House Keeping'),
        backgroundColor: Colors.blue[800],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildTextField(label: "Email", controller: _emailController, keyboardType: TextInputType.emailAddress),
              buildDateField(context),
              buildTextField(label: "Nama", controller: _namaController),
              buildTextField(label: "Departemen", controller: _departemenController),
              buildDropdownField(),
              buildTextField(label: "Jam Kerja", controller: _jamKerjaController),
              SizedBox(height: 20),
              buildPelayananSection(),
              SizedBox(height: 20),
              buildDokumentasiSection(),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  shape: StadiumBorder(),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Center(child: Text('Submit Report', style: TextStyle(fontSize: 18))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required String label,
    TextEditingController? controller,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
        SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator ??
              (value) {
                if (value == null || value.isEmpty) return 'Wajib diisi';
                if (label == "Email" && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Format email tidak valid';
                }
                return null;
              },
          decoration: InputDecoration(
            hintText: 'Masukkan $label',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget buildDateField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Tanggal", style: TextStyle(fontWeight: FontWeight.w600)),
        SizedBox(height: 4),
        TextFormField(
          controller: _dateController,
          readOnly: true,
          onTap: _selectDate,
          validator: (value) => (value == null || value.isEmpty) ? 'Pilih tanggal' : null,
          decoration: InputDecoration(
            hintText: 'Pilih Tanggal',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
            suffixIcon: Icon(Icons.calendar_today),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Shift", style: TextStyle(fontWeight: FontWeight.w600)),
        SizedBox(height: 4),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0))),
          hint: Text('Pilih Shift'),
          value: selectedShift,
          validator: (value) => value == null ? 'Pilih shift' : null,
          onChanged: (value) => setState(() => selectedShift = value),
          items: ['Pagi', 'Siang', 'Malam'].map((shift) => DropdownMenuItem(value: shift, child: Text(shift))).toList(),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget buildPelayananSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("List Pelayanan (10 items)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: 10,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (_, i) {
            return TextFormField(
              decoration: InputDecoration(
                hintText: 'Pelayanan ${i + 1}',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
              ),
              validator: (value) => (value == null || value.isEmpty) ? 'Wajib diisi' : null,
              onSaved: (val) => pelayanan[i] = val,
            );
          },
        ),
      ],
    );
  }

  Widget buildDokumentasiSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Dokumentasi (Upload Foto)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: 10,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (_, i) {
            final imageWidget = kIsWeb && dokumenWeb[i] != null
                ? Image.memory(dokumenWeb[i]!, fit: BoxFit.cover)
                : !kIsWeb && dokumen[i] != null
                    ? Image.file(dokumen[i]!, fit: BoxFit.cover)
                    : Center(child: Text('Upload Foto ${i + 1}', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])));

            return InkWell(
              onTap: () => _pickImage(i),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: Colors.grey),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: imageWidget,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
