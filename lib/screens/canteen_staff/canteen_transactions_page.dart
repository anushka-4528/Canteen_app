import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({Key? key}) : super(key: key);

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  List<DocumentSnapshot> _transactions = [];
  Map<String, double> _dailyTotals = {};
  final Color primaryColor = const Color(0xFF757373);

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('payments')
        .orderBy('timestamp', descending: true)
        .get();

    final transactions = snapshot.docs;
    final dailyTotals = <String, double>{};

    for (var txn in transactions) {
      final timestamp = txn['timestamp'] as Timestamp?;
      final amount = txn['amount'] as num? ?? 0;

      if (timestamp != null) {
        final date = DateFormat('yMMMd').format(timestamp.toDate());
        dailyTotals.update(date, (value) => value + amount.toDouble(),
            ifAbsent: () => amount.toDouble());
      }
    }

    setState(() {
      _transactions = transactions;
      _dailyTotals = dailyTotals;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transactions',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 1,
      ),
      backgroundColor: const Color(0xFFF2F2F2),
      body: _transactions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _dailyTotals.keys.length,
        itemBuilder: (context, index) {
          final date = _dailyTotals.keys.elementAt(index);
          final dailyTotal = _dailyTotals[date] ?? 0;

          final txnsForDate = _transactions.where((txn) {
            final timestamp = txn['timestamp'] as Timestamp?;
            final txnDate = timestamp != null
                ? DateFormat('yMMMd').format(timestamp.toDate())
                : '';
            return txnDate == date;
          }).toList();

          return _buildDailyTransactions(date, dailyTotal, txnsForDate);
        },
      ),
    );
  }

  Widget _buildDailyTransactions(
      String date, double dailyTotal, List<DocumentSnapshot> txns) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Colors.blue.shade50,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.add, // Changed from add_circle_outline
                    color: Colors.blue,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '₹${dailyTotal.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        ...txns.map((txn) {
          final amount = txn['amount'] as num? ?? 0;
          final userId = txn['userId'] ?? 'User';

          return ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(
              userId,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              DateFormat('yMMMd').format(
                (txn['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
              ),
            ),
            trailing: Text(
              '₹${amount.toStringAsFixed(0)}',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          );
        }),
      ],
    );
  }
}
