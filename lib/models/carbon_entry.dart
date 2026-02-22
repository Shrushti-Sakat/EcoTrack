class CarbonEntry {
  final int? id;
  final String date;
  final String category;
  final double amount;
  final double carbonValue;

  CarbonEntry({
    this.id,
    required this.date,
    required this.category,
    required this.amount,
    required this.carbonValue,
  });

  // Convert a CarbonEntry into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'category': category,
      'amount': amount,
      'carbonValue': carbonValue,
    };
  }

  // Extract a CarbonEntry object from a Map.
  factory CarbonEntry.fromMap(Map<String, dynamic> map) {
    return CarbonEntry(
      id: map['id'] as int?,
      date: map['date'] as String,
      category: map['category'] as String,
      amount: (map['amount'] as num).toDouble(),
      carbonValue: (map['carbonValue'] as num).toDouble(),
    );
  }

  @override
  String toString() {
    return 'CarbonEntry{id: $id, date: $date, category: $category, amount: $amount, carbonValue: $carbonValue}';
  }
}
