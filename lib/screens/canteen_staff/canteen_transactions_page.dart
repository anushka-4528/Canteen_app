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
  Map<String, int> _dailyTotals = {};
  final Color primaryColor = const Color(0xFF757373);

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .orderBy('timestamp', descending: true)
        .get();

    final transactions = snapshot.docs;

    // Calculate daily totals
    final dailyTotals = <String, int>{};

    for (var txn in transactions) {
      final timestamp = txn['timestamp'] as Timestamp?;
      final amountPaisa = txn['amount'] as int? ?? 0;
      final amountRupees = amountPaisa ~/ 100; // Paisa to Rupees

      if (timestamp != null) {
        final date = DateFormat('yMMMd').format(timestamp.toDate());
        dailyTotals.update(date, (value) => value + amountRupees,
            ifAbsent: () => amountRupees);
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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
            'Transactions', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: _transactions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _dailyTotals.keys.length,
        itemBuilder: (context, index) {
          final date = _dailyTotals.keys.elementAt(index);
          final dailyTotal = _dailyTotals[date] ?? 0;

          // Filter transactions for this date
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

  Widget _buildDailyTransactions(String date, int dailyTotal,
      List<DocumentSnapshot> txns) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Colors.grey.shade300,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18, // Bigger font size
                  color: Colors.black87,
                ),
              ),
              Text(
                '₹$dailyTotal',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18, // Bigger font size
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
        ...txns.map((txn) {
          final amountPaisa = txn['amount'] as int? ?? 0;
          final amountRupees = amountPaisa ~/ 100;

          return ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(
              txn['uid'] ?? 'User',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              DateFormat('yMMMd').format(
                (txn['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
              ),
            ),
            trailing: Text(
              '₹$amountRupees',
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
