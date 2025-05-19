import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final _formKey = GlobalKey<FormState>();

  String? departemen;
  String? pendidikan;
  String? jenisKelamin;
  String? channelRekrutmen;
  String? memenangkanPenghargaan;
  String? kpisAbove80;

  final usiaController = TextEditingController();
  final masaKerjaController = TextEditingController();
  final ratingController = TextEditingController();
  final jumlahPelatihanController = TextEditingController();
  final rataRataSkorPelatihanController = TextEditingController();

  final List<String> departemenList = [
    'Sales & Marketing',
    'Operations',
    'Technology',
    'Analytics',
    'R&D',
    'Procurement',
    'Finance',
    'HR',
    'Legal',
  ];

  final List<String> pendidikanList = [
    "Below Secondary",
    "Bachelor's",
    "Master's & above",
  ];

  final List<String> jenisKelaminList = ["Laki-laki", "Perempuan"];

  final List<String> channelRekrutmenList = [
    "Lainnya"
        "Referral",
    "Sourcing",
  ];

  final List<String> yaTidakList = ['Ya', 'Tidak'];

  bool _isLoading = false;
  String? _result;

  Future<void> _submitPrediction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _result = null;
    });

    final body = {
      "departemen": departemen,
      "pendidikan": pendidikan,
      "jenis_kelamin": jenisKelamin,
      "channel_rekrutmen": channelRekrutmen,
      "usia": int.tryParse(usiaController.text) ?? 0,
      "masa_kerja": int.tryParse(masaKerjaController.text) ?? 0,
      "rating": double.tryParse(ratingController.text) ?? 0.0,
      "jumlah_pelatihan": int.tryParse(jumlahPelatihanController.text) ?? 0,
      "memenangkan_penghargaan": memenangkanPenghargaan == 'Ya' ? 1 : 0,
      "rata_rata_skor_pelatihan":
          double.tryParse(rataRataSkorPelatihanController.text) ?? 0.0,
      "kpis_above_80": kpisAbove80 == 'Ya' ? 1 : 0,
    };

    try {
      final response = await http.post(
        Uri.parse('https://example.com/api/predict'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _result = data['prediction'] ?? "Tidak ada hasil prediksi";
        });
      } else {
        setState(() {
          _result = "Error saat memproses prediksi";
        });
      }
    } catch (e) {
      setState(() {
        _result = "Terjadi kesalahan: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    usiaController.dispose();
    masaKerjaController.dispose();
    ratingController.dispose();
    jumlahPelatihanController.dispose();
    rataRataSkorPelatihanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.blue.shade700;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prediksi Promosi'),
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 4,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildDropdownField(
                        label: 'Departemen',
                        value: departemen,
                        items: departemenList,
                        onChanged: (val) => setState(() => departemen = val),
                        icon: Icons.business_center_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: jumlahPelatihanController,
                        label: 'Jumlah Pelatihan',
                        keyboardType: TextInputType.number,
                        icon: Icons.format_list_numbered,
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownField(
                        label: 'Pendidikan',
                        value: pendidikan,
                        items: pendidikanList,
                        onChanged: (val) => setState(() => pendidikan = val),
                        icon: Icons.school_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: usiaController,
                        label: 'Usia',
                        keyboardType: TextInputType.number,
                        icon: Icons.cake_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownField(
                        label: 'Jenis Kelamin',
                        value: jenisKelamin,
                        items: jenisKelaminList,
                        onChanged: (val) => setState(() => jenisKelamin = val),
                        icon: Icons.wc_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: ratingController,
                        label: 'Rating Tahun Lalu (1-5)',
                        keyboardType: TextInputType.number,
                        icon: Icons.star_rate_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownField(
                        label: 'Channel Rekrutmen',
                        value: channelRekrutmen,
                        items: channelRekrutmenList,
                        onChanged:
                            (val) => setState(() => channelRekrutmen = val),
                        icon: Icons.how_to_reg_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: masaKerjaController,
                        label: 'Masa Kerja (tahun)',
                        keyboardType: TextInputType.number,
                        icon: Icons.timer_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownField(
                        label: 'Memenangkan Penghargaan?',
                        value: memenangkanPenghargaan,
                        items: yaTidakList,
                        onChanged:
                            (val) =>
                                setState(() => memenangkanPenghargaan = val),
                        icon: Icons.emoji_events_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: rataRataSkorPelatihanController,
                        label: 'Rata-rata Skor Pelatihan',
                        keyboardType: TextInputType.number,
                        icon: Icons.score_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownField(
                        label: 'KPIs >80%?',
                        value: kpisAbove80,
                        items: yaTidakList,
                        onChanged: (val) => setState(() => kpisAbove80 = val),
                        icon: Icons.assessment_outlined,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 6,
                  shadowColor: primaryColor.withOpacity(0.6),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                onPressed: _isLoading ? null : _submitPrediction,
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Prediksi Promosi'),
              ),
              if (_result != null) ...[
                const SizedBox(height: 30),
                Card(
                  color: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _result!,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    IconData? icon,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          onChanged: onChanged,
          items:
              items
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
          hint: Text('Pilih $label'),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    IconData? icon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Field $label tidak boleh kosong';
        }
        return null;
      },
    );
  }
}
