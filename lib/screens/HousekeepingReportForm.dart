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
  _HousekeepingReportForm createState() => _HousekeepingReportForm();
}

class _HousekeepingReportForm extends State<HousekeepingReportForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _jamKerjaController = TextEditingController();
  final TextEditingController _pelayananController = TextEditingController();

  String? selectedDepartemen;
  String? selectedShift;
  final List<Uint8List?> dokumenWeb = List.filled(5, null);

  final List<String> departemenList = [
    "Sales & Marketing",
    "Operations",
    "Technology",
    "Analytics",
    "R&D",
    "Procurement",
    "Finance",
    "HR",
    "Legal",
  ];

  final Map<String, String> shiftToJam = {
    "Pagi": "08:00 - 16:00",
    "Siang": "16:00 - 00:00",
    "Malam": "00:00 - 08:00",
  };

  void _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  void _pickImage(int index) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        dokumenWeb[index] = result.files.single.bytes!;
      });
    }
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    bool allPhotosFilled = dokumenWeb.every((img) => img != null);
    if (!allPhotosFilled) {
      _showMessage('Semua foto dokumentasi wajib diisi');
      return;
    }

    _showMessage('Submit Berhasil');
    _formKey.currentState!.reset();
    _dateController.clear();
    _jamKerjaController.clear();
    _pelayananController.clear();
    setState(() {
      selectedDepartemen = null;
      selectedShift = null;
      for (int i = 0; i < dokumenWeb.length; i++) {
        dokumenWeb[i] = null;
      }
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.blue.shade600,
        content: Text(message, style: TextStyle(color: Colors.white)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('REPORT HARIAN HOUSE KEEPING'),
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTextField(
                "Email",
                _emailController,
                TextInputType.emailAddress,
              ),
              buildDateField(),
              buildTextField("Nama", _namaController, TextInputType.text),
              buildDropdownField(
                "Departemen",
                departemenList,
                selectedDepartemen,
                (val) {
                  setState(() => selectedDepartemen = val);
                },
              ),
              buildDropdownField(
                "Shift",
                shiftToJam.keys.toList(),
                selectedShift,
                (val) {
                  setState(() {
                    selectedShift = val;
                    _jamKerjaController.text =
                        val != null ? shiftToJam[val]! : '';
                  });
                },
              ),
              buildTextField(
                "Jam Kerja",
                _jamKerjaController,
                TextInputType.text,
                enabled: false,
              ),

              // PELAYANAN
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Pelayanan",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 6),
                    TextFormField(
                      controller: _pelayananController,
                      keyboardType: TextInputType.multiline,
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Wajib diisi';
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "Deskripsikan pelayanan hari ini",
                        filled: true,
                        fillColor: Colors.blue.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // UPLOAD FOTO
              Text(
                "Dokumentasi (upload minimal 5 foto)",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 6),
              Text(
                "Upload minimal 5 foto dokumentasi",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
              SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                itemCount: 5,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemBuilder: (_, i) {
                  return InkWell(
                    onTap: () => _pickImage(i),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue.shade300),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.blue.shade50,
                      ),
                      child:
                          dokumenWeb[i] != null
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  dokumenWeb[i]!,
                                  fit: BoxFit.cover,
                                ),
                              )
                              : Center(
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 40,
                                  color: Colors.blue.shade300,
                                ),
                              ),
                    ),
                  );
                },
              ),

              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  shape: StadiumBorder(),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Center(
                  child: Text('Kirim Laporan', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
    String label,
    TextEditingController controller,
    TextInputType keyboardType, {
    int maxLines = 1,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
          ),
          SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            enabled: enabled,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Wajib diisi';
              if (label == "Email" &&
                  !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                return 'Format email tidak valid';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: 'Masukkan $label',
              fillColor: Colors.blue.shade50,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Tanggal",
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
          ),
          SizedBox(height: 6),
          GestureDetector(
            onTap: _selectDate,
            child: AbsorbPointer(
              child: TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  hintText: 'Pilih Tanggal',
                  suffixIcon: Icon(Icons.calendar_today),
                  fillColor: Colors.blue.shade50,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDropdownField(
    String label,
    List<String> items,
    String? selected,
    void Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
          ),
          SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: selected,
            onChanged: onChanged,
            validator: (value) => value == null ? 'Wajib dipilih' : null,
            items:
                items
                    .map(
                      (val) => DropdownMenuItem(value: val, child: Text(val)),
                    )
                    .toList(),
            decoration: InputDecoration(
              fillColor: Colors.blue.shade50,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
