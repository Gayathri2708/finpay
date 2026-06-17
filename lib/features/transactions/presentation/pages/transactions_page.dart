import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../presentation/widgets/transaction_tile.dart';
import '../bloc/transaction_bloc.dart';
import '../../../wallet/presentation/widgets/offline_banner.dart';
import '../../../wallet/presentation/widgets/shimmer_list.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<TransactionBloc>().add(TransactionsLoadMore());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: ShimmerList(itemCount: 10),
            );
          }

          if (state is TransactionLoaded) {
            return Column(
              children: [
                if (state.isOffline) const OfflineBanner(),
                Expanded(
                  child: state.transactions.isEmpty
                      ? _buildEmptyState(context)
                      : RefreshIndicator(
                          onRefresh: () async {
                            context
                                .read<TransactionBloc>()
                                .add(TransactionsRefreshRequested());
                          },
                          child: ListView.separated(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(20),
                            itemCount: state.transactions.length +
                                (state.hasMore ? 1 : 0),
                            separatorBuilder: (_, _) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              if (index >= state.transactions.length) {
                                return const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              return TransactionTile(
                                transaction: state.transactions[index],
                              );
                            },
                          ),
                        ),
                ),
              ],
            );
          }

          if (state is TransactionError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: AppColors.error),
                  const Gap(12),
                  Text(state.message),
                  const Gap(12),
                  ElevatedButton(
                    onPressed: () => context
                        .read<TransactionBloc>()
                        .add(const TransactionsLoadRequested()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: AppColors.textHint),
          const Gap(16),
          Text(
            'No transactions yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Gap(8),
          Text(
            'Your transaction history will appear here',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}
