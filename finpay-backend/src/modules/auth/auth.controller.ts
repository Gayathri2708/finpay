import { Response } from 'express';
import bcrypt from 'bcryptjs';
import { User } from '../users/user.model';
import { AuthRequest } from '../../middleware/auth.middleware';
import { generateAccessToken, generateRefreshToken } from '../../utils/jwt.utils';
import { success, error } from '../../utils/response.utils';

// In-memory blacklist for invalidated refresh tokens
const tokenBlacklist = new Set<string>();

/** Checks if a refresh token has been blacklisted (logged out). */
export function isTokenBlacklisted(token: string): boolean {
  return tokenBlacklist.has(token);
}

/** Registers a new user, hashes password, creates wallet with ₹10,000 starting balance. */
export async function register(req: AuthRequest, res: Response): Promise<void> {
  try {
    const { name, email, phone, password } = req.body;

    const existingUser = await User.findOne({ $or: [{ email }, { phone }] });
    if (existingUser) {
      error(res, 'Email or phone number already registered', 409);
      return;
    }

    const passwordHash = await bcrypt.hash(password, 12);
    const user = await User.create({
      name,
      email,
      phone,
      passwordHash,
      balance: 10000,
    });

    const accessToken = generateAccessToken(user._id.toString());
    const refreshToken = generateRefreshToken(user._id.toString());

    success(res, {
      access_token: accessToken,
      refresh_token: refreshToken,
      user: user.toSafeObject(),
    }, 'Registration successful', 201);
  } catch (err) {
    console.error('Register error:', err);
    error(res, 'Registration failed');
  }
}

/** Authenticates a user by email and password, returns JWT tokens. */
export async function login(req: AuthRequest, res: Response): Promise<void> {
  try {
    const { email, password } = req.body;

    const user = await User.findOne({ email });
    if (!user) {
      error(res, 'Invalid email or password', 401);
      return;
    }

    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      error(res, 'Invalid email or password', 401);
      return;
    }

    const accessToken = generateAccessToken(user._id.toString());
    const refreshToken = generateRefreshToken(user._id.toString());

    success(res, {
      access_token: accessToken,
      refresh_token: refreshToken,
      user: user.toSafeObject(),
    }, 'Login successful');
  } catch (err) {
    console.error('Login error:', err);
    error(res, 'Login failed');
  }
}

/** Issues a new access token using a valid refresh token. */
export async function refresh(req: AuthRequest, res: Response): Promise<void> {
  try {
    const { refresh_token } = req.body;

    if (isTokenBlacklisted(refresh_token)) {
      error(res, 'Refresh token has been revoked', 401);
      return;
    }

    const accessToken = generateAccessToken(req.userId!);

    success(res, { access_token: accessToken }, 'Token refreshed');
  } catch (err) {
    console.error('Refresh error:', err);
    error(res, 'Token refresh failed');
  }
}

/** Invalidates the refresh token by adding it to the blacklist. */
export async function logout(req: AuthRequest, res: Response): Promise<void> {
  try {
    const { refresh_token } = req.body;
    if (refresh_token) {
      tokenBlacklist.add(refresh_token);
    }

    success(res, null, 'Logged out successfully');
  } catch (err) {
    console.error('Logout error:', err);
    error(res, 'Logout failed');
  }
}
