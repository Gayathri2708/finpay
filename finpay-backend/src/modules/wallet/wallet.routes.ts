import { Router } from 'express';
import { body } from 'express-validator';
import { getWallet, sendMoney } from './wallet.controller';
import { verifyAccessTokenMiddleware } from '../../middleware/auth.middleware';
import { validate } from '../../middleware/validate.middleware';

const router = Router();

/** GET /wallet — returns the authenticated user's balance. */
router.get('/', verifyAccessTokenMiddleware, getWallet);

/** POST /wallet/send — transfers money to a recipient by phone number. */
router.post(
  '/send',
  verifyAccessTokenMiddleware,
  [
    body('to_phone').trim().notEmpty().withMessage('Recipient phone is required'),
    body('amount').isFloat({ gt: 0 }).withMessage('Amount must be greater than 0'),
  ],
  validate,
  sendMoney
);

export default router;
