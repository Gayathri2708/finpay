import express, { Request, Response, NextFunction } from 'express';
import helmet from 'helmet';
import cors from 'cors';
import morgan from 'morgan';
import { env } from './config/env';
import { connectDatabase } from './config/database';
import { apiLimiter } from './middleware/rateLimit.middleware';
import authRoutes from './modules/auth/auth.routes';
import walletRoutes from './modules/wallet/wallet.routes';
import transactionRoutes from './modules/transactions/transaction.routes';
import userRoutes from './modules/users/user.routes';

const app = express();

// Security headers
app.use(helmet());

// CORS — allows requests from Flutter apps on any origin during development
app.use(cors({ origin: '*', credentials: true }));

// Request logging
app.use(morgan('dev'));

// Body parser
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Rate limiting on all API routes
app.use('/api', apiLimiter);

// Routes
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/wallet', walletRoutes);
app.use('/api/v1/transactions', transactionRoutes);
app.use('/api/v1/users', userRoutes);

// Health check
app.get('/health', (_req: Request, res: Response) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// 404 handler
app.use((_req: Request, res: Response) => {
  res.status(404).json({ success: false, message: 'Route not found' });
});

// Global error handler — catches any unhandled errors so the server never crashes
app.use((err: Error, _req: Request, res: Response, _next: NextFunction) => {
  console.error('Unhandled error:', err);
  res.status(500).json({ success: false, message: 'Internal server error' });
});

/** Starts the Express server and connects to MongoDB. */
async function start(): Promise<void> {
  await connectDatabase();
  app.listen(env.PORT, () => {
    console.log(`🚀 FinPay API running on http://localhost:${env.PORT}`);
    console.log(`📚 API base: http://localhost:${env.PORT}/api/v1`);
  });
}

start();

export default app;
