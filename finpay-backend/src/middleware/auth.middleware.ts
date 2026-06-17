import { Request, Response, NextFunction } from 'express';
import { verifyAccessToken, verifyRefreshToken } from '../utils/jwt.utils';
import { error } from '../utils/response.utils';

/** Extends Express Request to carry the authenticated user's ID. */
export interface AuthRequest extends Request {
  userId?: string;
}

/** Extracts the Bearer token from the Authorization header, verifies it, and attaches userId to the request. */
export function verifyAccessTokenMiddleware(
  req: AuthRequest,
  res: Response,
  next: NextFunction
): void {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      error(res, 'Access token required', 401);
      return;
    }

    const token = authHeader.split(' ')[1];
    const decoded = verifyAccessToken(token);
    req.userId = decoded.userId;
    next();
  } catch {
    error(res, 'Invalid or expired access token', 401);
  }
}

/** Verifies a refresh token from the request body. Used only by the /auth/refresh endpoint. */
export function verifyRefreshTokenMiddleware(
  req: AuthRequest,
  res: Response,
  next: NextFunction
): void {
  try {
    const { refresh_token } = req.body;
    if (!refresh_token) {
      error(res, 'Refresh token required', 401);
      return;
    }

    const decoded = verifyRefreshToken(refresh_token);
    req.userId = decoded.userId;
    next();
  } catch {
    error(res, 'Invalid or expired refresh token', 401);
  }
}
