class ExpenseModel {
  final String? id;
  final double amount;
  final String title;
  final DateTime date;
  final DateTime time;

  ExpenseModel({
    this.id,
    required this.amount,
    required this.title,
    required this.date,
    required this.time,
  });

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'title': title,
      'date': date.millisecondsSinceEpoch,
      'time': time.millisecondsSinceEpoch,
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map, String id) {
    return ExpenseModel(
      id: id,
      amount: map['amount']?.toDouble() ?? 0.0,
      title: map['title'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      time: DateTime.fromMillisecondsSinceEpoch(map['time']),
    );
  }
}