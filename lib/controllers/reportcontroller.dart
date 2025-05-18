import 'package:get/get.dart';
import '../app/data/report_provider.dart';

class ReportController extends GetxController {
  var reports = <dynamic>[].obs;
  final provider = ReportProvider();

  @override
  void onInit() {
    super.onInit();
    fetchReports();
  }

  void fetchReports() async {
    try {
      var data = await provider.getReports();
      reports.assignAll(data);
    } catch (e) {
      print('Error fetching reports: $e');
    }
  }

  void submitReport(Map<String, dynamic> reportData) async {
    try {
      bool success = await provider.sendReport(reportData);
      if (success) {
        print('Report submitted successfully');
        fetchReports(); // refresh list setelah submit
      }
    } catch (e) {
      print('Error submitting report: $e');
    }
  }
}
