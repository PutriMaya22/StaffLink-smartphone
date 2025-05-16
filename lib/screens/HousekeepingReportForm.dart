import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class HousekeepingReportForm extends StatefulWidget {
  @override
  _HousekeepingReportFormState createState() => _HousekeepingReportFormState();
}

class _HousekeepingReportFormState extends State<HousekeepingReportForm> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String? selectedShift;
  final List<String?> pelayanan = List.filled(10, '');
  final List<File?> dokumen = List.filled(10, null);

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
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        dokumen[index] = File(image.path);
      });
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
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
              buildTextField(
                label: "Email",
                keyboardType: TextInputType.emailAddress,
              ),
              buildDateField(context),
              buildTextField(label: "Nama"),
              buildTextField(label: "Divisi"),
              buildDropdownField(),
              buildTextField(label: "Jam Kerja"),

              SizedBox(height: 20),
              buildPelayananSection(),
              SizedBox(height: 20),
              buildDokumentasiSection(),

              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save(); // simpan data pelayanan
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Form submitted')));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  shape: StadiumBorder(),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Center(
                  child: Text('Submit Report', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField({required String label, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
        SizedBox(height: 4),
        TextFormField(
          keyboardType: keyboardType,
          validator:
              (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
          decoration: InputDecoration(
            hintText: 'Masukkan $label',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
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
          validator:
              (value) =>
                  value == null || value.isEmpty ? 'Pilih tanggal' : null,
          decoration: InputDecoration(
            hintText: 'Pilih Tanggal',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
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
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          hint: Text('Pilih Shift'),
          value: selectedShift,
          validator: (value) => value == null ? 'Pilih shift' : null,
          onChanged: (value) {
            setState(() {
              selectedShift = value;
            });
          },
          items:
              ['Pagi', 'Siang', 'Malam']
                  .map(
                    (shift) =>
                        DropdownMenuItem(value: shift, child: Text(shift)),
                  )
                  .toList(),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget buildPelayananSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "List Pelayanan (10 items)",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              onSaved: (val) => pelayanan[i] = val ?? '',
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
        Text(
          "Dokumentasi Pelayanan (Upload 10 dokumen)",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: 10,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3.5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (_, i) {
            final file = dokumen[i];
            return ElevatedButton(
              onPressed: () => _pickImage(i),
              style: ElevatedButton.styleFrom(
                backgroundColor: file != null ? Colors.green : Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 10),
              ),
              child:
                  file != null
                      ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'File ${i + 1} selected',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(Icons.check_circle, color: Colors.white),
                        ],
                      )
                      : Text('Upload ${i + 1}'),
            );
          },
        ),
      ],
    );
  }
}
