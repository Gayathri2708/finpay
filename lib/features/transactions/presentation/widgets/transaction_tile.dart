import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionTile extends StatelessWidget {
  final TransactionEntity transaction;

  const TransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.type == TransactionType.credit;
    final color = isCredit ? AppColors.success : AppColors.error;
    final prefix = isCredit ? '+' : '-';
    final icon = isCredit ? Icons.arrow_downward : Icons.arrow_upward;
    final amountStr = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    ).format(transaction.amount);
    final dateStr = DateFormat('dd MMM, hh:mm a').format(transaction.createdAt);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        isCredit ? 'Received' : 'Sent',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        transaction.description.isNotEmpty ? transaction.description : dateStr,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.textHint,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '$prefix$amountStr',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(2),
          if (transaction.status == TransactionStatus.pending)
            Text(
              'Pending',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.warning,
              ),
            )
          else
            Text(
              dateStr,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textHint,
              ),
            ),
        ],
      ),
    );
  }
}
