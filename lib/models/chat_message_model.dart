import 'package:cliniq/models/scan_result_model.dart';

enum MessageType { user, ai, system }

enum ContentType { text, image, result, loading, sessionLimit }

class ChatMessage {
  final String id;
  final MessageType messageType;
  final ContentType contentType;
  final String? text;
  final String? imagePath;
  final ScanResult? scanResult;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.messageType,
    required this.contentType,
    this.text,
    this.imagePath,
    this.scanResult,
    required this.createdAt,
  });

  // Factory constructors
  factory ChatMessage.aiText(String text) => ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        messageType: MessageType.ai,
        contentType: ContentType.text,
        text: text,
        createdAt: DateTime.now(),
      );

  factory ChatMessage.userImage(String imagePath) => ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        messageType: MessageType.user,
        contentType: ContentType.image,
        imagePath: imagePath,
        createdAt: DateTime.now(),
      );

  factory ChatMessage.userText(String text) => ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        messageType: MessageType.user,
        contentType: ContentType.text,
        text: text,
        createdAt: DateTime.now(),
      );

  factory ChatMessage.aiLoading() => ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        messageType: MessageType.ai,
        contentType: ContentType.loading,
        createdAt: DateTime.now(),
      );

  factory ChatMessage.aiResult(ScanResult result) => ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        messageType: MessageType.ai,
        contentType: ContentType.result,
        scanResult: result,
        createdAt: DateTime.now(),
      );

  factory ChatMessage.sessionLimit() => ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        messageType: MessageType.system,
        contentType: ContentType.sessionLimit,
        createdAt: DateTime.now(),
      );
}
