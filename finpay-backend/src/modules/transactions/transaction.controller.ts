import { Response } from 'express';
import { AuthRequest } from '../../middleware/auth.middleware';
import { Transaction } from './transaction.model';
import { success, error } from '../../utils/response.utils';

/**
 * Returns paginated transactions for the authenticated user (as sender or recipient).
 * Sorted by createdAt descending. Supports page and limit query params.
 */
export async function getTransactions(req: AuthRequest, res: Response): Promise<void> {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 20;
    const skip = (page - 1) * limit;

    const filter = {
      $or: [{ fromUserId: req.userId }, { toUserId: req.userId }],
    };

    const [transactions, total] = await Promise.all([
      Transaction.find(filter)
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .lean(),
      Transaction.countDocuments(filter),
    ]);

    const formatted = transactions.map((t) => ({
      id: t._id,
      from_user_id: t.fromUserId,
      to_user_id: t.toUserId,
      amount: t.amount,
      type: t.type,
      status: t.status,
      description: t.description,
      reference: t.reference,
      created_at: t.createdAt.toISOString(),
    }));

    success(res, {
      transactions: formatted,
      total,
      page,
      limit,
      hasMore: skip + transactions.length < total,
    });
  } catch (err) {
    console.error('Get transactions error:', err);
    error(res, 'Failed to fetch transactions');
  }
}

/** Returns a single transaction by ID, only if it belongs to the authenticated user. */
export async function getTransactionById(req: AuthRequest, res: Response): Promise<void> {
  try {
    const transaction = await Transaction.findById(req.params.id).lean();

    if (!transaction) {
      error(res, 'Transaction not found', 404);
      return;
    }

    const userId = req.userId!;
    if (
      transaction.fromUserId.toString() !== userId &&
      transaction.toUserId.toString() !== userId
    ) {
      error(res, 'Transaction not found', 404);
      return;
    }

    success(res, {
      id: transaction._id,
      from_user_id: transaction.fromUserId,
      to_user_id: transaction.toUserId,
      amount: transaction.amount,
      type: transaction.type,
      status: transaction.status,
      description: transaction.description,
      reference: transaction.reference,
      created_at: transaction.createdAt.toISOString(),
    });
  } catch (err) {
    console.error('Get transaction by ID error:', err);
    error(res, 'Failed to fetch transaction');
  }
}
