import mongoose, { Document, Schema } from 'mongoose';
import bcrypt from 'bcryptjs';

export interface IUser extends Document {
  name: string;
  email: string;
  phone: string;
  passwordHash: string;
  balance: number;
  fcmToken: string | null;
  isActive: boolean;
  createdAt: Date;
  comparePassword(password: string): Promise<boolean>;
  toSafeObject(): Record<string, unknown>;
}

const userSchema = new Schema<IUser>({
  name: { type: String, required: true, trim: true },
  email: { type: String, required: true, unique: true, lowercase: true, trim: true },
  phone: { type: String, required: true, unique: true, trim: true },
  passwordHash: { type: String, required: true },
  balance: { type: Number, default: 10000 },
  fcmToken: { type: String, default: null },
  isActive: { type: Boolean, default: true },
  createdAt: { type: Date, default: Date.now },
});

userSchema.index({ email: 1 });
userSchema.index({ phone: 1 });

/** Compares a plain-text password against the stored bcrypt hash. */
userSchema.methods.comparePassword = async function (password: string): Promise<boolean> {
  return bcrypt.compare(password, this.passwordHash);
};

/** Returns user data without sensitive fields like passwordHash. */
userSchema.methods.toSafeObject = function (): Record<string, unknown> {
  return {
    id: this._id,
    full_name: this.name,
    email: this.email,
    phone_number: this.phone,
    balance: this.balance,
    is_verified: this.isActive,
    avatar_url: null,
    created_at: this.createdAt.toISOString(),
  };
};

export const User = mongoose.model<IUser>('User', userSchema);
