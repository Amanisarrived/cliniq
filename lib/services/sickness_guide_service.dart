import 'package:cloud_functions/cloud_functions.dart';

class SicknessGuideService {
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    region: 'asia-south1',
  );

  Future<Map<String, dynamic>> getQuestions(String symptoms) async {
    final callable = _functions.httpsCallable('sicknessGuide');
    final result = await callable.call({
      'symptoms': symptoms,
      'mode': 'question',
    });
    return Map<String, dynamic>.from(result.data);
  }

  Future<Map<String, dynamic>> getGuide(
    String symptoms,
    String answers,
  ) async {
    final callable = _functions.httpsCallable('sicknessGuide');
    final result = await callable.call({
      'symptoms': symptoms,
      'answers': answers,
      'mode': 'guide',
    });
    return Map<String, dynamic>.from(result.data);
  }

  Future<Map<String, dynamic>> getFollowUp(
    String symptoms,
    String guide,
    String followUp,
  ) async {
    final callable = _functions.httpsCallable('sicknessGuide');
    final result = await callable.call({
      'symptoms': symptoms,
      'answers': guide,
      'followUp': followUp,
      'mode': 'followup',
    });
    return Map<String, dynamic>.from(result.data);
  }
}
