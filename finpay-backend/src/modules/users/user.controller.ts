import { Response } from 'express';
import { AuthRequest } from '../../middleware/auth.middleware';
import { User } from './user.model';
import { success, error } from '../../utils/response.utils';

/** Returns the authenticated user's profile (without sensitive fields). */
export async function getMe(req: AuthRequest, res: Response): Promise<void> {
  try {
    const user = await User.findById(req.userId);
    if (!user) {
      error(res, 'User not found', 404);
      return;
    }

    success(res, { user: user.toSafeObject() });
  } catch (err) {
    console.error('Get me error:', err);
    error(res, 'Failed to fetch profile');
  }
}

/** Updates the authenticated user's FCM token for push notifications. */
export async function updateFcmToken(req: AuthRequest, res: Response): Promise<void> {
  try {
    const { fcm_token } = req.body;

    await User.findByIdAndUpdate(req.userId, { fcmToken: fcm_token });

    success(res, null, 'FCM token updated');
  } catch (err) {
    console.error('Update FCM token error:', err);
    error(res, 'Failed to update FCM token');
  }
}
