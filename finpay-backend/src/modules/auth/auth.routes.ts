import { Router } from 'express';
import { body } from 'express-validator';
import { register, login, refresh, logout } from './auth.controller';
import { validate } from '../../middleware/validate.middleware';
import { verifyRefreshTokenMiddleware, verifyAccessTokenMiddleware } from '../../middleware/auth.middleware';
import { authLimiter } from '../../middleware/rateLimit.middleware';

const router = Router();

/** POST /auth/register — create a new user account. */
router.post(
  '/register',
  authLimiter,
  [
    body('name').trim().notEmpty().withMessage('Name is required'),
    body('email').isEmail().normalizeEmail().withMessage('Valid email is required'),
    body('phone').trim().notEmpty().withMessage('Phone number is required'),
    body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),
  ],
  validate,
  register
);

/** POST /auth/login — authenticate with email and password. */
router.post(
  '/login',
  authLimiter,
  [
    body('email').isEmail().normalizeEmail().withMessage('Valid email is required'),
    body('password').notEmpty().withMessage('Password is required'),
  ],
  validate,
  login
);

/** POST /auth/refresh — get a new access token using a refresh token. */
router.post('/refresh', verifyRefreshTokenMiddleware, refresh);

/** POST /auth/logout — invalidate the refresh token. */
router.post('/logout', verifyAccessTokenMiddleware, logout);

export default router;
