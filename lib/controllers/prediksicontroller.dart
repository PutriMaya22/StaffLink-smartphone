import 'package:get/get.dart';
import '../app/data/prediksi.provider.dart';

class PromotionController extends GetxController {
  var predictionResult = Rxn<Map<String, dynamic>>();
  final provider = PromotionProvider();

  void predictPromotion(Map<String, dynamic> inputData) async {
    try {
      final result = await provider.predictPromotion(inputData);
      predictionResult.value = result;
      print('Prediction success: $result');
    } catch (e) {
      print('Error predicting promotion: $e');
    }
  }
}
