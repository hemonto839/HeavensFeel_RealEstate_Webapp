class Payment {
  final String pid;
  final String userId;
  final String propertyId;

  // date
  final DateTime paymentDate;

  // banking info
  final String paymentOption;
  final String cardNo;

  // Constructor
  Payment({
    required this.pid,
    required this.userId,
    required this.propertyId,
    required this.paymentDate,
    required this.paymentOption,
    required this.cardNo,
  });

  // Map to Database
  Map<String, dynamic> toMap() {
    return {
      'pid': pid,
      'userId': userId,
      'propertyId': propertyId,
      'paymentDate': paymentDate.millisecondsSinceEpoch,
      'paymentOption': paymentOption,
      'cardNo': cardNo,
    };
  }

  // Map from Database
  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      pid: map['pid'] ?? '',
      userId: map['userId'] ?? '',
      propertyId: map['propertyId'] ?? '',
      paymentDate: DateTime.fromMillisecondsSinceEpoch(map['paymentDate']),
      paymentOption: map['paymentOption'] ?? '',
      cardNo: map['cardNo'] ?? '',
    );
  }
}
