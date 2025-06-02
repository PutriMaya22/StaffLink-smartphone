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

  // Dropdown fields
  int? department;
  int? education;
  int? gender;
  int? recruitmentChannel;
  int? awardsWon;
  int? kpisMet;

  // Text controllers
  final ageController = TextEditingController();
  final lengthOfServiceController = TextEditingController();
  final previousRatingController = TextEditingController();
  final noOfTrainingsController = TextEditingController();
  final avgTrainingScoreController = TextEditingController();

  bool _isLoading = false;
  String? _result;

  // Dropdown options
  final List<Map<String, dynamic>> departmentList = [
    {'id': 1, 'label': 'Sales & Marketing'},
    {'id': 2, 'label': 'Operations'},
    {'id': 3, 'label': 'Technology'},
    {'id': 4, 'label': 'Analytics'},
    {'id': 5, 'label': 'R&D'},
    {'id': 6, 'label': 'Procurement'},
    {'id': 7, 'label': 'Finance'},
    {'id': 8, 'label': 'HR'},
    {'id': 9, 'label': 'Legal'},
  ];

  final List<Map<String, dynamic>> educationList = [
    {'id': 1, 'label': 'Below Secondary'},
    {'id': 2, 'label': "Bachelor's"},
    {'id': 3, 'label': "Master's & above"},
  ];

  final List<Map<String, dynamic>> genderList = [
    {'id': 1, 'label': 'Laki-laki'},
    {'id': 2, 'label': 'Perempuan'},
  ];

  final List<Map<String, dynamic>> recruitmentChannelList = [
    {'id': 1, 'label': 'Lainnya'},
    {'id': 2, 'label': 'Referral'},
    {'id': 3, 'label': 'Sourcing'},
  ];

  final List<Map<String, dynamic>> yaTidakList = [
    {'id': 1, 'label': 'Ya'},
    {'id': 0, 'label': 'Tidak'},
  ];

  @override
  void dispose() {
    ageController.dispose();
    lengthOfServiceController.dispose();
    previousRatingController.dispose();
    noOfTrainingsController.dispose();
    avgTrainingScoreController.dispose();
    super.dispose();
  }

  Future<void> _submitPrediction() async {
    if (!_formKey.currentState!.validate()) return;

    if ([department, education, gender, recruitmentChannel, kpisMet, awardsWon].contains(null)) {
      setState(() => _result = "Mohon lengkapi semua data dropdown.");
      return;
    }

    setState(() {
      _isLoading = true;
      _result = null;
    });

    final body = {
      "department": department,
      "education": education,
      "gender": gender,
      "recruitment_channel": recruitmentChannel,
      "no_of_trainings": int.tryParse(noOfTrainingsController.text) ?? 0,
      "age": int.tryParse(ageController.text) ?? 0,
      "previous_year_rating": int.tryParse(previousRatingController.text) ?? 0,
      "length_of_service": int.tryParse(lengthOfServiceController.text) ?? 0,
      "kpis_met": kpisMet,
      "awards_won": awardsWon,
      "avg_training_score": double.tryParse(avgTrainingScoreController.text) ?? 0.0,
    };

  try {
  final response = await http.post(
    Uri.parse('http://localhost:8000/api/predict'),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(body),
  );

  if (response.statusCode == 200) {
    final responseData = jsonDecode(response.body);
final innerData = responseData['data'] ?? {}; // Ambil isi dari key 'data'

final prediction = responseData['prediction'].toString().toLowerCase().trim();

print("Prediction result: $prediction");
print("DATA DARI BACKEND: $innerData");

final departmentMap = {
  1: 'Sales & Marketing',
  2: 'Operations',
  3: 'Technology',
  4: 'Analytics',
  5: 'R&D',
  6: 'Procurement',
  7: 'Finance',
  8: 'HR',
  9: 'Legal',
};

final departmentId = int.tryParse(innerData['department'].toString()) ?? 0;
final department = departmentMap[departmentId] ?? '-';

final educationMap = {
  1: 'Below Secondary',
  2: "Bachelor's",
  3: "Master's & above",
};

final educationId = int.tryParse(innerData['education']?.toString() ?? '0') ?? 0;
final education = educationMap[educationId] ?? '-';

final rating = innerData['previous_year_rating']?.toString() ?? '';
final skorPelatihan = innerData['avg_training_score']?.toString() ?? '';
final kpisMet = innerData['KPIs_met >80%']; // Perbaikan nama key
final penghargaanWon = innerData['awards_won?']; // Perbaikan nama key

// Perbaikan logika untuk menampilkan 'Ya'/'Tidak' berdasarkan nilai boolean atau integer 1/0
final kpisLolos = (kpisMet == 1 || kpisMet == true);
final penghargaanLolos = (penghargaanWon == 1 || penghargaanWon == true);

final kpis = kpisLolos ? 'Ya' : 'Tidak';
final penghargaan = penghargaanLolos ? 'Ya' : 'Tidak';

final hasilPrediksi = prediction == 'promoted';
final hasil = hasilPrediksi ? 'Promoted' : 'Not Promoted';
final statusPromosiKpi = kpisLolos ? 'Ya' : 'Tidak';
final statusPenghargaan = penghargaanLolos ? 'Ya' : 'Tidak';

setState(() {
  _result = '''
        $hasil
Detail Input:
Departemen: $department
Pendidikan: $education
Rating Tahun Lalu: $rating
Skor Pelatihan: $skorPelatihan
KPIs >80%: ${statusPromosiKpi}
Penghargaan: ${statusPenghargaan}
''';
});

  } else {
    setState(() {
      _result = "Gagal memproses prediksi.";
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

  Widget _buildDropdownField({
    required String label,
    required int? value,
    required List<Map<String, dynamic>> items,
    required void Function(int?) onChanged,
    required IconData icon,
  }) {
    return DropdownButtonFormField<int>(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      value: value,
      isExpanded: true,
      items: items.map((item) => DropdownMenuItem<int>(
        value: item['id'],
        child: Text(item['label']),
      )).toList(),
      onChanged: onChanged,
      validator: (val) => val == null ? 'Harap pilih $label' : null,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required TextInputType keyboardType,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: validator,
    );
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildDropdownField(
                        label: 'Departemen',
                        value: department,
                        items: departmentList,
                        onChanged: (val) => setState(() => department = val),
                        icon: Icons.business_center_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: noOfTrainingsController,
                        label: 'Jumlah Pelatihan',
                        keyboardType: TextInputType.number,
                        icon: Icons.format_list_numbered,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Harap isi Jumlah Pelatihan';
                          if (int.tryParse(value) == null) return 'Jumlah Pelatihan harus berupa angka';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownField(
                        label: 'Pendidikan',
                        value: education,
                        items: educationList,
                        onChanged: (val) => setState(() => education = val),
                        icon: Icons.school_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: ageController,
                        label: 'Usia',
                        keyboardType: TextInputType.number,
                        icon: Icons.cake_outlined,
                        validator: (value) {
                          final n = int.tryParse(value ?? '');
                          if (value == null || value.isEmpty) return 'Harap isi Usia';
                          if (n == null) return 'Usia harus berupa angka';
                          if (n < 18 || n > 60) return 'Usia harus antara 18 sampai 60';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownField(
                        label: 'Jenis Kelamin',
                        value: gender,
                        items: genderList,
                        onChanged: (val) => setState(() => gender = val),
                        icon: Icons.wc_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: previousRatingController,
                        label: 'Rating Tahun Lalu (1-5)',
                        keyboardType: TextInputType.number,
                        icon: Icons.star_rate_outlined,
                        validator: (value) {
                          final n = int.tryParse(value ?? '');
                          if (value == null || value.isEmpty) return 'Harap isi Rating';
                          if (n == null || n < 1 || n > 5) return 'Rating harus antara 1 sampai 5';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownField(
                        label: 'Channel Rekrutmen',
                        value: recruitmentChannel,
                        items: recruitmentChannelList,
                        onChanged: (val) => setState(() => recruitmentChannel = val),
                        icon: Icons.how_to_reg_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: lengthOfServiceController,
                        label: 'Masa Kerja (tahun)',
                        keyboardType: TextInputType.number,
                        icon: Icons.timer_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Harap isi Masa Kerja';
                          if (int.tryParse(value) == null) return 'Masa Kerja harus berupa angka';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownField(
                        label: 'Memenangkan Penghargaan',
                        value: awardsWon,
                        items: yaTidakList,
                        onChanged: (val) => setState(() => awardsWon = val),
                        icon: Icons.emoji_events_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: avgTrainingScoreController,
                        label: 'Rata-rata Skor Pelatihan',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        icon: Icons.score_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Harap isi Rata-rata Skor Pelatihan';
                          if (double.tryParse(value) == null) return 'Skor harus berupa angka';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownField(
                        label: 'KPI di atas 80%',
                        value: kpisMet,
                        items: yaTidakList,
                        onChanged: (val) => setState(() => kpisMet = val),
                        icon: Icons.insights_outlined,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _submitPrediction,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Submit'),
                      ),
                      if (_result != null) ...[
                        const SizedBox(height: 24),
                        Text('Hasil Prediksi:', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text(
                          _result!,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.blueAccent),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
