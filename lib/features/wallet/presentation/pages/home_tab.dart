import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../transactions/presentation/bloc/transaction_bloc.dart';
import '../../../transactions/presentation/widgets/transaction_tile.dart';
import '../bloc/wallet_bloc.dart';
import '../widgets/balance_card.dart';
import '../widgets/offline_banner.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/shimmer_card.dart';
import '../widgets/shimmer_list.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<WalletBloc>().add(WalletRefreshRequested());
        context.read<TransactionBloc>().add(TransactionsRefreshRequested());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWalletSection(context),
            const Gap(24),
            _buildQuickActions(context),
            const Gap(24),
            _buildRecentTransactions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletSection(BuildContext context) {
    return BlocBuilder<WalletBloc, WalletState>(
      builder: (context, state) {
        if (state is WalletLoading) {
          return const ShimmerCard();
        }
        if (state is WalletLoaded) {
          return Column(
            children: [
              if (state.isOffline) const OfflineBanner(),
              if (state.isOffline) const Gap(12),
              BalanceCard(wallet: state.wallet),
            ],
          );
        }
        if (state is WalletError) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(Icons.error_outline, color: AppColors.error),
                const Gap(8),
                Text(state.message),
                const Gap(8),
                TextButton(
                  onPressed: () =>
                      context.read<WalletBloc>().add(WalletLoadRequested()),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        return const ShimmerCard();
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        QuickActionButton(
          icon: Icons.send,
          label: 'Send',
          color: AppColors.primary,
          onTap: () => context.pushNamed('send-money'),
        ),
        QuickActionButton(
          icon: Icons.download,
          label: 'Receive',
          color: AppColors.secondary,
          onTap: () {},
        ),
        QuickActionButton(
          icon: Icons.payment,
          label: 'Pay',
          color: AppColors.warning,
          onTap: () {},
        ),
        QuickActionButton(
          icon: Icons.history,
          label: 'History',
          color: AppColors.success,
          onTap: () => context.pushNamed('transactions'),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () => context.pushNamed('transactions'),
              child: const Text('See All'),
            ),
          ],
        ),
        const Gap(4),
        BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, state) {
            if (state is TransactionLoading) {
              return const ShimmerList(itemCount: 3);
            }
            if (state is TransactionLoaded) {
              if (state.transactions.isEmpty) {
                return _buildEmptyState(context);
              }
              final recent = state.transactions.take(5).toList();
              return Column(
                children: recent
                    .map((t) => TransactionTile(transaction: t))
                    .toList(),
              );
            }
            return _buildEmptyState(context);
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: AppColors.textHint,
          ),
          const Gap(12),
          Text(
            'No transactions yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
