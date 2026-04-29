import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../database/daos/chat_dao.dart';
import '../database/daos/scans_dao.dart';
import '../database/tables/chat_table.dart';
import '../models/chat_message_model.dart';
import '../models/scan_result_model.dart';

enum ScannerStatus { idle, scanning, success, error, limitReached }

class ScannerProvider extends ChangeNotifier {
  final ChatDao _chatDao = ChatDao.instance;
  final ScansDao _scansDao = ScansDao.instance;

  final List<ChatMessage> _messages = [];
  ScannerStatus _status = ScannerStatus.idle;
  String? _error;

  final String _sessionId = DateTime.now().millisecondsSinceEpoch.toString();

  int _sessionMessageCount = 0;
  static const int _maxFollowUps = 3;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  ScannerStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _status == ScannerStatus.scanning;
  bool get isLimitReached => _status == ScannerStatus.limitReached;
  bool get canSendMessage =>
      _status != ScannerStatus.scanning &&
      _status != ScannerStatus.limitReached;

  Future<void> loadLastSession() async {
    try {
      final sessions = await _chatDao.getAllSessions();
      if (sessions.isEmpty) return;

      final lastSessionId = sessions.first[ChatTable.sessionId] as String;
      final rows = await _chatDao.getSessionMessages(lastSessionId);

      for (final row in rows) {
        final contentType = ContentType.values.firstWhere(
          (e) => e.name == row[ChatTable.contentType],
          orElse: () => ContentType.text,
        );
        final messageType = MessageType.values.firstWhere(
          (e) => e.name == row[ChatTable.messageType],
          orElse: () => MessageType.ai,
        );

        if (contentType == ContentType.loading ||
            contentType == ContentType.sessionLimit) {
          continue;
        }

        if (contentType == ContentType.result) {
          final scanId = row[ChatTable.scanId] as int?;
          if (scanId == null) continue;

          final scans = await _scansDao.getAllScans();
          final scanRow = scans.firstWhere(
            (s) => s['id'] == scanId,
            orElse: () => {},
          );

          if (scanRow.isEmpty) continue;

          _messages.add(ChatMessage(
            id: row[ChatTable.id].toString(),
            messageType: messageType,
            contentType: contentType,
            scanResult: ScanResult(
              medicineName: scanRow['medicine_name'] ?? '',
              whatItsFor: scanRow['what_its_for'] ?? '',
              whenToTake: scanRow['when_to_take'] ?? '',
              avoid: scanRow['avoid'] ?? '',
              additionalInfo: scanRow['additional_info'],
              isFromCache: scanRow['from_cache'] == 1,
            ),
            createdAt: DateTime.parse(row[ChatTable.createdAt]),
          ));
          continue;
        }

        _messages.add(ChatMessage(
          id: row[ChatTable.id].toString(),
          messageType: messageType,
          contentType: contentType,
          text: row[ChatTable.text],
          imagePath: row[ChatTable.imagePath],
          createdAt: DateTime.parse(row[ChatTable.createdAt]),
        ));
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Load session error: $e');
    }
  }

  Future<void> scanFromImage(File imageFile, int userCredits) async {
    if (!canSendMessage) return;

    if (userCredits <= 0) {
      _addSessionLimitMessage();
      return;
    }

    final userMsg = ChatMessage.userImage(imageFile.path);
    _addMessage(userMsg);
    await _saveMessage(userMsg);

    _addMessage(ChatMessage.aiLoading());
    _setStatus(ScannerStatus.scanning);

    try {
      final extractedText = await _extractTextFromImage(imageFile);

      if (extractedText.isEmpty) {
        _removeLastMessage();
        final errMsg = ChatMessage.aiText(
          "I couldn't read the text from this image. Please try a clearer photo or type the medicine name.",
        );
        _addMessage(errMsg);
        await _saveMessage(errMsg);
        _setStatus(ScannerStatus.idle);
        return;
      }

      await _callScanFunction(
        extractedText,
        imagePath: imageFile.path,
      );
    } catch (e) {
      _removeLastMessage();
      final errMsg = ChatMessage.aiText(
        'Something went wrong. Please try again.',
      );
      _addMessage(errMsg);
      await _saveMessage(errMsg);
      _setStatus(ScannerStatus.error);
      debugPrint('Scan image error: $e');
    }
  }

  Future<void> scanFromText(
    String medicineName,
    int userCredits,
  ) async {
    if (!canSendMessage || medicineName.trim().isEmpty) return;

    if (userCredits <= 0) {
      _addSessionLimitMessage();
      return;
    }

    final userMsg = ChatMessage.userText(medicineName.trim());
    _addMessage(userMsg);
    await _saveMessage(userMsg);

    _addMessage(ChatMessage.aiLoading());
    _setStatus(ScannerStatus.scanning);

    try {
      await _callScanFunction(medicineName.trim());
    } catch (e) {
      _removeLastMessage();
      final errMsg = ChatMessage.aiText(
        'Something went wrong. Please try again.',
      );
      _addMessage(errMsg);
      await _saveMessage(errMsg);
      _setStatus(ScannerStatus.error);
      debugPrint('Scan text error: $e');
    }
  }

  Future<void> sendFollowUp(
    String question,
    int userCredits,
  ) async {
    if (!canSendMessage || question.trim().isEmpty) return;

    if (_sessionMessageCount >= _maxFollowUps) {
      _addSessionLimitMessage();
      return;
    }

    if (userCredits <= 0) {
      _addSessionLimitMessage();
      return;
    }

    _sessionMessageCount++;

    final userMsg = ChatMessage.userText(question.trim());
    _addMessage(userMsg);
    await _saveMessage(userMsg);

    _addMessage(ChatMessage.aiLoading());
    _setStatus(ScannerStatus.scanning);

    try {
      await _callScanFunction(question.trim());
    } catch (e) {
      _removeLastMessage();
      final errMsg = ChatMessage.aiText(
        'Something went wrong. Please try again.',
      );
      _addMessage(errMsg);
      await _saveMessage(errMsg);
      _setStatus(ScannerStatus.error);
    }
  }

  // ── Private helpers ──────────────────────────────────
  Future<String> _extractTextFromImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer();
    try {
      final recognized = await textRecognizer.processImage(inputImage);
      return recognized.text;
    } finally {
      textRecognizer.close();
    }
  }

