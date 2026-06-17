import { Response } from 'express';
import mongoose from 'mongoose';
import { v4 as uuidv4 } from 'uuid';
import { AuthRequest } from '../../middleware/auth.middleware';
import { User } from '../users/user.model';
import { Transaction } from '../transactions/transaction.model';
import { success, error } from '../../utils/response.utils';

/** Returns the authenticated user's wallet balance and currency. */
export async function getWallet(req: AuthRequest, res: Response): Promise<void> {
  try {
    const user = await User.findById(req.userId);
    if (!user) {
      error(res, 'User not found', 404);
      return;
    }

    success(res, {
      user_id: user._id,
      balance: user.balance,
      currency: 'INR',
    });
  } catch (err) {
    console.error('Get wallet error:', err);
    error(res, 'Failed to fetch wallet');
  }
}

/**
 * Transfers money from the authenticated user to a recipient identified by phone number.
 * Uses a MongoDB session (transaction) to ensure atomicity — both balances update or neither does.
 */
export async function sendMoney(req: AuthRequest, res: Response): Promise<void> {
  const session = await mongoose.startSession();
  session.startTransaction();

  try {
    const { to_phone, amount, description } = req.body;
    const senderId = req.userId!;

    const sender = await User.findById(senderId).session(session);
    if (!sender) {
      await session.abortTransaction();
      error(res, 'Sender not found', 404);
      return;
    }

    if (amount <= 0) {
      await session.abortTransaction();
      error(res, 'Amount must be greater than zero', 400);
      return;
    }

    if (sender.balance < amount) {
      await session.abortTransaction();
      error(res, 'Insufficient balance', 400);
      return;
    }

    const recipient = await User.findOne({ phone: to_phone }).session(session);
    if (!recipient) {
      await session.abortTransaction();
      error(res, 'Recipient not found', 404);
      return;
    }

    if (sender._id.equals(recipient._id)) {
      await session.abortTransaction();
      error(res, 'Cannot send money to yourself', 400);
      return;
    }

    // Deduct from sender, credit to recipient
    sender.balance -= amount;
    recipient.balance += amount;
    await sender.save({ session });
    await recipient.save({ session });

    const reference = uuidv4();

    // Create debit transaction for sender
    await Transaction.create(
      [{
        fromUserId: sender._id,
        toUserId: recipient._id,
        amount,
        type: 'debit',
        status: 'completed',
        description: description || '',
        reference,
      }],
      { session }
    );

    // Create credit transaction for recipient
    await Transaction.create(
      [{
        fromUserId: sender._id,
        toUserId: recipient._id,
        amount,
        type: 'credit',
        status: 'completed',
        description: description || '',
        reference: `${reference}-cr`,
      }],
      { session }
    );

    await session.commitTransaction();

    success(res, {
      wallet: {
        user_id: sender._id,
        balance: sender.balance,
        currency: 'INR',
      },
      reference,
    }, 'Transfer successful');
  } catch (err) {
    await session.abortTransaction();
    console.error('Send money error:', err);
    error(res, 'Transfer failed');
  } finally {
    session.endSession();
  }
}
