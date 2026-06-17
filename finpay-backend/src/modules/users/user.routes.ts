import { Router } from 'express';
import { body } from 'express-validator';
import { getMe, updateFcmToken } from './user.controller';
import { verifyAccessTokenMiddleware } from '../../middleware/auth.middleware';
import { validate } from '../../middleware/validate.middleware';

const router = Router();

/** GET /users/me — returns the authenticated user's profile. */
router.get('/me', verifyAccessTokenMiddleware, getMe);

/** PUT /users/fcm-token — updates the user's push notification token. */
router.put(
  '/fcm-token',
  verifyAccessTokenMiddleware,
  [body('fcm_token').trim().notEmpty().withMessage('FCM token is required')],
  validate,
  updateFcmToken
);

export default router;
