class ScanResult {
  final String medicineName;
  final String whatItsFor;
  final String whenToTake;
  final String avoid;
  final String? additionalInfo;
  final bool isFromCache;

  const ScanResult({
    required this.medicineName,
    required this.whatItsFor,
    required this.whenToTake,
    required this.avoid,
    this.additionalInfo,
    this.isFromCache = false,
  });

  factory ScanResult.fromMap(Map<String, dynamic> map) {
    return ScanResult(
      medicineName: map['medicineName'] ?? '',
      whatItsFor: map['whatItsFor'] ?? '',
      whenToTake: map['whenToTake'] ?? '',
      avoid: map['avoid'] ?? '',
      additionalInfo: map['additionalInfo'],
      isFromCache: map['isFromCache'] ?? false,
    );
  }
}
