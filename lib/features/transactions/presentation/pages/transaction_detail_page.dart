// Displays full transaction details with status badge, share receipt, and deep link support.
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionDetailPage extends StatelessWidget {
  final TransactionEntity transaction;

  const TransactionDetailPage({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.type == TransactionType.credit;
    final amountColor = isCredit ? AppColors.success : AppColors.error;
    final prefix = isCredit ? '+' : '-';
    final amountStr = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    ).format(transaction.amount);
    final dateStr = DateFormat('dd MMMM yyyy, hh:mm a').format(
      transaction.createdAt,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareReceipt(amountStr, dateStr),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Gap(16),
            Icon(
              isCredit ? Icons.arrow_downward : Icons.arrow_upward,
              size: 48,
              color: amountColor,
            ),
            const Gap(12),
            Text(
              '$prefix$amountStr',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: amountColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(8),
            _buildStatusBadge(context),
            const Gap(32),
            _buildDetailCard(context, dateStr),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final (label, color) = switch (transaction.status) {
      TransactionStatus.pending => ('Pending', AppColors.warning),
      TransactionStatus.completed => ('Completed', AppColors.success),
      TransactionStatus.failed => ('Failed', AppColors.error),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context, String dateStr) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          _detailRow(context, 'From', transaction.fromUserId),
          const Divider(height: 24),
          _detailRow(context, 'To', transaction.toUserId),
          const Divider(height: 24),
          _detailRow(context, 'Description',
              transaction.description.isNotEmpty
                  ? transaction.description
                  : 'No description'),
          const Divider(height: 24),
          _detailRow(context, 'Date & Time', dateStr),
          const Divider(height: 24),
          _detailRow(context, 'Transaction ID', transaction.id),
        ],
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  void _shareReceipt(String amountStr, String dateStr) {
    final type = transaction.type == TransactionType.credit
        ? 'Received'
        : 'Sent';
    final receipt = '''
FinPay Payment Receipt
──────────────────
$type: $amountStr
Status: ${transaction.status.name.toUpperCase()}
From: ${transaction.fromUserId}
To: ${transaction.toUserId}
Description: ${transaction.description}
Date: $dateStr
ID: ${transaction.id}
──────────────────
Powered by FinPay
''';
    Share.share(receipt);
  }
}