  Future<void> _callScanFunction(
    String text, {
    String? imagePath,
  }) async {
    final callable = FirebaseFunctions.instanceFor(
      region: 'asia-south1',
    ).httpsCallable('scanMedicine');

    final result = await callable.call({
      'medicineName': text,
      'inputType': imagePath != null ? 'image' : 'text',
    });

    final data = Map<String, dynamic>.from(result.data);
    _removeLastMessage();

    if (data['success'] == true) {
      final scanResult = ScanResult(
        medicineName: data['medicineName'] ?? text,
        whatItsFor: data['whatItsFor'] ?? '',
        whenToTake: data['whenToTake'] ?? '',
        avoid: data['avoid'] ?? '',
        additionalInfo: data['additionalInfo'],
        isFromCache: data['fromCache'] ?? false,
      );

      // ✅ Save scan to DB
      final scanId = await _scansDao.insertScan(
        result: scanResult,
        imagePath: imagePath,
      );

      final resultMsg = ChatMessage.aiResult(scanResult);
      _addMessage(resultMsg);
      await _saveMessage(resultMsg, scanId: scanId);

      _setStatus(ScannerStatus.success);
    } else {
      final errMsg = ChatMessage.aiText(
        data['message'] ?? 'Something went wrong.',
      );
      _addMessage(errMsg);
      await _saveMessage(errMsg);
      _setStatus(ScannerStatus.error);
    }
  }

  Future<void> _saveMessage(
    ChatMessage message, {
    int? scanId,
  }) async {
    try {
      await _chatDao.insertMessage(
        sessionId: _sessionId,
        message: message,
        scanId: scanId,
      );
    } catch (e) {
      debugPrint('Save message error: $e');
    }
  }

  void _addSessionLimitMessage() {
    final msg = ChatMessage.sessionLimit();
    _addMessage(msg);
    _setStatus(ScannerStatus.limitReached);
  }

  void _addMessage(ChatMessage message) {
    _messages.add(message);
    notifyListeners();
  }

  void _removeLastMessage() {
    if (_messages.isNotEmpty) {
      _messages.removeLast();
      notifyListeners();
    }
  }

  void _setStatus(ScannerStatus status) {
    _status = status;
    notifyListeners();
  }

  void clearChat() {
    _messages.clear();
    _status = ScannerStatus.idle;
    _error = null;
    _sessionMessageCount = 0;
    notifyListeners();
  }
}
