import jwt from 'jsonwebtoken';
import { env } from '../config/env';

/** Converts a time string like '15m' or '7d' to seconds. */
function toSeconds(val: string): number {
  const match = val.match(/^(\d+)([smhd])$/);
  if (!match) return 900; // fallback 15 minutes
  const num = parseInt(match[1]);
  switch (match[2]) {
    case 's': return num;
    case 'm': return num * 60;
    case 'h': return num * 3600;
    case 'd': return num * 86400;
    default: return 900;
  }
}

/** Generates a short-lived access token (default 15m) for the given user ID. */
export function generateAccessToken(userId: string): string {
  return jwt.sign({ userId }, env.JWT_SECRET, {
    expiresIn: toSeconds(env.JWT_EXPIRES_IN),
  });
}

/** Generates a long-lived refresh token (default 7d) for the given user ID. */
export function generateRefreshToken(userId: string): string {
  return jwt.sign({ userId }, env.JWT_REFRESH_SECRET, {
    expiresIn: toSeconds(env.JWT_REFRESH_EXPIRES_IN),
  });
}

/** Verifies and decodes an access token. Throws if invalid or expired. */
export function verifyAccessToken(token: string): { userId: string } {
  return jwt.verify(token, env.JWT_SECRET) as { userId: string };
}

/** Verifies and decodes a refresh token. Throws if invalid or expired. */
export function verifyRefreshToken(token: string): { userId: string } {
  return jwt.verify(token, env.JWT_REFRESH_SECRET) as { userId: string };
}
