import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import rateLimit from 'express-rate-limit';
import dotenv from 'dotenv';
import { pool } from './config/database';

// Import routes
import authRoutes from './routes/auth';
import questionRoutes from './routes/questions';
import sessionRoutes from './routes/sessions';
import userRoutes from './routes/users';
import analyticsRoutes from './routes/analytics';
import subscriptionsRoutes from './routes/subscriptions';

// Import middleware
import { authenticate, optionalAuth } from './middleware/auth';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Security middleware
app.use(helmet());

// CORS configuration
const corsOrigins = process.env.CORS_ORIGINS 
  ? process.env.CORS_ORIGINS.split(',').map(origin => origin.trim())
  : ['http://localhost:3000', 'http://localhost:5000', 'http://localhost:5500'];

app.use(cors({
  origin: process.env.NODE_ENV === 'production' ? corsOrigins : '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true
}));

// Rate limiting
const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '900000'), // 15 minutes
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100'),
  message: {
    error: 'Too many requests from this IP, please try again later.'
  }
});
app.use('/api/', limiter);

// Body parsing middleware
app.use(compression());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development'
  });
});

// API Routes
// Public routes (no authentication required)
app.use('/api/auth', authRoutes);
app.use('/api/questions', optionalAuth, questionRoutes); // Optional auth for better experience

// Protected routes (authentication required)
app.use('/api/sessions', authenticate, sessionRoutes);
app.use('/api/users', authenticate, userRoutes);
app.use('/api/analytics', authenticate, analyticsRoutes);
app.use('/api/subscriptions', authenticate, subscriptionsRoutes);

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'ExamCoach JAMB CBT Backend API',
    version: '1.0.0',
    documentation: '/api/docs',
    health: '/health'
  });
});

// Error handling middleware
app.use((err: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error('Error:', err);
  
  res.status(err.status || 500).json({
    error: process.env.NODE_ENV === 'production' 
      ? 'Internal server error' 
      : err.message,
    ...(process.env.NODE_ENV !== 'production' && { stack: err.stack })
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Route not found',
    path: req.originalUrl
  });
});

// Graceful shutdown
process.on('SIGTERM', async () => {
  console.log('SIGTERM received, shutting down gracefully');
  await pool.end();
  process.exit(0);
});

process.on('SIGINT', async () => {
  console.log('SIGINT received, shutting down gracefully');
  await pool.end();
  process.exit(0);
});

if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`🚀 ExamCoach Backend running on port ${PORT}`);
    console.log(`📚 Environment: ${process.env.NODE_ENV || 'development'}`);
    console.log(`🔗 Health check: http://localhost:${PORT}/health`);
  });
}

export default app;