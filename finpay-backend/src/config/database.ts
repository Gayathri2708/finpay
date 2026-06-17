import mongoose from 'mongoose';
import { env } from './env';

/** Connects to MongoDB with automatic retry on failure (max 5 attempts). */
export async function connectDatabase(): Promise<void> {
  const maxRetries = 5;
  let attempt = 0;

  while (attempt < maxRetries) {
    try {
      await mongoose.connect(env.MONGODB_URI);
      console.log('✅ MongoDB connected successfully');
      return;
    } catch (error) {
      attempt++;
      console.error(`❌ MongoDB connection attempt ${attempt}/${maxRetries} failed:`, error);
      if (attempt >= maxRetries) {
        console.error('🛑 Could not connect to MongoDB. Exiting.');
        process.exit(1);
      }
      // Wait 3 seconds before retrying
      await new Promise((resolve) => setTimeout(resolve, 3000));
    }
  }
}
