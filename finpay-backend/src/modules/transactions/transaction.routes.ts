import { Router } from 'express';
import { getTransactions, getTransactionById } from './transaction.controller';
import { verifyAccessTokenMiddleware } from '../../middleware/auth.middleware';

const router = Router();

/** GET /transactions — paginated transaction history for the authenticated user. */
router.get('/', verifyAccessTokenMiddleware, getTransactions);

/** GET /transactions/:id — single transaction detail. */
router.get('/:id', verifyAccessTokenMiddleware, getTransactionById);

export default router;
