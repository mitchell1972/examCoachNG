import { Request, Response, NextFunction } from 'express';
import jwt, { SignOptions } from 'jsonwebtoken';
import { Logger } from '../utils/logger';

// Extend Express Request type to include user
declare global {
  namespace Express {
    interface Request {
      user?: {
        id: string;
        email?: string;
        role?: string;
      };
    }
  }
}

const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key-change-in-production';
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '7d';

/**
 * Generate JWT token
 */
export function generateToken(payload: { id: string; email?: string; role?: string }): string {
  return jwt.sign(payload, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN as any });
}

/**
 * Verify JWT token
 */
export function verifyToken(token: string): any {
  try {
    return jwt.verify(token, JWT_SECRET);
  } catch (error) {
    throw new Error('Invalid token');
  }
}

/**
 * Authentication middleware - requires valid JWT
 */
export function authenticate(req: Request, res: Response, next: NextFunction): void {
  try {
    // Get token from header
    const authHeader = req.headers.authorization;
    
    if (!authHeader) {
      res.status(401).json({ error: 'No authorization header provided' });
      return;
    }

    // Check if it's a Bearer token
    if (!authHeader.startsWith('Bearer ')) {
      res.status(401).json({ error: 'Invalid authorization format. Use Bearer token' });
      return;
    }

    // Extract token
    const token = authHeader.substring(7);

    // Verify token
    const decoded = verifyToken(token);
    
    // Attach user to request
    req.user = {
      id: decoded.id,
      email: decoded.email,
      role: decoded.role
    };

    next();
  } catch (error: any) {
    Logger.error('Authentication failed:', error);
    res.status(401).json({ error: 'Invalid or expired token' });
    return;
  }
}

/**
 * Optional authentication - doesn't fail if no token, but attaches user if valid token exists
 */
export function optionalAuth(req: Request, res: Response, next: NextFunction) {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      // No token provided, continue without user
      return next();
    }

    const token = authHeader.substring(7);
    const decoded = verifyToken(token);
    
    req.user = {
      id: decoded.id,
      email: decoded.email,
      role: decoded.role
    };
  } catch (error) {
    // Invalid token, continue without user
    Logger.debug('Optional auth: Invalid token provided');
  }
  
  next();
}

/**
 * Role-based authorization middleware
 */
export function authorize(...roles: string[]) {
  return (req: Request, res: Response, next: NextFunction): void => {
    if (!req.user) {
      res.status(401).json({ error: 'Authentication required' });
      return;
    }

    if (roles.length > 0 && !roles.includes(req.user.role || '')) {
      res.status(403).json({ error: 'Insufficient permissions' });
      return;
    }

    next();
  };
}

/**
 * API Key authentication for service-to-service communication
 */
export function apiKeyAuth(req: Request, res: Response, next: NextFunction) {
  const apiKey = req.headers['x-api-key'] as string;
  const validApiKey = process.env.API_KEY;

  if (!validApiKey) {
    // API key auth not configured, skip
    return next();
  }

  if (!apiKey || apiKey !== validApiKey) {
    return res.status(401).json({ error: 'Invalid API key' });
  }

  next();
}

/**
 * Rate limiting per user (requires authentication)
 */
export function userRateLimit(maxRequests: number = 100, windowMs: number = 900000) {
  const userRequests = new Map<string, { count: number; resetTime: number }>();

  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user) {
      return next(); // Skip rate limiting for unauthenticated requests
    }

    const userId = req.user.id;
    const now = Date.now();
    const userLimit = userRequests.get(userId);

    if (!userLimit || now > userLimit.resetTime) {
      // Create new window
      userRequests.set(userId, {
        count: 1,
        resetTime: now + windowMs
      });
      return next();
    }

    if (userLimit.count >= maxRequests) {
      const retryAfter = Math.ceil((userLimit.resetTime - now) / 1000);
      res.setHeader('Retry-After', retryAfter.toString());
      return res.status(429).json({
        error: 'Too many requests',
        retryAfter
      });
    }

    userLimit.count++;
    next();
  };
}
